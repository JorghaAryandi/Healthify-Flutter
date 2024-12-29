import 'package:flutter/material.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InfoBlock(
              title: "Heart Rate",
              content:
                  "Heart rate, atau detak jantung, adalah jumlah detak jantung per menit (bpm). Normalnya, heart rate orang dewasa berada di kisaran 60–100 bpm saat istirahat.",
            ),
            SizedBox(height: 16),
            InfoBlock(
              title: "Saturasi Oksigen (SpO2)",
              content:
                  "Saturasi oksigen menunjukkan persentase oksigen dalam darah Anda. Nilai normal biasanya berada di atas 95%. Jika kurang, itu bisa menjadi tanda hipoksemia.",
            ),
            SizedBox(height: 16),
            InfoBlock(
              title: "Suhu Tubuh Normal",
              content:
                  "Suhu tubuh normal manusia berkisar antara 36.5°C hingga 37.5°C. Jika suhu tubuh lebih dari 37.5°C, Anda mungkin mengalami demam.",
            ),
            SizedBox(height: 16),
            InfoBlock(
              title: "Suhu dan Kelembaban Ruangan",
              content:
                  "Suhu ruangan yang ideal berkisar antara 20–24°C, dengan kelembaban sekitar 40–60%. Lingkungan ini nyaman dan mendukung kesehatan pernapasan.",
            ),
          ],
        ),
      ),
    );
  }
}

class InfoBlock extends StatelessWidget {
  final String title;
  final String content;

  const InfoBlock({
    Key? key,
    required this.title,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
