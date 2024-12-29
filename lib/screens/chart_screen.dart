import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class ChartScreen extends StatefulWidget {
  final String userId;
  const ChartScreen({super.key, required this.userId});

  @override
  _ChartScreenState createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  bool isLoading = true;
  List<Map<String, dynamic>> data = [];

  // Cache for timestamps to improve performance
  late List<double> _timestamps;

  @override
  void initState() {
    super.initState();
    fetchHistoryData();
  }

  void fetchHistoryData() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    try {
      final checksRef =
          _dbRef.child('Checks').orderByChild('UID').equalTo(widget.userId);
      final snapshot = await checksRef.get();

      if (!mounted) return;

      if (snapshot.exists) {
        final rawData = Map<String, dynamic>.from(snapshot.value as Map);
        final newData = rawData.entries.map((entry) {
          final item = Map<String, dynamic>.from(entry.value);
          item['Datetime'] = entry.value['Datetime'] as String;
          return item;
        }).toList();

        // Sort data by datetime
        newData.sort((a, b) {
          final dateA = DateTime.parse(a['Datetime']);
          final dateB = DateTime.parse(b['Datetime']);
          return dateA.compareTo(dateB);
        });

        // Initialize cached values
        _timestamps = newData
            .map((item) => DateTime.parse(item['Datetime'])
                .millisecondsSinceEpoch
                .toDouble())
            .toList();

        setState(() {
          data = newData;
          isLoading = false;
        });
      } else {
        setState(() {
          data = [];
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          data = [];
          isLoading = false;
        });
      }
      print('Error fetching data: $e');
    }
  }

  List<FlSpot> _createSpots(String field) {
    if (data.isEmpty) return [];

    return List.generate(data.length, (i) {
      final value = data[i][field]?.toDouble() ?? 0;
      return FlSpot(_timestamps[i], value);
    });
  }

  LineChartBarData _createLineChartBarData(List<FlSpot> spots, Color color) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: color,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          return FlDotCirclePainter(
            radius: 4,
            color: color,
            strokeWidth: 1,
            strokeColor: Colors.white,
          );
        },
      ),
      belowBarData: BarAreaData(show: false),
    );
  }

  String _getBottomTitle(double value) {
    try {
      final DateTime date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
      return DateFormat('HH:mm\ndd/MM').format(date); // Format lebih ringkas
    } catch (e) {
      return '';
    }
  }

  LineChartData _createChartData(List<LineChartBarData> bars) {
    // Buat list timestamps dari data spots
    final List<double> timestamps = bars
        .expand((barData) => barData.spots.map((spot) => spot.x))
        .toSet()
        .toList()
      ..sort(); // Urutkan timestamp

    // Normalisasi timestamps menggunakan index berbasis jumlah data
    final List<double> normalizedIndexes = List.generate(
      timestamps.length,
      (index) => index.toDouble() / (timestamps.length - 1), // Rentang [0, 1]
    );

    final double intervalX =
        1.0 / (timestamps.length - 1); // Interval tetap untuk sebaran

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 20,
        verticalInterval: intervalX,
      ),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            interval: 20,
            getTitlesWidget: (value, meta) => Text(
              value.toInt().toString(),
              style: const TextStyle(fontSize: 10),
            ),
          ),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 50,
            interval: intervalX,
            getTitlesWidget: (value, meta) {
              int index = (value * (timestamps.length - 1)).round();
              if (index >= 0 && index < timestamps.length) {
                final String title = _getBottomTitle(timestamps[index]);
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 9),
                    textAlign: TextAlign.center,
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
      lineBarsData: bars.map((barData) {
        // Peta ulang spots berdasarkan index normalisasi
        final List<FlSpot> adjustedSpots = barData.spots.map((spot) {
          int originalIndex = timestamps.indexOf(spot.x);
          final normalizedX = normalizedIndexes[originalIndex];
          return FlSpot(normalizedX, spot.y);
        }).toList();
        return barData.copyWith(spots: adjustedSpots);
      }).toList(),
      lineTouchData: const LineTouchData(
        enabled: true,
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            color: color,
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }

  Widget buildHealthChart() {
    if (data.isEmpty) {
      return const Center(child: Text('No health data available'));
    }

    final bars = [
      _createLineChartBarData(_createSpots('Heart Rate'), Colors.blue),
      _createLineChartBarData(_createSpots('SpO2'), Colors.green),
      _createLineChartBarData(_createSpots('Body Temp'), Colors.orange),
    ];

    return Column(
      children: [
        // Wrap the chart with SizedBox to limit its height
        SizedBox(
          height: 300, // Fix the height of the chart
          child: LineChart(_createChartData(bars)),
        ),
        const SizedBox(height: 10), // Space between chart and legend
        // Wrap the legend in a SingleChildScrollView to handle overflow
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildLegendItem('Heart Rate', Colors.blue),
              _buildLegendItem('SpO2', Colors.green),
              _buildLegendItem('Body Temp', Colors.orange),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildRoomChart() {
    if (data.isEmpty) {
      return const Center(child: Text('No room data available'));
    }

    final bars = [
      _createLineChartBarData(_createSpots('Room Temp'), Colors.blue),
      _createLineChartBarData(
          _createSpots('Room Humi'), const Color.fromARGB(255, 67, 255, 167)),
    ];

    return Column(
      children: [
        // Wrap the chart with SizedBox to limit its height
        SizedBox(
          height: 300, // Fix the height of the chart
          child: LineChart(_createChartData(bars)),
        ),
        const SizedBox(height: 10), // Space between chart and legend
        // Wrap the legend in a SingleChildScrollView to handle overflow
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildLegendItem('Room Temp', Colors.blue),
              _buildLegendItem('Room Humi', Colors.purple),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else if (data.isEmpty)
                const Center(
                  child: Text(
                    'No Data Available',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                )
              else ...[
                // Health Data Card
                Card(
                  elevation: 4,
                  shadowColor: Colors.black26,
                  color:
                      const Color(0xffdeffda), // Warna untuk Health Data Card
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Health Data",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        // Wrap health chart in ConstrainedBox to prevent layout overflow
                        ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxHeight:
                                350, // Set a max height to avoid overflow
                          ),
                          child: buildHealthChart(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Room Data Card
                Card(
                  elevation: 4,
                  shadowColor: Colors.black26,
                  color: Colors.blue.shade50, // Warna untuk Room Data Card
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Room Data",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        // Wrap room chart in ConstrainedBox to prevent layout overflow
                        ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxHeight:
                                350, // Set a max height to avoid overflow
                          ),
                          child: buildRoomChart(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
