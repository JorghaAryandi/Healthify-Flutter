import 'package:flutter/material.dart';
import 'Auth/login.dart'; // Import the Login Screen
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      //Web
      // options: const FirebaseOptions(
      //   apiKey: 'AIzaSyCsw6q3UuBIVuRIRopZg-hRzatNsmrDeMk',
      //   authDomain: 'healthify-2f05e.firebaseapp.com',
      //   databaseURL:
      //       'https://healthify-2f05e-default-rtdb.asia-southeast1.firebasedatabase.app',
      //   projectId: 'healthify-2f05e',
      //   storageBucket: 'healthify-2f05e.firebasestorage.app',
      //   messagingSenderId: '266385184151',
      //   appId: '1:266385184151:web:77b340f3c5e7172aaee0d2',
      // ),

      //Android
      options: const FirebaseOptions(
        apiKey: 'AIzaSyD4wzC6NFxMhg5yxwxCejn-VaqoP5SeFS4',
        authDomain: 'healthify-2f05e.firebaseapp.com',
        databaseURL:
            'https://healthify-2f05e-default-rtdb.asia-southeast1.firebasedatabase.app',
        projectId: 'healthify-2f05e',
        storageBucket: 'healthify-2f05e.firebasestorage.app',
        messagingSenderId: '266385184151',
        appId: '1:266385184151:web:77b340f3c5e7172aaee0d2',
      ),
    );
  } catch (e) {
    print('Failed to initialize Firebase: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Healthify',
      debugShowCheckedModeBanner: false,
      home: LoginScreen(), // Set LoginScreen as the home screen
      theme: ThemeData(
        fontFamily: 'Poppins', // Set Poppins as the default font
        snackBarTheme: const SnackBarThemeData(
          backgroundColor:
              Color.fromARGB(255, 0, 140, 255), // Warna latar belakang SnackBar
          contentTextStyle: TextStyle(
            color: Colors.white, // Warna teks pada SnackBar
            fontSize: 16, // Ukuran font teks
          ),
        ),
      ),
    );
  }
}
