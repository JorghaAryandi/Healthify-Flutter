import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:healthify_pab/screens/profile_screen.dart';
import '../Auth/login.dart';
import 'chart_screen.dart';
import 'history_screen.dart';
import 'home_screen.dart';
import 'measure_screen.dart';
import 'info_screen.dart';
import 'profile_screen.dart';
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
      MeasureScreen(userData: widget.userData),
      ChartScreen(userId: widget.userData.userUID),
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
        leading: Image.asset(
          'assets/images/healthify_logo.png',
          width: 40,
          height: 40,
        ), // Left logo
        title: const Text(
          'Healthify',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black, // Title color
          ),
        ),
        backgroundColor: Colors.white, // AppBar color
        elevation: 0, // Remove shadow
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.account_circle, // Profile icon
              color: Colors.black,
            ),
            onSelected: (value) {
              if (value == 'profile') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(
                      userId: widget.userData.userUID,
                    ),
                  ),
                ); // Navigate to profile
              } else if (value == 'logout') {
                _showLogoutDialog(); // Show logout confirmation
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person, color: Colors.black),
                    SizedBox(width: 10),
                    Text('Profile'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.black),
                    SizedBox(width: 10),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
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
            _buildNavItem(Icons.home, 'Home', 0),
            _buildNavItem(Icons.timeline, 'Tracker', 1),
            _buildNavItem(
                Icons.touch_app, 'Measure', 2), // Ganti dengan ikon tangan
            _buildNavItem(Icons.timeline, 'Chart', 3),
            _buildNavItem(Icons.info, 'Info', 4),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(
      IconData icon, String label, int index) {
    return BottomNavigationBarItem(
      icon: Container(
        decoration: _currentIndex == index
            ? BoxDecoration(
                color: Color(0xff1e4064), // Warna latar aktif
                borderRadius: BorderRadius.circular(10),
              )
            : null,
        padding: const EdgeInsets.all(8.0),
        child: Icon(
          icon,
          size: 24,
          color: _currentIndex == index ? Colors.white : Colors.grey,
        ),
      ),
      label: label,
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
