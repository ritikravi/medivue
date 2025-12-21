import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  /// Request permissions needed for SOS (location + SMS/phone on Android).
  /// On macOS we skip runtime permission_handler because macOS uses entitlements/Info.plist.
  static Future<bool> requestBluetoothPermissions() async {
    // macOS: skip runtime permissions (already handled via entitlements/Info.plist)
    if (Platform.isMacOS) {
      print("macOS detected → skipping permission_handler");
      return true;
    }

    // For Android & iOS
    Map<Permission, PermissionStatus> statuses = await [
      // Location required for SOS location sharing
      Permission.locationWhenInUse,

      // Android-only runtime permissions
      if (Platform.isAndroid) Permission.sms,
      if (Platform.isAndroid) Permission.phone,
    ].request();

    // Must return true ONLY if all permissions are granted
    return statuses.values.every((status) => status.isGranted);
  }
}