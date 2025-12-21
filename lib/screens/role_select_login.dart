import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'doctor_dashboard.dart';
import 'home_screen.dart';

class RoleLoginScreen extends StatefulWidget {
  const RoleLoginScreen({super.key});

  @override
  State<RoleLoginScreen> createState() => _RoleLoginScreenState();
}

class _RoleLoginScreenState extends State<RoleLoginScreen> {
  String selectedRole = "";
  final _emailC = TextEditingController();
  final _passC = TextEditingController();
  bool loading = false;

  Future<void> login() async {
    if (selectedRole.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select Doctor or Caretaker.")),
      );
      return;
    }

    if (_emailC.text.trim().isEmpty || _passC.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email & Password required")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      final auth = FirebaseAuth.instance;

      final res = await auth.signInWithEmailAndPassword(
        email: _emailC.text.trim(),
        password: _passC.text.trim(),
      );

      // Fetch role stored in Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(res.user!.uid)
          .get();

      if (!userDoc.exists || !userDoc.data()!.containsKey('role')) {
        throw Exception("User role not found in database");
      }

      final savedRole = userDoc['role'];

      if (savedRole != selectedRole) {
        throw Exception(
            "Incorrect role selection! Login as: $savedRole instead.");
      }

      // ------------------------------------------
      // Redirect user based on role
      // ------------------------------------------
      if (savedRole == "doctor") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DoctorDashboard()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Login failed: ${e.toString().replaceAll('Exception:', '').trim()}",
          ),
        ),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  Widget roleButton(String role, IconData icon) {
    final isSelected = selectedRole == role;

    return GestureDetector(
      onTap: () => setState(() => selectedRole = role),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.black),
            const SizedBox(width: 10),
            Text(
              role == "doctor" ? "I am Doctor" : "I am Caretaker",
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailC.dispose();
    _passC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("User Login")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Select your role",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            roleButton("doctor", Icons.medical_information),
            const SizedBox(height: 12),
            roleButton("caretaker", Icons.person),

            const SizedBox(height: 30),

            TextField(
              controller: _emailC,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: _passC,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : login,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Login",
                        style: TextStyle(fontSize: 18),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}