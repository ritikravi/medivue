import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:fl_chart/fl_chart.dart';

class HeartRateCameraScreen extends StatefulWidget {
  const HeartRateCameraScreen({super.key});

  @override
  State<HeartRateCameraScreen> createState() => _HeartRateCameraScreenState();
}

class _HeartRateCameraScreenState extends State<HeartRateCameraScreen> {
  CameraController? controller;
  bool isCameraReady = false;

  bool fingerDetected = false;
  List<double> greenValues = [];
  Timer? bpmTimer;
  int bpm = 0;

  double currentAvg = 0;

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  // --------------------------------------------------------------
  // INIT CAMERA + TURN ON FLASH USING CameraController (SAFE)
  // --------------------------------------------------------------
  Future<void> initCamera() async {
    try {
      final cameras = await availableCameras();
      final backCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
      );

      controller = CameraController(
        backCamera,
        ResolutionPreset.low,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420, // ✔ Motorola safe format
      );

      await controller!.initialize();

      // TURN FLASH ON (NO torch plugin needed)
      await controller!.setFlashMode(FlashMode.torch);

      setState(() => isCameraReady = true);

      startStream();
    } catch (e) {
      print("Camera start error: $e");
    }
  }

  // --------------------------------------------------------------
  // PROCESS FRAMES — USE GREEN CHANNEL (more accurate)
  // --------------------------------------------------------------
  void startStream() {
    controller!.startImageStream((CameraImage image) {
      try {
        // GREEN = plane[1] in YUV420
        final bytes = image.planes[1].bytes;

        double sum = 0;
        for (int i = 0; i < bytes.length; i += 2) {
          sum += bytes[i]; // read only green
        }

        currentAvg = sum / (bytes.length / 2);

        // ----------- FINGER DETECTION ---------------
        if (currentAvg > 120) {
          fingerDetected = true;
        } else {
          fingerDetected = false;
          bpm = 0;
          greenValues.clear();
          setState(() {});
          return;
        }

        // Record waveform
        greenValues.add(currentAvg);
        if (greenValues.length > 200) greenValues.removeAt(0);

        setState(() {});
      } catch (e) {
        print("Frame error: $e");
      }
    });

    bpmTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      computeBPM();
    });
  }

  // --------------------------------------------------------------
  // BPM DETECTION — Peak Detection
  // --------------------------------------------------------------
  void computeBPM() {
    if (!fingerDetected || greenValues.length < 60) {
      setState(() => bpm = 0);
      return;
    }

    int peaks = 0;
    double maxVal = greenValues.reduce(max);

    for (int i = 2; i < greenValues.length - 2; i++) {
      if (greenValues[i] > greenValues[i - 1] &&
          greenValues[i] > greenValues[i + 1] &&
          greenValues[i] > maxVal * 0.92) {
        peaks++;
      }
    }

    int result = peaks * 6; // Convert to BPM

    // VALIDATE REAL HEART RATE RANGE
    bpm = (result >= 45 && result <= 160) ? result : 0;

    setState(() {});
  }

  @override
  void dispose() {
    bpmTimer?.cancel();
    controller?.setFlashMode(FlashMode.off);
    controller?.dispose();
    super.dispose();
  }

  // --------------------------------------------------------------
  // UI
  // --------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    if (!isCameraReady) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Heart Rate Monitor")),
      body: Column(
        children: [
          Expanded(child: CameraPreview(controller!)),

          const SizedBox(height: 15),

          Text(
            fingerDetected
                ? (bpm == 0 ? "Detecting heartbeat..." : "$bpm BPM")
                : "Place your finger on camera + flash",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: fingerDetected ? Colors.black : Colors.red,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            "GREEN AVG: ${currentAvg.toStringAsFixed(2)}",
            style: TextStyle(color: Colors.grey[700]),
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                minY:
                    greenValues.isEmpty ? 0 : greenValues.reduce(min) * 0.9,
                maxY:
                    greenValues.isEmpty ? 1 : greenValues.reduce(max) * 1.1,
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    spots: List.generate(
                      greenValues.length,
                      (i) => FlSpot(i.toDouble(), greenValues[i]),
                    ),
                    dotData: FlDotData(show: false),
                    color: Colors.green,
                    barWidth: 2,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}