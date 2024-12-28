import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class AddDataScreen extends StatefulWidget {
  final String userId;

  const AddDataScreen({super.key, required this.userId});

  @override
  _AddDataScreenState createState() => _AddDataScreenState();
}

class _AddDataScreenState extends State<AddDataScreen> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController bodyTempController = TextEditingController();
  final TextEditingController heartRateController = TextEditingController();
  final TextEditingController roomHumiController = TextEditingController();
  final TextEditingController roomTempController = TextEditingController();
  final TextEditingController spo2Controller = TextEditingController();

  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  void _submitData() async {
    if (_formKey.currentState!.validate() &&
        _fbKey.currentState!.saveAndValidate()) {
      final String datetime =
          _fbKey.currentState!.fields['datetime']!.value.toString();
      final double bodyTemp = double.parse(bodyTempController.text);
      final double heartRate = double.parse(heartRateController.text);
      final double roomHumi = double.parse(roomHumiController.text);
      final double roomTemp = double.parse(roomTempController.text);
      final double spo2 = double.parse(spo2Controller.text);

      // Creating data to be stored in Firebase
      final Map<String, dynamic> data = {
        'Datetime': datetime,
        'Body Temp': bodyTemp,
        'Heart Rate': heartRate,
        'Room Humi': roomHumi,
        'Room Temp': roomTemp,
        'SpO2': spo2,
        'UID': widget.userId,
      };

      try {
        // Push data to Firebase under Checks node
        await _dbRef.child('Checks').push().set(data);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data added successfully!')),
        );

        // Navigate back to the previous screen
        Navigator.pop(context);

        // Clear input fields
        bodyTempController.clear();
        heartRateController.clear();
        roomHumiController.clear();
        roomTempController.clear();
        spo2Controller.clear();
      } catch (e) {
        // Show error message if data fails to be added
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
                      'Add Data',
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
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a date and time';
                        }
                        return null;
                      },
                      inputType: InputType.both,
                    ),
                    const SizedBox(height: 16),
                    // Heart Rate Field
                    TextFormField(
                      controller: heartRateController,
                      decoration: InputDecoration(
                        labelText: 'Heart Rate (bpm)',
                        prefixIcon: const Icon(FontAwesomeIcons.heartPulse),
                        fillColor: const Color(0xffF1F0F5),
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
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
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
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
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
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
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
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
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
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
                        onPressed: _submitData,
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
