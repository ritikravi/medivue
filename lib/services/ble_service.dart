// lib/services/ble_service.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BLEService {
  BLEService._internal();
  static final BLEService instance = BLEService._internal();

  // Streams to update UI screens
  final _bpmController = StreamController<int>.broadcast();
  final _spo2Controller = StreamController<int>.broadcast();

  Stream<int> get bpmStream => _bpmController.stream;
  Stream<int> get spo2Stream => _spo2Controller.stream;

  BluetoothDevice? _device;

  StreamSubscription<List<ScanResult>>? _scanSub;
  StreamSubscription<List<int>>? _bpmSub;
  StreamSubscription<List<int>>? _spo2Sub;
  StreamSubscription<BluetoothConnectionState>? _deviceStateSub;

  // UUIDs matching your ESP32 UART BLE code
  static const String SERVICE_UUID  = "6E400001-B5A3-F393-E0A9-E50E24DCCA9E";
  static const String BPM_CHAR_UUID = "6E400002-B5A3-F393-E0A9-E50E24DCCA9E";
  static const String SPO2_CHAR_UUID= "6E400003-B5A3-F393-E0A9-E50E24DCCA9E";

  bool get isConnected => _device?.isConnected ?? false;

  // ──────────────────────────────────────────────
  // 🔍 Scan for ESP32 and auto-connect
  // ──────────────────────────────────────────────
  void scanAndConnect({Duration timeout = const Duration(seconds: 6)}) {
    stopScan();

    // Start scanning (does NOT return stream!)
    FlutterBluePlus.startScan(timeout: timeout);

    // Listen to scan results stream
    _scanSub = FlutterBluePlus.scanResults.listen((results) async {
      for (final scanResult in results) {
        final dev = scanResult.device;
        final name = dev.name.trim();

        if (name.contains("ESP32") || name.contains("ESP32-MEDIVUE")) {
          await _scanSub?.cancel();
          FlutterBluePlus.stopScan();

          await _connectToDevice(dev);
          break;
        }
      }
    });
  }

  void stopScan() {
    _scanSub?.cancel();
    _scanSub = null;
    FlutterBluePlus.stopScan();
  }

  // ──────────────────────────────────────────────
  // 🔌 Connect to ESP32
  // ──────────────────────────────────────────────
  Future<void> _connectToDevice(BluetoothDevice device) async {
    _device = device;

    // Listen for connect/disconnect changes
    _deviceStateSub?.cancel();
    _deviceStateSub = device.connectionState.listen((state) async {
      debugPrint("Device ${device.remoteId} state: $state");

      if (state == BluetoothConnectionState.connected) {
        await _discoverAndSubscribe();
      } else if (state == BluetoothConnectionState.disconnected) {
        _cancelCharSubs();
        Future.delayed(const Duration(seconds: 2), () => scanAndConnect());
      }
    });

    try {
      await device.connect(timeout: const Duration(seconds: 12));
    } catch (_) {
      await _discoverAndSubscribe();
    }
  }

  // ──────────────────────────────────────────────
  // 🔎 Discover BLE service + subscribe to data
  // ──────────────────────────────────────────────
  Future<void> _discoverAndSubscribe() async {
    if (_device == null) return;

    final services = await _device!.discoverServices();

    for (var service in services) {
      if (service.uuid.toString().toUpperCase() == SERVICE_UUID) {
        for (var c in service.characteristics) {
          final uuid = c.uuid.toString().toUpperCase();

          if (uuid == BPM_CHAR_UUID) {
            await _setupCharacteristic(c, isBpm: true);
          } else if (uuid == SPO2_CHAR_UUID) {
            await _setupCharacteristic(c, isBpm: false);
          }
        }
      }
    }
  }

  // ──────────────────────────────────────────────
  // 📡 Subscribe to notifications from ESP32
  // ──────────────────────────────────────────────
  Future<void> _setupCharacteristic(
    BluetoothCharacteristic c, {
    required bool isBpm,
  }) async {
    await c.setNotifyValue(true);

    final sub = c.onValueReceived.listen((bytes) {
      final text = String.fromCharCodes(bytes).trim();
      final val = int.tryParse(text);

      if (val == null) return;

      if (isBpm) _bpmController.add(val);
      else _spo2Controller.add(val);
    });

    if (isBpm) {
      _bpmSub?.cancel();
      _bpmSub = sub;
    } else {
      _spo2Sub?.cancel();
      _spo2Sub = sub;
    }
  }

  // ──────────────────────────────────────────────
  // ❌ Disconnect cleanup
  // ──────────────────────────────────────────────
  void _cancelCharSubs() {
    _bpmSub?.cancel();
    _spo2Sub?.cancel();
    _bpmSub = null;
    _spo2Sub = null;
  }

  Future<void> disconnect() async {
    _cancelCharSubs();
    await _device?.disconnect();
    _device = null;
  }

  void dispose() {
    stopScan();
    _cancelCharSubs();
    _deviceStateSub?.cancel();
    _bpmController.close();
    _spo2Controller.close();
  }
}