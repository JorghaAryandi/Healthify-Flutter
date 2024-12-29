import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'main_screen.dart';
import '../stores/user.dart';

final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

class MeasureScreen extends StatelessWidget {
  final UserData userData;

  const MeasureScreen({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MeasureStart(userData: userData),
    );
  }
}

class MeasureStart extends StatelessWidget {
  final UserData userData;

  const MeasureStart({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Heart Icon and Start Text
          GestureDetector(
            onTap: () async {
              final sessionRef = _dbRef.child('Sessions');
              final sessionSnapshot = await sessionRef.get();

              // If any session data exists, show a message and do not proceed
              if (sessionSnapshot.exists && sessionSnapshot.value != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Session Already Active!")),
                );
              } else {
                // If no session exists, navigate to MeasureProcessScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        MeasureProcessScreen(userData: userData),
                  ),
                );
              }
            },
            child: Column(
              children: [
                Container(
                  height: 150,
                  width: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red.shade100,
                  ),
                  child: const Icon(
                    Icons.favorite,
                    size: 80,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'START\nTap to Measure',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class MeasureProcessScreen extends StatefulWidget {
  final UserData userData;

  const MeasureProcessScreen({super.key, required this.userData});

  @override
  State<MeasureProcessScreen> createState() => _MeasureProcessScreenState();
}

class _MeasureProcessScreenState extends State<MeasureProcessScreen> {
  bool isMeasureSuccess = false;

  @override
  void initState() {
    super.initState();
    saveSessionData();
    listenForNewData();
  }

  // Method to save session data
  Future<void> saveSessionData() async {
    try {
      final userRef = _dbRef.child('Users/${widget.userData.userUID}');
      final snapshot = await userRef.get();

      if (snapshot.exists) {
        final userData = snapshot.value as Map<dynamic, dynamic>;
        final userName = userData['name'] ?? 'Unknown';
        final userEmail = userData['email'] ?? 'Unknown';

        final sessionRef = _dbRef.child('Sessions/${widget.userData.userUID}');
        await sessionRef.set({
          'name': userName,
          'email': userEmail,
          'loginTime': DateTime.now().toIso8601String(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Start Measure!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User data not found!")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving session data: $e")),
      );
    }
  }

  void listenForNewData() {
    final checksRef = _dbRef
        .child('Checks')
        .orderByChild('UID')
        .equalTo(widget.userData.userUID);

    // Listen for new child added
    checksRef.onChildAdded.listen((event) async {
      if (event.snapshot.exists) {
        // Get the check data from the snapshot
        final checkData = event.snapshot.value as Map<dynamic, dynamic>;

        // Retrieve the necessary fields from the new entry
        final timestamp =
            checkData['Datetime']; // Assuming Datetime is a string
        final bodyTemp = checkData['Body Temp'];
        final heartRate = checkData['Heart Rate'];
        final roomHumi = checkData['Room Humi'];
        final roomTemp = checkData['Room Temp'];
        final spO2 = checkData['SpO2'];

        // Check if this data is the latest (comparing the timestamp or any other criteria)
        if (isLatestData(timestamp)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("New data has been measured.")),
          );

          setState(() {
            isMeasureSuccess = true; // Mark success
          });

          // Optionally, print or display the latest data
          print(
              "New Data: $bodyTemp, $heartRate, $roomHumi, $roomTemp, $spO2 at $timestamp");
        }
      }
    });
  }

// Method to compare if the timestamp of the data is within 5 minutes of the current time
  bool isLatestData(String timestamp) {
    try {
      // Parse the timestamp string into a DateTime object
      final dataTimestamp = DateTime.parse(timestamp);
      final currentTimestamp = DateTime.now();

      // Calculate the difference in minutes between the current time and the data timestamp
      final difference = currentTimestamp.difference(dataTimestamp).inMinutes;

      // Return true if the difference is within 2 minutes
      return difference.abs() <= 2;
    } catch (e) {
      // Handle parsing errors
      print("Error parsing timestamp: $e");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PopScope(
        canPop: true,
        onPopInvoked: (bool didPop) {
          // Perform actions when a pop attempt is made
          clearSession();
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Text(
                isMeasureSuccess
                    ? "You have successfully measured."
                    : "Processing Data...",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (isMeasureSuccess) {
                  await clearSession();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            MainScreen(userData: widget.userData)),
                  );
                } else {
                  await clearSession();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isMeasureSuccess
                    ? Colors.green.shade50
                    : Colors.blue.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                isMeasureSuccess ? "Done" : "Cancel",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isMeasureSuccess ? Colors.green : Colors.blue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Method to cancel session and delete from Firebase
  Future<void> clearSession() async {
    try {
      // Reference to the user in Firebase
      final userRef = _dbRef.child('Users/${widget.userData.userUID}');
      final snapshot = await userRef.get();

      // Check if user exists in Firebase
      if (snapshot.exists) {
        // Reference to the session in Firebase
        final sessionRef = _dbRef.child('Sessions/${widget.userData.userUID}');

        // Remove the session data from Firebase
        await sessionRef.remove();

        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(content: Text("Canceled")),
        // );

        // Navigate back to the previous screen
        Navigator.pop(context);
      } else {
        // User data not found in Firebase
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User data not found.")),
        );
      }
    } catch (e) {
      // Handle any errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error canceling session: $e")),
      );
    }
  }
}
