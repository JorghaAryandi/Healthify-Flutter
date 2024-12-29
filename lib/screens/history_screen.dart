import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'addData_screen.dart';
import 'editData_screen.dart';
import 'viewData_screen.dart'; // Import your AddData screen

class HistoryScreen extends StatefulWidget {
  final String userId;

  const HistoryScreen({super.key, required this.userId});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  late List<PlutoColumn> columns;
  late List<PlutoRow> rows;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    initializeTable();
    fetchHistoryData();
  }

  @override
  void dispose() {
    // Cancel any ongoing operations here
    super.dispose();
  }

  void initializeTable() {
    columns = [
      PlutoColumn(
        title: 'Actions',
        field: 'actions',
        type: PlutoColumnType.text(),
        enableEditingMode: false,
        textAlign: PlutoColumnTextAlign.center,
        renderer: (rendererContext) {
          return Builder(
            builder: (BuildContext context) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // View Icon
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ViewDataScreen(
                            data: rendererContext.row.cells.map(
                                (key, value) => MapEntry(key, value.value)),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.visibility, color: Colors.blue),
                    ),
                  ),
                  // Edit Icon
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditDataScreen(
                            data: rendererContext.row.cells.map(
                                (key, value) => MapEntry(key, value.value)),
                            onUpdateSuccess: () {
                              // Setelah update berhasil, lakukan fetch data ulang
                              fetchHistoryData();
                            },
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.edit, color: Colors.orange),
                    ),
                  ),
                  // Delete Icon
                  GestureDetector(
                    onTap: () {
                      deleteHistoryItem(
                          rendererContext.row.cells['key']?.value);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.delete, color: Colors.red),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
      PlutoColumn(
          title: 'No',
          field: 'no',
          type: PlutoColumnType.number(),
          textAlign: PlutoColumnTextAlign.center),
      PlutoColumn(
        title: 'Datetime',
        field: 'datetime',
        type: PlutoColumnType.text(),
        textAlign: PlutoColumnTextAlign.center,
      ),
      PlutoColumn(
        title: 'Heart Rate (BPM)',
        field: 'heart_rate',
        type: PlutoColumnType.text(),
        textAlign: PlutoColumnTextAlign.center,
      ),
      PlutoColumn(
        title: 'Blood Oxygen (%)',
        field: 'spo2',
        type: PlutoColumnType.text(),
        textAlign: PlutoColumnTextAlign.center,
      ),
      PlutoColumn(
        title: 'Body Temp (°C)',
        field: 'body_temp',
        type: PlutoColumnType.text(),
        textAlign: PlutoColumnTextAlign.center,
      ),
      PlutoColumn(
        title: 'Room Temp (°C)',
        field: 'room_temp',
        type: PlutoColumnType.text(),
        textAlign: PlutoColumnTextAlign.center,
      ),
      PlutoColumn(
        title: 'Room Humi (%)',
        field: 'room_humi',
        type: PlutoColumnType.text(),
        textAlign: PlutoColumnTextAlign.center,
      ),
    ];
    rows = [];
  }

  Future<void> fetchHistoryData() async {
    if (!mounted) return;

    print("Fetching history data...");

    setState(() {
      isLoading = true;
      rows = []; // Clear existing data first
    });

    try {
      final checksRef =
          _dbRef.child('Checks').orderByChild('UID').equalTo(widget.userId);
      final snapshot = await checksRef.get();

      if (!mounted) return;

      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);

        setState(() {
          int no = 1; // Inisialisasi nomor urut
          rows = data.entries.map((entry) {
            final item = entry.value as Map;

            return PlutoRow(cells: {
              'no': PlutoCell(value: no++), // Tambahkan nomor urut
              'actions': PlutoCell(
                value: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // View Icon
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ViewDataScreen(
                              data: {
                                'key': entry.key, // Pass the key here
                                'datetime': item['Datetime'] ?? 'N/A',
                                'heart_rate': (item['Heart Rate'] ?? 0),
                                'body_temp': (item['Body Temp'] ?? 0),
                                'room_humi': (item['Room Humi'] ?? 0),
                                'room_temp': (item['Room Temp'] ?? 0),
                                'spo2': (item['SpO2'] ?? 0),
                              },
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.visibility, color: Colors.blue),
                      ),
                    ),
                    // Edit Icon
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditDataScreen(
                              data: {
                                'key': entry.key, // Pass the key here
                                'datetime': item['Datetime'] ?? 'N/A',
                                'heart_rate': (item['Heart Rate'] ?? 0),
                                'body_temp': (item['Body Temp'] ?? 0),
                                'room_humi': (item['Room Humi'] ?? 0),
                                'room_temp': (item['Room Temp'] ?? 0),
                                'spo2': (item['SpO2'] ?? 0),
                              },
                              // Tambahkan callback onUpdateSuccess
                              onUpdateSuccess: () async {
                                fetchHistoryData();
                              },
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.edit, color: Colors.orange),
                      ),
                    ),
                    // Delete Icon
                    GestureDetector(
                      onTap: () {
                        deleteHistoryItem(entry.key); // Pass the key here
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.delete, color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
              'key': PlutoCell(
                  value: entry.key), // Display the key in a separate column
              'datetime': PlutoCell(value: item['Datetime'] ?? 'N/A'),
              'heart_rate': PlutoCell(value: (item['Heart Rate'] ?? 0)),
              'body_temp': PlutoCell(value: (item['Body Temp'] ?? 0)),
              'room_humi': PlutoCell(value: (item['Room Humi'] ?? 0)),
              'room_temp': PlutoCell(value: (item['Room Temp'] ?? 0)),
              'spo2': PlutoCell(value: (item['SpO2'] ?? 0)),
            });
          }).toList();

          // print("Rows updated: $rows");

          isLoading = false;
        });
      } else {
        setState(() {
          rows = [];
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch data: $e')),
        );
      }
    }
  }

  void deleteHistoryItem(String key) async {
    if (!mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Delete')),
        ],
      ),
    );

    if (confirmed ?? false) {
      try {
        // Set loading state only if still mounted
        if (mounted) {
          setState(() {
            isLoading = true;
          });
        }

        await _dbRef.child('Checks/$key').remove();
        await fetchHistoryData();
        if (mounted) {
          await fetchHistoryData();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Item deleted successfully!')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete item: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.teal, // Mengubah warna indikator pengisian
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                // Wrap the entire body with SingleChildScrollView
                child: Column(
                  children: [
                    Card(
                      color: Colors.green.shade50,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'History',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.teal,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              constraints: BoxConstraints(
                                maxHeight: MediaQuery.of(context).size.height *
                                    0.6, // Limit the height of the table
                              ),
                              child: PlutoGrid(
                                columns: columns,
                                rows: rows,
                                configuration: const PlutoGridConfiguration(
                                  columnFilter: PlutoGridColumnFilterConfig(
                                    filters: [
                                      PlutoFilterTypeContains(),
                                      PlutoFilterTypeEquals(),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to add data screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AddDataScreen(
                                    userId: widget.userId,
                                    onAddSuccess: () async {
                                      fetchHistoryData(); // Pastikan menunggu data terbaru
                                    },
                                  )),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade50,
                        padding: const EdgeInsets.symmetric(
                            vertical: 20, horizontal: 30),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'Add Data Manually',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(
                        height:
                            20), // Add this line to add space below the button
                  ],
                ),
              ),
            ),
    );
  }
}
