import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'screens/role_select_login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MediVue',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const RoleLoginScreen(),   // ⭐ LOGIN FIRST
    );
  }
}