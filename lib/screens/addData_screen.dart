import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';

class AddDataScreen extends StatefulWidget {
  final String userId; // UID pengguna untuk fetch data dari Firebase
  final Function onAddSuccess;

  const AddDataScreen(
      {super.key, required this.userId, required this.onAddSuccess});

  @override
  _AddDataScreenState createState() => _AddDataScreenState();
}

class _AddDataScreenState extends State<AddDataScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController datetimeController;
  late TextEditingController heartRateController;
  late TextEditingController bodyTempController;
  late TextEditingController roomHumiController;
  late TextEditingController roomTempController;
  late TextEditingController spo2Controller;

  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    // Initialize controllers
    datetimeController = TextEditingController();
    heartRateController = TextEditingController();
    bodyTempController = TextEditingController();
    roomHumiController = TextEditingController();
    roomTempController = TextEditingController();
    spo2Controller = TextEditingController();
  }

  void _addData() async {
    if (_formKey.currentState!.validate()) {
      // Format the selected DateTime using DateFormat
      String formattedDatetime = '';
      if (datetimeController.text.isNotEmpty) {
        DateTime selectedDatetime = DateTime.parse(datetimeController.text);
        formattedDatetime =
            DateFormat('yyyy-MM-dd HH:mm:ss').format(selectedDatetime);
      } else {
        // Fallback to current datetime if no date is selected
        formattedDatetime =
            DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      }

      // Parse the input fields to ensure no null values are passed
      double parseToDouble(String? text) {
        return text != null && text.isNotEmpty
            ? double.tryParse(text) ?? 0.0
            : 0.0;
      }

      final newData = {
        'Datetime': formattedDatetime,
        'Heart Rate': parseToDouble(heartRateController.text),
        'Body Temp': parseToDouble(bodyTempController.text),
        'Room Humi': parseToDouble(roomHumiController.text),
        'Room Temp': parseToDouble(roomTempController.text),
        'SpO2': parseToDouble(spo2Controller.text),
        'UID': widget.userId,
      };

      try {
        // Add the new data to Firebase
        await _dbRef.child('Checks').push().set(newData);

        // Call the onAddSuccess callback to refresh the data on the previous screen
        widget.onAddSuccess();

        // Navigate back to the previous screen
        Navigator.pop(context);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data added successfully!')),
        );
      } catch (e) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to add data. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Add Data'),
        backgroundColor: Colors.green.shade50,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          color: Colors.green.shade50,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Add New Data',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.teal,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // DateTime Picker (flutter_form_builder)
                    FormBuilderDateTimePicker(
                      name: 'datetime',
                      decoration: InputDecoration(
                        labelText: 'Select Date and Time',
                        prefixIcon: const Icon(Icons.calendar_today),
                        fillColor: const Color(0xffF1F0F5),
                        filled: true,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: Colors.blue),
                        ),
                      ),
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a date and time';
                        }
                        return null;
                      },
                      inputType: InputType.both,
                      onChanged: (value) {
                        datetimeController.text =
                            value != null ? value.toString() : '';
                      },
                    ),
                    const SizedBox(height: 16),
                    // Heart Rate Field
                    TextFormField(
                      controller: heartRateController,
                      decoration: InputDecoration(
                        labelText: 'Heart Rate (bpm)',
                        prefixIcon: const Icon(FontAwesomeIcons.heart),
                        fillColor: const Color(0xffF1F0F5),
                        filled: true,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: Colors.blue),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'\d*\.?\d*')),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter heart rate';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // SpO2 Field
                    TextFormField(
                      controller: spo2Controller,
                      decoration: InputDecoration(
                        labelText: 'SpO2 (%)',
                        prefixIcon: const Icon(FontAwesomeIcons.lungs),
                        fillColor: const Color(0xffF1F0F5),
                        filled: true,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: Colors.blue),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'\d*\.?\d*')),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter SpO2';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Body Temperature Field
                    TextFormField(
                      controller: bodyTempController,
                      decoration: InputDecoration(
                        labelText: 'Body Temp (°C)',
                        prefixIcon:
                            const Icon(FontAwesomeIcons.temperatureHigh),
                        fillColor: const Color(0xffF1F0F5),
                        filled: true,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: Colors.blue),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'\d*\.?\d*')),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter body temperature';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Room Temperature Field
                    TextFormField(
                      controller: roomTempController,
                      decoration: InputDecoration(
                        labelText: 'Room Temp (°C)',
                        prefixIcon: const Icon(FontAwesomeIcons.house),
                        fillColor: const Color(0xffF1F0F5),
                        filled: true,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: Colors.blue),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'\d*\.?\d*')),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter room temperature';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Room Humidity Field
                    TextFormField(
                      controller: roomHumiController,
                      decoration: InputDecoration(
                        labelText: 'Room Humidity (%)',
                        prefixIcon: const Icon(FontAwesomeIcons.droplet),
                        fillColor: const Color(0xffF1F0F5),
                        filled: true,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: Colors.blue),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'\d*\.?\d*')),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter room humidity';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Submit Button
                    Center(
                      child: ElevatedButton(
                        onPressed: _addData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade50,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          'Add Data',
                          style: TextStyle(
                            color: Colors.teal,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
