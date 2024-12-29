import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';

class EditDataScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  final Function onUpdateSuccess; // Callback function

  const EditDataScreen(
      {super.key, required this.data, required this.onUpdateSuccess});

  @override
  _EditDataScreenState createState() => _EditDataScreenState();
}

class _EditDataScreenState extends State<EditDataScreen> {
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
    // Initialize controllers with data passed from the parent widget
    datetimeController = TextEditingController(text: widget.data['datetime']);
    heartRateController =
        TextEditingController(text: widget.data['heart_rate'].toString());
    bodyTempController =
        TextEditingController(text: widget.data['body_temp'].toString());
    roomHumiController =
        TextEditingController(text: widget.data['room_humi'].toString());
    roomTempController =
        TextEditingController(text: widget.data['room_temp'].toString());
    spo2Controller =
        TextEditingController(text: widget.data['spo2'].toString());
  }

  void _updateData() async {
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

      final updatedData = {
        'Datetime': formattedDatetime,
        'Heart Rate': parseToDouble(heartRateController.text),
        'Body Temp': parseToDouble(bodyTempController.text),
        'Room Humi': parseToDouble(roomHumiController.text),
        'Room Temp': parseToDouble(roomTempController.text),
        'SpO2': parseToDouble(spo2Controller.text),
      };

      // Print the key for debugging
      // print("Updating data with key: ${widget.data['key']}");

      try {
        // print("Updated Data: $updatedData");
        // Update the data in Firebase
        await _dbRef
            .child('Checks')
            .child(widget.data['key'])
            .update(updatedData);

        // Call the onUpdateSuccess callback to inform the HistoryScreen to refresh the data
        widget.onUpdateSuccess();

        // Navigate back to the previous screen
        Navigator.pop(context);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data updated successfully!')),
        );
      } catch (e) {
        // Print the error message for debugging
        // print("Error updating data: $e");

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to update data. Please try again.')),
        );
      }
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Edit Data'),
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
                      'Edit Data',
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
                        onPressed: _updateData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade50,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          'Update',
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
