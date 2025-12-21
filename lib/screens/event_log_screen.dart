import 'package:flutter/material.dart';

class EventLogScreen extends StatelessWidget {
  const EventLogScreen({super.key});

  // Sample events (fake data)
  final List<Map<String, String>> events = const [
    {"type": "Fall Detected", "time": "2025-12-02 11:12:23"},
    {"type": "SOS Triggered", "time": "2025-12-02 10:45:10"},
    {"type": "Warning", "time": "2025-12-01 18:20:50"},
    {"type": "Fall Detected", "time": "2025-12-01 14:30:15"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Event Log")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          Color iconColor;
          IconData iconData;

          switch (event['type']) {
            case "SOS Triggered":
              iconColor = Colors.red;
              iconData = Icons.warning;
              break;
            case "Fall Detected":
              iconColor = Colors.orange;
              iconData = Icons.warning_amber_outlined;
              break;
            default:
              iconColor = Colors.grey;
              iconData = Icons.info_outline;
          }

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Icon(iconData, color: iconColor),
              title: Text(event['type'] ?? ''),
              subtitle: Text(event['time'] ?? ''),
            ),
          );
        },
      ),
    );
  }
}