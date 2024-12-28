import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ViewDataScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const ViewDataScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Data'),
      ),
      backgroundColor: Colors.white,
      body: data.isEmpty
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Last Update Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text(
                        'Datetime:',
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
                          data["datetime"] ?? "N/A",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Health Data Card
                  _buildDataCard(
                    color: Colors.green.shade50,
                    title: 'Health Data',
                    data: [
                      {
                        "label": "Heart Rate",
                        "value": "${data["heart_rate"] ?? "N/A"} BPM",
                        "icon": FontAwesomeIcons.heartPulse,
                      },
                      {
                        "label": "Blood Oxygen Saturation",
                        "value": "${data["spo2"] ?? "N/A"} %",
                        "icon": FontAwesomeIcons.lungs,
                      },
                      {
                        "label": "Body Temp.",
                        "value": "${data["body_temp"] ?? "N/A"} °C",
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
                        "label": "Room Temperature",
                        "value": "${data["room_temp"] ?? "N/A"} °C",
                        "icon": FontAwesomeIcons.house,
                      },
                      {
                        "label": "Room Humidity",
                        "value": "${data["room_humi"] ?? "N/A"} %",
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
