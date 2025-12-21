import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ContactStore {
  static const _kKey = 'emergency_contacts';

  /// Load contacts from SharedPreferences
  static Future<List<Map<String, String>>> loadContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kKey);

    if (raw == null) return [];

    final List decoded = jsonDecode(raw);

    return decoded.map<Map<String, String>>((e) => {
          'name': e['name'] as String? ?? '',
          'number': e['number'] as String? ?? '',
          'email': e['email'] as String? ?? '',   // NEW FIELD
        }).toList();
  }

  /// Save contacts including name, number, email
  static Future<void> saveContacts(List<Map<String, String>> contacts) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(contacts);
    await prefs.setString(_kKey, encoded);
  }
}