import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomeScreen extends StatefulWidget {
  final String userId; // UID pengguna untuk fetch data dari Firebase

  const HomeScreen({super.key, required this.userId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  Map<String, dynamic> latestHealthData = {};

  @override
  void initState() {
    super.initState();
    fetchLatestHealthData();
  }

  void fetchLatestHealthData() {
    final checksRef = _dbRef
        .child('Checks')
        .orderByChild('UID')
        .equalTo(widget.userId)
        .limitToLast(1);

    checksRef.onValue.listen((event) {
      if (event.snapshot.exists) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        final latestKey = data.keys.first;

        // Konversi nilai sesuai tipe data
        setState(() {
          latestHealthData = {
            "Datetime": data[latestKey]["Datetime"] ?? "N/A",
            "UID": data[latestKey]["UID"] ?? "N/A",
            "Heart Rate": (data[latestKey]["Heart Rate"] ?? 0).toDouble(),
            "Body Temp": (data[latestKey]["Body Temp"] ?? 0).toDouble(),
            "Room Humi": (data[latestKey]["Room Humi"] ?? 0).toDouble(),
            "Room Temp": (data[latestKey]["Room Temp"] ?? 0).toDouble(),
            "SpO2": (data[latestKey]["SpO2"] ?? 0).toDouble(),
          };
        });
      } else {
        setState(() {
          latestHealthData = {}; // No data found
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: latestHealthData.isEmpty
          ? const Center(
              child: Text(
                'No Data Available',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Date and Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text(
                        'Last Updated:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          latestHealthData["Datetime"] ?? "N/A",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Measurement Data Card
                  _buildDataCard(
                    color: Colors.green.shade50,
                    title: 'Health Data',
                    data: [
                      {
                        "label": "Heart Rate",
                        "value":
                            "${latestHealthData["Heart Rate"]?.toStringAsFixed(1) ?? "N/A"} BPM",
                        "icon": FontAwesomeIcons.heartPulse,
                      },
                      {
                        "label": "Blood Oxygen Saturation",
                        "value":
                            "${latestHealthData["SpO2"]?.toStringAsFixed(1) ?? "N/A"} %",
                        "icon": FontAwesomeIcons.lungs,
                      },
                      {
                        "label": "Body Temp.",
                        "value":
                            "${latestHealthData["Body Temp"]?.toStringAsFixed(1) ?? "N/A"} °C",
                        "icon": FontAwesomeIcons.temperatureHigh,
                      },
                    ],
                  ),

                  const SizedBox(height: 20),
                  // Room Data Card
                  _buildDataCard(
                    color: Colors.blue.shade50,
                    title: 'Room Data',
                    data: [
                      {
                        "label": "Room Temperatue",
                        "value":
                            "${latestHealthData["Room Temp"]?.toStringAsFixed(1) ?? "N/A"} °C",
                        "icon": FontAwesomeIcons.house,
                      },
                      {
                        "label": "Room Humidity",
                        "value":
                            "${latestHealthData["Room Humi"]?.toStringAsFixed(1) ?? "N/A"} %",
                        "icon": FontAwesomeIcons.droplet,
                      },
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDataCard({
    required Color color,
    required String title,
    required List<Map> data,
  }) {
    return Material(
      elevation: 4, // Add elevation here
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: data.map((item) {
                return Column(
                  children: [
                    FaIcon(item["icon"] as IconData,
                        size: 45, color: Colors.blue),
                    const SizedBox(height: 8),
                    Text(
                      item["value"]!,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      item["label"]!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color.fromARGB(255, 36, 36, 36),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
