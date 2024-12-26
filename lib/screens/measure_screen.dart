import 'package:flutter/material.dart';

class MeasureScreen extends StatelessWidget {
  const MeasureScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Measure'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: MeasureStart(),
    );
  }
}

class MeasureStart extends StatelessWidget {
  const MeasureStart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Heart Icon and Start Text
          GestureDetector(
            onTap: () {
              // Navigate to Measure Result
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MeasureResult(),
                ),
              );
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
          // Last Measurements
          const Text(
            'Last Measurements',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            '85 BPM',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const Text(
            '2024, Nov 25 - 12:00',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class MeasureResult extends StatelessWidget {
  const MeasureResult({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Measure Result'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date and Time
            const Text(
              'Nov 25 12:00',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            // Measurement Data
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                _MeasurementData(label: 'Heart Rate', value: '85 bpm'),
                _MeasurementData(label: 'Blood Oxygen', value: '98 % SpO2'),
                _MeasurementData(label: 'Body Temp.', value: '36 ° Celsius'),
              ],
            ),
            const SizedBox(height: 20),
            // Gender and Age
            Row(
              children: [
                _Tag(label: 'Female'),
                const SizedBox(width: 10),
                _Tag(label: 'Age 20'),
              ],
            ),
            const SizedBox(height: 10),
            const _Tag(label: 'Resting'),
            const SizedBox(height: 20),
            // Indicator Bars
            const _Indicator(
              label: 'Heart Rate',
              value: 'NORMAL',
              percentage: 0.6,
              color: Colors.green,
            ),
            const _Indicator(
              label: 'Blood Oxygen',
              value: 'GOOD',
              percentage: 0.9,
              color: Colors.blue,
            ),
            const _Indicator(
              label: 'Body Temperature',
              value: 'NORMAL',
              percentage: 0.5,
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }
}

class _MeasurementData extends StatelessWidget {
  final String label;
  final String value;

  const _MeasurementData({
    Key? key,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;

  const _Tag({Key? key, required this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.blue),
      ),
    );
  }
}

class _Indicator extends StatelessWidget {
  final String label;
  final String value;
  final double percentage;
  final Color color;

  const _Indicator({
    Key? key,
    required this.label,
    required this.value,
    required this.percentage,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            Expanded(
              flex: (percentage * 100).toInt(),
              child: Container(
                height: 10,
                color: color,
              ),
            ),
            Expanded(
              flex: 100 - (percentage * 100).toInt(),
              child: Container(
                height: 10,
                color: Colors.grey.shade300,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: color,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
