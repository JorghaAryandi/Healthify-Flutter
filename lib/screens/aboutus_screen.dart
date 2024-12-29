import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "About Us",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Image.asset(
                  'assets/images/healthify_logo.png',
                  width: 400,
                  height: 400,
                ),
              ),
              const SizedBox(height: 20),
              // Card untuk deskripsi Healthify
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: const Color(0xffdeffda), // Warna latar hijau muda
                  borderRadius: BorderRadius.circular(
                      12), // Radius untuk membulatkan sudut
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "HEALTHIFY",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "adalah aplikasi pintar yang dirancang untuk membantu Anda memantau kesehatan dengan mudah dan efektif. "
                      "Dengan teknologi terkini, aplikasi ini memberikan pembacaan akurat terkait:",
                      style: TextStyle(fontSize: 14, color: Colors.black),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "• detak jantung (Heart Rate),\n"
                      "• kadar oksigen dalam darah (Blood Oxygen),\n"
                      "• suhu tubuh (Body Temperature),\n"
                      "• serta suhu dan kelembaban ruangan (Room Humidity).",
                      style: TextStyle(fontSize: 14, color: Colors.black),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "HEALTHIFY mendukung Anda dalam menjaga kesehatan dengan alat pemantauan yang praktis dan antarmuka yang intuitif. "
                      "Jadikan HEALTHIFY sebagai partner kesehatan terpercaya Anda!",
                      style: TextStyle(fontSize: 14, color: Colors.black),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Footer text
              const Text(
                "EMPOWERING YOU TO LIVE HEALTHIER",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
