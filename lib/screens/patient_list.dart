import 'package:flutter/material.dart';

class PatientListScreen extends StatelessWidget {
  const PatientListScreen({super.key});

  final List<Map<String, dynamic>> patients = const [
    {"name": "Ritik", "heartRate": 78, "spo2": 96, "fall": "No"},
    {"name": "Amit", "heartRate": 88, "spo2": 94, "fall": "Yes"},
    {"name": "Ravi", "heartRate": 72, "spo2": 98, "fall": "No"},
    {"name": "Mehul", "heartRate": 90, "spo2": 92, "fall": "No"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Patients"),
        backgroundColor: Colors.blue,
      ),

      body: ListView.builder(
        itemCount: patients.length,
        itemBuilder: (context, index) {
          final p = patients[index];

          return Card(
            margin: const EdgeInsets.all(12),
            child: ListTile(
              title: Text(p["name"],
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              subtitle: Text(
                "Heart: ${p["heartRate"]} bpm\n"
                "SpO₂: ${p["spo2"]}%\n"
                "Fall: ${p["fall"]}",
              ),
              trailing: const Icon(Icons.chevron_right),
            ),
          );
        },
      ),
    );
  }
}