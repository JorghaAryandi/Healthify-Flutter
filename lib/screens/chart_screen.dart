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

  @override
  void initState() {
    super.initState();
    fetchHistoryData();
  }

  void fetchHistoryData() async {
    print("userId: ${widget.userId}");
    final checksRef =
        _dbRef.child('Checks').orderByChild('UID').equalTo(widget.userId);
    final snapshot = await checksRef.get();

    if (snapshot.exists) {
      final rawData = Map<String, dynamic>.from(snapshot.value as Map);

      setState(() {
        data = rawData.entries.map((entry) {
          final item = Map<String, dynamic>.from(entry.value);
          // Ensure Datetime is a string in the format 'yyyy-MM-dd HH:mm:ss'
          item['Datetime'] =
              entry.value['Datetime'] as String; // Store as String
          return item;
        }).toList();

        // Sort data by 'Datetime' in ascending order
        data.sort((a, b) {
          final dateA = DateTime.parse(a['Datetime']);
          final dateB = DateTime.parse(b['Datetime']);
          return dateA.compareTo(dateB); // Ascending order
        });

        isLoading = false;
      });
    } else {
      setState(() {
        data = [];
        isLoading = false;
      });
    }
  }

  List<LineChartBarData> _buildChartData1(List<Map<String, dynamic>> data) {
    List<FlSpot> heartRateSpots = [];
    List<FlSpot> spo2Spots = [];
    List<FlSpot> bodyTempSpots = [];

    for (int i = 0; i < data.length; i++) {
      final timestamp =
          DateTime.parse(data[i]['Datetime']).millisecondsSinceEpoch.toDouble();

      // Printing values before adding to FlSpot lists
      String formattedTime = formatDatetime(timestamp.toInt());

      print('Formatted Time: $formattedTime');
      print('Heart Rate: ${data[i]['Heart Rate']?.toDouble() ?? 0}');
      print('SpO2: ${data[i]['SpO2']?.toDouble() ?? 0}');
      print('Body Temp: ${data[i]['Body Temp']?.toDouble() ?? 0}');

      // Add FlSpot values to the respective lists
      heartRateSpots
          .add(FlSpot(timestamp, data[i]['Heart Rate']?.toDouble() ?? 0));
      spo2Spots.add(FlSpot(timestamp, data[i]['SpO2']?.toDouble() ?? 0));
      bodyTempSpots
          .add(FlSpot(timestamp, data[i]['Body Temp']?.toDouble() ?? 0));
    }

    return [
      LineChartBarData(
        spots: heartRateSpots,
        isCurved: true,
        color: Colors.blueAccent,
        barWidth: 4,
        isStrokeCapRound: true,
        belowBarData: BarAreaData(show: false),
      ),
      LineChartBarData(
        spots: spo2Spots,
        isCurved: true,
        color: Colors.greenAccent,
        barWidth: 4,
        isStrokeCapRound: true,
        belowBarData: BarAreaData(show: false),
      ),
      LineChartBarData(
        spots: bodyTempSpots,
        isCurved: true,
        color: Colors.orangeAccent,
        barWidth: 4,
        isStrokeCapRound: true,
        belowBarData: BarAreaData(show: false),
      ),
    ];
  }

  List<LineChartBarData> _buildChartData2(List<Map<String, dynamic>> data) {
    List<FlSpot> roomTempSpots = [];
    List<FlSpot> roomHumiSpots = [];

    for (int i = 0; i < data.length; i++) {
      final timestamp =
          DateTime.parse(data[i]['Datetime']).millisecondsSinceEpoch.toDouble();

      // Printing values before adding to FlSpot lists
      String formattedTime = formatDatetime(timestamp.toInt());
      print('Formatted Time: $formattedTime');
      print('Room Temp: ${data[i]['Room Temp']?.toDouble() ?? 0}');
      print('Room Humi: ${data[i]['Room Humi']?.toDouble() ?? 0}');

      roomTempSpots
          .add(FlSpot(timestamp, data[i]['Room Temp']?.toDouble() ?? 0));
      roomHumiSpots
          .add(FlSpot(timestamp, data[i]['Room Humi']?.toDouble() ?? 0));
    }

    return [
      LineChartBarData(
        spots: roomTempSpots,
        isCurved: true,
        color: Colors.blue,
        barWidth: 4,
        isStrokeCapRound: true,
        belowBarData: BarAreaData(show: false),
      ),
      LineChartBarData(
        spots: roomHumiSpots,
        isCurved: true,
        color: Colors.purpleAccent,
        barWidth: 4,
        isStrokeCapRound: true,
        belowBarData: BarAreaData(show: false),
      ),
    ];
  }

  String formatDatetime(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('yyyy-MM-dd HH:mm')
        .format(date); // Format as 'YYYY-MM-DD HH:mm'
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else ...[
                // Card for Chart 1: Heart Rate, SpO2, and Body Temperature
                Card(
                  elevation: 4,
                  shadowColor: Colors.black26,
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
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.4,
                          child: LineChart(LineChartData(
                            gridData:
                                const FlGridData(show: false), // Hilangkan grid
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 40, // Beri ruang untuk label Y
                                  interval:
                                      10, // Sesuaikan interval Y dengan data
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      value
                                          .toInt()
                                          .toString(), // Menampilkan nilai sebagai integer
                                      style: const TextStyle(fontSize: 10),
                                      textAlign: TextAlign.center,
                                    );
                                  },
                                ),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(
                                    showTitles: false), // Hilangkan di kanan
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(
                                    showTitles: false), // Hilangkan di atas
                              ),
                              // Inside your chart setup
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true, // Show labels on the X-axis
                                  reservedSize:
                                      60, // Ensure there's enough space for the labels
                                  getTitlesWidget: (value, meta) {
                                    final timestamp = value
                                        .toInt(); // Convert timestamp to int
                                    String formattedTime = formatDatetime(
                                        timestamp); // Format the timestamp

                                    return Transform.translate(
                                      offset: Offset(0,
                                          10), // Adjust the label position vertically
                                      child: Transform.rotate(
                                        angle:
                                            -0.5, // Rotate the label to make it readable
                                        child: Text(
                                          formattedTime, // Display the formatted datetime
                                          style: TextStyle(fontSize: 10),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            borderData: FlBorderData(
                              show: false, // Hilangkan border
                            ),
                            lineBarsData:
                                _buildChartData1(data), // Data untuk grafik 1
                          )),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Card for Chart 2: Room Temperature and Room Humidity
                Card(
                  elevation: 4,
                  shadowColor: Colors.black26,
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
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.3,
                          child: LineChart(LineChartData(
                            gridData:
                                const FlGridData(show: false), // Hilangkan grid
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 40, // Beri ruang untuk label Y
                                  interval:
                                      10, // Sesuaikan interval Y dengan data
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      value
                                          .toInt()
                                          .toString(), // Menampilkan nilai sebagai integer
                                      style: const TextStyle(fontSize: 10),
                                      textAlign: TextAlign.center,
                                    );
                                  },
                                ),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(
                                    showTitles: false), // Hilangkan di kanan
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(
                                    showTitles: false), // Hilangkan di atas
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true, // Show labels on the X-axis
                                  reservedSize:
                                      60, // Ensure there's enough space for the labels
                                  getTitlesWidget: (value, meta) {
                                    final timestamp = value
                                        .toInt(); // Convert timestamp to int
                                    String formattedTime = formatDatetime(
                                        timestamp); // Format the timestamp

                                    return Transform.translate(
                                      offset: Offset(0,
                                          10), // Adjust the label position vertically
                                      child: Transform.rotate(
                                        angle:
                                            -0.5, // Rotate the label to make it readable
                                        child: Text(
                                          formattedTime, // Display the formatted datetime
                                          style: TextStyle(fontSize: 10),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            borderData: FlBorderData(
                              show: false, // Hilangkan border
                            ),
                            lineBarsData:
                                _buildChartData2(data), // Data untuk grafik 2
                          )),
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
