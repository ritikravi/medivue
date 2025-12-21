import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SosService {
  static Future<void> sendSOS({bool auto = false}) async {
    print("🔥 SOS TRIGGERED (auto = $auto)");

    // 1. Get saved contact details
    final prefs = await SharedPreferences.getInstance();
    final number = prefs.getString('sos_number') ?? "9117328809";
    final email = prefs.getString('sos_email') ?? "ritikravi7724@gmail.com";

    // 2. Get GPS location
    Position? pos;
    try {
      pos = await Geolocator.getCurrentPosition();
      print("📍 Location: ${pos.latitude}, ${pos.longitude}");
    } catch (e) {
      print("⚠ Location error: $e");
    }

    final locationText = pos == null
        ? "Location unavailable"
        : "Lat: ${pos.latitude}, Lon: ${pos.longitude}";

    // --- BUILD MESSAGES ---
    final smsText = Uri.encodeComponent(
      "🚨 EMERGENCY! I NEED HELP!\n$locationText",
    );

    final emailBody = Uri.encodeComponent(
      "🚨 EMERGENCY ALERT\n\nI need help now!\n$locationText",
    );

    // --- 4. SEND SMS ---
    final smsUrl = Uri.parse("sms:$number?body=$smsText");
    if (await canLaunchUrl(smsUrl)) {
      print("📩 Sending SMS...");
      await launchUrl(smsUrl);
    } else {
      print("❌ Cannot open SMS");
    }

    // --- 5. CALL (Direct call works on Android) ---
    final callUrl = Uri.parse("tel:$number");
    if (await canLaunchUrl(callUrl)) {
      print("📞 Placing emergency CALL...");
      await launchUrl(callUrl);
    } else {
      print("❌ Cannot call");
    }

    // --- 6. EMAIL ---
    final mailUrl = Uri.parse(
      "mailto:$email?subject=EMERGENCY ALERT&body=$emailBody",
    );

    if (await canLaunchUrl(mailUrl)) {
      print("📧 Opening EMAIL...");
      await launchUrl(mailUrl);
    } else {
      print("❌ Cannot open email");
    }

    print("✅ SOS Completed");
  }
}