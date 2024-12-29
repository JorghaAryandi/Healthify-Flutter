import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_svg/svg.dart';

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
            // "Datetime": "29-03-2004 19:00:00",
            // "UID": "12345",
            // "Heart Rate": 75.0,
            // "Body Temp": 36.6,
            // "Room Humi": 45.0,
            // "Room Temp": 22.0,
            // "SpO2": 98.0,
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
          :
          // body: SingleChildScrollView(
          SingleChildScrollView(
              child: Padding(
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
                    const SizedBox(height: 30),
                    // Measurement Data Card
                    Material(
                      elevation: 3, // Menambahkan elevation
                      borderRadius: BorderRadius.circular(
                          12), // Menyesuaikan border radius
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xffdeffda),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  children: [
                                    const Text(
                                      "Health Data",
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xff1e4064),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    const FaIcon(FontAwesomeIcons.heartPulse,
                                        size: 45, color: Color(0xff1e4064)),
                                    const SizedBox(height: 8),
                                    Text(
                                      "${latestHealthData["Heart Rate"] != null ? (latestHealthData["Heart Rate"] as num).toStringAsFixed(1) : "N/A"} BPM",
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Text(
                                      "Heart Rate",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color.fromARGB(255, 36, 36, 36),
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Transform.translate(
                                      offset: const Offset(
                                          0.0, -50.0), // Dorong elemen keluar
                                      child: SvgPicture.asset(
                                        'assets/svg/body.svg',
                                        height: 120.0,
                                        width: 120.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment
                                  .spaceAround, // Mengatur jarak rata
                              children: [
                                Column(
                                  children: [
                                    const FaIcon(FontAwesomeIcons.lungs,
                                        size: 45, color: Color(0xff1e4064)),
                                    const SizedBox(height: 8),
                                    Text(
                                      "${latestHealthData["SpO2"] != null ? (latestHealthData["SpO2"] as num).toStringAsFixed(1) : "N/A"} %",
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Text(
                                      "Blood Oxygen Saturation",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color.fromARGB(255, 36, 36, 36),
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    const FaIcon(
                                        FontAwesomeIcons.temperatureHigh,
                                        size: 45,
                                        color: Color(0xff1e4064)),
                                    const SizedBox(height: 8),
                                    Text(
                                      "${latestHealthData["Body Temp"] != null ? (latestHealthData["Body Temp"] as num).toStringAsFixed(1) : "N/A"} °C",
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Text(
                                      "Body Temp",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color.fromARGB(255, 36, 36, 36),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 38),

                    // Room Data Card
                    Material(
                      elevation: 3, // Menambahkan elevation
                      borderRadius: BorderRadius.circular(
                          12), // Menyesuaikan border radius
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                Column(
                                  children: [
                                    Transform.translate(
                                      offset: const Offset(
                                          0.0, 30.0), // Dorong elemen keluar
                                      child: const Text(
                                        "Room \nCondition",
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xff1e4064),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                // const SizedBox(height: 20),
                                Column(
                                  children: [
                                    Transform.translate(
                                      offset: const Offset(
                                          0.0, 50.0), // Dorong elemen keluar
                                      child: SvgPicture.asset(
                                        'assets/svg/room.svg',
                                        height: 180.0,
                                        width: 180.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Column(
                              // mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  children: [
                                    const FaIcon(FontAwesomeIcons.house,
                                        size: 45, color: Color(0xff1e4064)),
                                    const SizedBox(height: 8),
                                    Text(
                                      "${latestHealthData["Room Temp"] != null ? (latestHealthData["Room Temp"] as num).toStringAsFixed(1) : "N/A"} °C",
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Text(
                                      "Room Temperature",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color.fromARGB(255, 36, 36, 36),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Column(
                                  children: [
                                    const FaIcon(FontAwesomeIcons.droplet,
                                        size: 45, color: Color(0xff1e4064)),
                                    const SizedBox(height: 8),
                                    Text(
                                      "${latestHealthData["Room Humi"] != null ? (latestHealthData["Room Humi"] as num).toStringAsFixed(1) : "N/A"} %",
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Text(
                                      "Room Humidity",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color.fromARGB(255, 36, 36, 36),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 38),

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: const Row(
                        children: [
                          Text(
                            'Heart Rate: ',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'NORMAL',
                            style: TextStyle(fontSize: 16, color: Colors.green),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 38),
                  ],
                ),
              ),
            ),
    );
  }
}
