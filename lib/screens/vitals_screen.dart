import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/ble_service.dart';
import '../services/permission_service.dart';

class VitalsScreen extends StatefulWidget {
  const VitalsScreen({super.key});

  @override
  State<VitalsScreen> createState() => _VitalsScreenState();
}

class _VitalsScreenState extends State<VitalsScreen> {
  final ble = BLEService.instance;

  double t = 0;

  List<FlSpot> heartRateData = [];
  List<FlSpot> spo2Data = [];

  StreamSubscription? bpmSub;
  StreamSubscription? spo2Sub;

  @override
  void initState() {
    super.initState();

    // Fill initial 5 dummy points
    for (int i = 0; i < 5; i++) {
      heartRateData.add(FlSpot(i.toDouble(), 80));
      spo2Data.add(FlSpot(i.toDouble(), 97));
    }
    t = 5;

    // 🔥 Correct permission + scan flow
    _startBLE();
  }

  Future<void> _startBLE() async {
    bool granted = await PermissionService.requestBluetoothPermissions();

    if (granted) {
      print("Permissions granted — starting BLE scan");
      BLEService.instance.scanAndConnect();

      // Listen for BPM updates
      bpmSub = ble.bpmStream.listen((value) {
        _addPoint(heartRateData, value.toDouble());
      });

      // Listen for SpO2 updates
      spo2Sub = ble.spo2Stream.listen((value) {
        _addPoint(spo2Data, value.toDouble());
      });
    } else {
      print("Bluetooth permissions NOT granted!");
    }
  }

  void _addPoint(List<FlSpot> list, double val) {
    setState(() {
      t += 1;
      list.add(FlSpot(t, val));

      if (list.length > 20) list.removeAt(0);
    });
  }

  @override
  void dispose() {
    bpmSub?.cancel();
    spo2Sub?.cancel();
    super.dispose();
  }

  Widget buildGraph(
    String title,
    Color color,
    List<FlSpot> data,
    String unit,
    double minY,
    double maxY,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                minY: minY,
                maxY: maxY,
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: data,
                    color: color,
                    isCurved: true,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
          Text(
            "${data.last.y.toStringAsFixed(0)} $unit",
            style: TextStyle(
                color: color, fontSize: 18, fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Vitals Monitoring")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            buildGraph("Heart Rate", Colors.red, heartRateData, "bpm", 40, 150),
            buildGraph("SpO₂", Colors.blue, spo2Data, "%", 85, 100),
          ],
        ),
      ),
    );
  }
}