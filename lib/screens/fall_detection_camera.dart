import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

// ⭐ GLOBAL FALL STATUS for HomeScreen sync
import '../services/fall_status_service.dart';

class CameraFallDetectionScreen extends StatefulWidget {
  const CameraFallDetectionScreen({super.key});

  @override
  State<CameraFallDetectionScreen> createState() =>
      _CameraFallDetectionScreenState();
}

class _CameraFallDetectionScreenState extends State<CameraFallDetectionScreen> {
  CameraController? controller;
  bool fallDetected = false;
  bool isCameraReady = false;

  StreamSubscription? accelSub;
  bool cooldown = false;

  static const double fallThreshold = 13;

  @override
  void initState() {
    super.initState();
    initCamera();
    startAccelerometer();
  }

  // -------------------------------------------------------------
  // INITIALIZE CAMERA
  // -------------------------------------------------------------
  Future<void> initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      controller = CameraController(
        cameras[0],
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await controller!.initialize();
      if (!mounted) return;

      setState(() => isCameraReady = true);
    } catch (e) {
      debugPrint("Camera init error: $e");
    }
  }

  // -------------------------------------------------------------
  // ACCELEROMETER FALL DETECTION
  // -------------------------------------------------------------
  void startAccelerometer() {
    accelSub = accelerometerEventStream().listen((event) {
      final double ax = event.x.toDouble();
      final double ay = event.y.toDouble();
      final double az = event.z.toDouble();

      final double magnitude = sqrt(ax * ax + ay * ay + az * az);

      print("📊 ACCEL = $magnitude");

      // FALL DETECTED
      if (magnitude > fallThreshold && !cooldown) {
        cooldown = true;

        print("🚨 FALL DETECTED — Starting 3-sec countdown");

        // ⭐ UPDATE GLOBAL FALL STATUS
        FallStatusService.setFallDetected();

        setState(() => fallDetected = true);

        // SEND SOS AFTER 3 SEC
        Future.delayed(const Duration(seconds: 3), () async {
          print("⏳ 3 sec done — Sending SOS");
          await sendAutoSOS();
        });

        // Reset after animation + cooldown
        Future.delayed(const Duration(seconds: 8), () {
          if (!mounted) return;

          // ⭐ RESET GLOBAL STATUS
          FallStatusService.reset();

          setState(() => fallDetected = false);
          cooldown = false;
        });
      }
    });
  }

  // -------------------------------------------------------------
  // AUTO SOS — (SMS + CALL + EMAIL)
  // -------------------------------------------------------------
  Future<void> sendAutoSOS() async {
    const String emergencyNumber = "9117328809";
    const String email = "ritikravi7724@gmail.com";

    print("📌 AUTO SOS STARTED");

    // 1️⃣ SMS
    final smsUri = Uri.parse(
      "sms:$emergencyNumber?body=${Uri.encodeComponent("⚠ FALL DETECTED! I may need help immediately.")}",
    );

    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
      print("📩 SMS OPENED");
    } else {
      print("❌ SMS FAILED - No app");
    }

    // 2️⃣ DIRECT CALL
    try {
      await FlutterPhoneDirectCaller.callNumber(emergencyNumber);
      print("📞 CALL STARTED");
    } catch (e) {
      print("❌ CALL FAILED: $e");
    }

    // 3️⃣ EMAIL
    final emailUri = Uri(
      scheme: "mailto",
      path: email,
      queryParameters: {
        "subject": "⚠ EMERGENCY – FALL DETECTED",
        "body": "A fall was detected automatically. Please respond immediately.",
      },
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
      print("📧 EMAIL STARTED");
    } else {
      print("❌ EMAIL FAILED");
    }

    print("✅ AUTO SOS COMPLETE");
  }

  // -------------------------------------------------------------
  // SAFE DISPOSAL
  // -------------------------------------------------------------
  @override
  void dispose() {
    try {
      accelSub?.cancel();
    } catch (_) {}

    try {
      if (controller != null && (controller?.value.isInitialized ?? false)) {
        controller!.dispose();
      }
    } catch (e) {
      print("⚠ Camera dispose issue ignored");
    }

    super.dispose();
  }

  // -------------------------------------------------------------
  // UI
  // -------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    if (!isCameraReady ||
        controller == null ||
        !controller!.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Camera + Sensor Fall Detection"),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          CameraPreview(controller!),

          // FALL STATUS INDICATOR
          Positioned(
            bottom: 20,
            left: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: fallDetected ? Colors.red : Colors.green,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                fallDetected ? "⚠ REAL FALL DETECTED!" : "Live monitoring...",
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}