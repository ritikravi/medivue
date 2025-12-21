import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

import 'vitals_screen.dart';
import 'sos_screen.dart';
import 'fall_detection_camera.dart';
import 'weather_screen.dart';
import 'heart_rate_camera.dart';
import 'role_select_login.dart';     // ⭐ CORRECT FILE

import '../services/permission_service.dart';
import '../services/ble_service.dart';
import '../services/fall_status_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double heartRate = 78;
  double spo2 = 96;

  final Random random = Random();
  Timer? timer;
  Timer? fallStatusTimer;

  @override
  void initState() {
    super.initState();

    /// Request permissions + BLE start
    Future.delayed(Duration.zero, () async {
      await PermissionService.requestBluetoothPermissions();
      BLEService.instance.scanAndConnect();
    });

    /// Simulated vitals
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        heartRate = 70 + random.nextInt(41).toDouble();
        spo2 = 94 + random.nextInt(7).toDouble();
      });
    });

    /// Update fall status from global service
    fallStatusTimer = Timer.periodic(const Duration(milliseconds: 300), (_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    fallStatusTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String fallStatus = FallStatusService.fallStatus;

    return Scaffold(
      appBar: AppBar(
        title: const Text("MediVue Dashboard"),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// HEART RATE (from ESP32)
            _buildVitalCard(
              icon: Icons.favorite,
              label: "Heart Rate",
              value: "${heartRate.toStringAsFixed(0)} bpm",
              color: Colors.red,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const VitalsScreen()),
                );
              },
            ),

            const SizedBox(height: 16),

            /// SPO₂
            _buildVitalCard(
              icon: Icons.bloodtype,
              label: "SpO₂",
              value: "${spo2.toStringAsFixed(0)}%",
              color: Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const VitalsScreen()),
                );
              },
            ),

            const SizedBox(height: 16),

            /// FALL DETECTION STATUS
            _buildVitalCard(
              icon: Icons.warning,
              label: "Fall Detection",
              value: fallStatus,
              color: fallStatus == "Fall detected!" ? Colors.red : Colors.orange,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const CameraFallDetectionScreen()),
                );
              },
            ),

            const SizedBox(height: 16),

            /// CAMERA HEART RATE MONITOR
            _buildVitalCard(
              icon: Icons.monitor_heart,
              label: "Measure Heart Rate",
              value: "Tap to start",
              color: Colors.purple,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const HeartRateCameraScreen()),
                );
              },
            ),

            const SizedBox(height: 16),

            /// WEATHER SCREEN
            _buildVitalCard(
              icon: Icons.cloud,
              label: "Weather",
              value: "Tap to check",
              color: Colors.teal,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WeatherScreen()),
                );
              },
            ),

            const SizedBox(height: 16),

            /// ⭐ LOGIN FOR BOTH DOCTOR + CARETAKER
            _buildVitalCard(
              icon: Icons.local_hospital,
              label: "Doctor / Caretaker Login",
              value: "Tap to login",
              color: Colors.green,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RoleLoginScreen()),
                );
              },
            ),

            const SizedBox(height: 30),

            /// SOS BUTTON
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SosScreen()),
                );
              },
              child: const Text(
                "EMERGENCY SOS",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// CARD BUILDER FUNCTION
  Widget _buildVitalCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold, color: color),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}