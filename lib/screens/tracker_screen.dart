import 'package:flutter/material.dart';

class TrackerScreen extends StatelessWidget {
  final List<Map<String, String>> historyData = [
    {
      "No": "1",
      "Heart Rate": "119.6 BPM",
      "Blood Oxygen": "93 %",
      "Body Temp": "34.39 °C",
      "Room Temp": "28.2 °C",
      "Room Humidity": "70 %",
      "Datetime": "2024-12-22 19:23:49",
    },
    {
      "No": "2",
      "Heart Rate": "70.8 BPM",
      "Blood Oxygen": "99 %",
      "Body Temp": "34.09 °C",
      "Room Temp": "27.8 °C",
      "Room Humidity": "70 %",
      "Datetime": "2024-12-22 19:39:13",
    },
    {
      "No": "3",
      "Heart Rate": "86 BPM",
      "Blood Oxygen": "99.8 %",
      "Body Temp": "34.83 °C",
      "Room Temp": "27.6 °C",
      "Room Humidity": "70 %",
      "Datetime": "2024-12-22 19:50:40",
    },
    {
      "No": "4",
      "Heart Rate": "76.8 BPM",
      "Blood Oxygen": "99.6 %",
      "Body Temp": "34.67 °C",
      "Room Temp": "26.1 °C",
      "Room Humidity": "60 %",
      "Datetime": "2024-12-23 09:34:09",
    },
    {
      "No": "5",
      "Heart Rate": "112.2 BPM",
      "Blood Oxygen": "99.6 %",
      "Body Temp": "34.07 °C",
      "Room Temp": "25.8 °C",
      "Room Humidity": "55 %",
      "Datetime": "2024-12-23 14:22:37",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tracker"),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text("No")),
            DataColumn(label: Text("Heart Rate")),
            DataColumn(label: Text("Blood Oxygen")),
            DataColumn(label: Text("Body Temp")),
            DataColumn(label: Text("Room Temp")),
            DataColumn(label: Text("Room Humidity")),
            DataColumn(label: Text("Datetime")),
          ],
          rows: historyData
              .map(
                (data) => DataRow(
                  cells: [
                    DataCell(Text(data["No"]!)),
                    DataCell(Text(data["Heart Rate"]!)),
                    DataCell(Text(data["Blood Oxygen"]!)),
                    DataCell(Text(data["Body Temp"]!)),
                    DataCell(Text(data["Room Temp"]!)),
                    DataCell(Text(data["Room Humidity"]!)),
                    DataCell(Text(data["Datetime"]!)),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
