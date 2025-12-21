import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import '../services/contact_store.dart';
import '../services/permission_service.dart';

class SosScreen extends StatefulWidget {
  const SosScreen({super.key});

  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen> {
  List<Map<String, String>> _contacts = [];
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    final contacts = await ContactStore.loadContacts();
    setState(() => _contacts = contacts);
  }

  Future<void> _saveContacts() async {
    await ContactStore.saveContacts(_contacts);
    setState(() {});
  }

  Future<bool> _requestPermissions() async {
    final ok = await PermissionService.requestBluetoothPermissions();
    if (!ok) return false;

    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    return !(perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever);
  }

  Future<Position?> _getLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return null;
      return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
    } catch (_) {
      return null;
    }
  }

  // --------------------------------------------------------
  // EMAIL SENDER FUNCTION
  // --------------------------------------------------------
  Future<void> _sendEmail(String email, String message) async {
    final emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: "subject=EMERGENCY ALERT&body=${Uri.encodeComponent(message)}",
    );

    print("STEP EMAIL → Launching $emailUri");

    try {
      final ok = await launchUrl(emailUri, mode: LaunchMode.externalApplication);
      print("MAIL RESULT: $ok");
    } catch (e) {
      print("MAIL FAILED → $e");
    }
  }

  // --------------------------------------------------------
  // MAIN SOS FUNCTION
  // --------------------------------------------------------
  Future<void> _onSosPressed() async {
    print("STEP 1: SOS Button Pressed");

    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Confirm SOS'),
        content: const Text('Send emergency alert?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text('Send')),
        ],
      ),
    );

    if (confirm != true) {
      print("STEP 2: User cancelled SOS");
      return;
    }

    print("STEP 2: User confirmed SOS");

    setState(() => _isSending = true);

    final perms = await _requestPermissions();
    print("STEP 3: Permission result = $perms");
    if (!perms) {
      setState(() => _isSending = false);
      return;
    }

    print("STEP 4: Getting location...");
    final pos = await _getLocation();
    print("STEP 4B: Location = $pos");

    String message = "EMERGENCY! I need help.";

    if (pos != null) {
      message += "\nLat: ${pos.latitude}, Lon: ${pos.longitude}";
    }

    if (_contacts.isEmpty) {
      print("STEP 5: No contacts found");
      setState(() => _isSending = false);
      return;
    }

    final first = _contacts.first;
    final phone = first['number'] ?? "";
    final email = first['email'] ?? "";

    // ---- SMS ----
    if (phone.isNotEmpty) {
      final smsUri =
          Uri.parse("sms:$phone?body=${Uri.encodeComponent(message)}");

      print("STEP 6: Launching SMS → $smsUri");
      await launchUrl(smsUri, mode: LaunchMode.externalApplication);
    }

    // ---- CALL ----
    if (phone.isNotEmpty) {
      final callUri = Uri.parse("tel:$phone");
      print("STEP 7: Launching CALL → $callUri");
      await launchUrl(callUri, mode: LaunchMode.externalApplication);
    }

    // ---- EMAIL ----
    if (email.isNotEmpty) {
      print("STEP 8: Sending EMAIL → $email");
      await _sendEmail(email, message);
    } else {
      print("NO EMAIL FOUND");
    }

    print("STEP 9: SOS COMPLETE");

    setState(() => _isSending = false);
  }

  // --------------------------------------------------------

  Future<void> _addContactDialog() async {
    final nameC = TextEditingController();
    final numberC = TextEditingController();
    final emailC = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Add Contact'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameC, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: numberC, decoration: const InputDecoration(labelText: 'Phone')),
            TextField(controller: emailC, decoration: const InputDecoration(labelText: 'Email')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(c, true), child: const Text('Add')),
        ],
      ),
    );

    if (ok == true) {
      _contacts.add({
        'name': nameC.text.trim(),
        'number': numberC.text.trim(),
        'email': emailC.text.trim(),
      });
      await _saveContacts();
    }
  }

  Future<void> _removeContact(int i) async {
    _contacts.removeAt(i);
    await _saveContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SOS"),
        actions: [
          IconButton(onPressed: _addContactDialog, icon: const Icon(Icons.add)),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: _onSosPressed,
              child: Container(
                width: 150,
                height: 150,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red,
                ),
                child: const Center(
                  child: Text(
                    "SOS",
                    style: TextStyle(
                        fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "Emergency Contacts",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 250,
              width: 350,
              child: ListView.builder(
                itemCount: _contacts.length,
                itemBuilder: (c, i) {
                  final e = _contacts[i];
                  return ListTile(
                    title: Text(e['name'] ?? ''),
                    subtitle: Text('${e['number'] ?? ''}\n${e['email'] ?? ''}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _removeContact(i),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}