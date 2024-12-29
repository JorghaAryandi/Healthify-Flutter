import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:healthify_pab/Auth/login.dart';
import 'package:healthify_pab/screens/aboutus_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;

  const ProfileScreen({super.key, required this.userId});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  // Fetch user data from Firebase
  void fetchUserData() async {
    try {
      final userRef = _dbRef.child('Users/${widget.userId}');
      final snapshot = await userRef.get();

      if (snapshot.exists) {
        final userData = snapshot.value as Map<dynamic, dynamic>;

        setState(() {
          nameController.text = userData['name'] ?? '';
          emailController.text = userData['email'] ?? '';
          genderController.text = userData['gender'] ?? '';
          ageController.text = userData['age']?.toString() ?? '';
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User data not found.")),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching data: $e")),
      );
    }
  }

  // Save user data to Firebase
  void saveUserData() async {
    try {
      final userRef = _dbRef.child('Users/${widget.userId}');
      await userRef.update({
        'name': nameController.text,
        'email': emailController.text,
        'gender': genderController.text,
        'age': int.tryParse(ageController.text) ?? 0,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating profile: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context); // Aksi untuk kembali ke halaman sebelumnya
          },
          child: Image.asset(
            'assets/images/healthify_logo.png',
            width: 40,
            height: 40,
          ),
        ),
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
                      userId: widget.userId,
                    ),
                  ),
                );
              } else if (value == 'logout') {
                _showLogoutDialog();
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
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    // Avatar dan Detail Profil
                    Row(
                      children: [
                        // Avatar
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey.shade200,
                          child: Image.asset(
                            'assets/images/default_avatar.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Detail Profil
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nameController.text,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              genderController.text,
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.grey),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Age ${ageController.text}",
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    // Edit Profile Form
                    const Text(
                      "Edit Profile",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField("Name", nameController),
                    const SizedBox(height: 16),
                    _buildTextField("Email", emailController),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                            child: _buildTextField("Gender", genderController)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildTextField("Age", ageController)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTextField("Password", passwordController,
                        obscureText: true),
                    const SizedBox(height: 20),
                    // Save Button
                    ElevatedButton(
                      onPressed: saveUserData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff1e4064),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Save",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 30),

                    Card(
                      elevation: 4,
                      color: Color(0xff1e4064),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 20, horizontal: 16),
                        child: Column(
                          children: [
                            ListTile(
                              leading:
                                  const Icon(Icons.info, color: Colors.white),
                              title: const Text(
                                "About Us",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              onTap: () {
                                // Logic untuk navigasi ke halaman About Us
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AboutUsScreen(),
                                  ),
                                );
                              },
                            ),
                            const Divider(),
                            ListTile(
                              leading:
                                  const Icon(Icons.logout, color: Colors.white),
                              title: const Text(
                                "Logout",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              onTap: () {
                                _showLogoutDialog();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

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
                Navigator.pushReplacement(
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

  // Helper untuk membuat TextField
  Widget _buildTextField(String label, TextEditingController controller,
      {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
