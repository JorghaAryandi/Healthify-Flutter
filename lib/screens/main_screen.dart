import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Auth/login.dart';
import 'chart_screen.dart';
import 'history_screen.dart';
import 'home_screen.dart';
import 'measure_screen.dart';
import 'info_screen.dart';
import '../stores/user.dart';

class MainScreen extends StatefulWidget {
  final UserData userData;

  const MainScreen({super.key, required this.userData});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(userId: widget.userData.userUID),
      HistoryScreen(userId: widget.userData.userUID),
      ChartScreen(userId: widget.userData.userUID),
      const MeasureScreen(),
      const InfoScreen(),
    ];
  }

  // Function to show logout confirmation dialog
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Log Out'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                FirebaseAuth.instance.signOut(); // Perform sign out
                Navigator.of(context).pop(); // Close the dialog
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              child: const Text('Log Out'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Image.asset('assets/images/healthify_logo.png',
            width: 40, height: 40), // Left logo
        title: const Text(
          'Healthify',
          style: TextStyle(fontWeight: FontWeight.bold), // Bold title
        ),
        backgroundColor: Colors.transparent, // Transparent AppBar
        elevation: 0, // Remove shadow
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _showLogoutDialog, // Show logout confirmation
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors
              .blue.shade50, // Background color for the BottomNavigationBar
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(
                20), // Rounded corners on the top-left and top-right
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: _buildIcon(Icons.dashboard),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: _buildIcon(Icons.history),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: _buildIcon(Icons.timeline),
              label: 'Chart',
            ),
            BottomNavigationBarItem(
              icon: _buildIcon(Icons.favorite),
              label: 'Measure',
            ),
            BottomNavigationBarItem(
              icon: _buildIcon(Icons.info),
              label: 'Info',
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to enlarge icons when clicked
  Widget _buildIcon(IconData icon) {
    return Icon(
      icon,
      size: 30, // Default size
    );
  }
}
