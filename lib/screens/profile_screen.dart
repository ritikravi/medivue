import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Image
            Center(
              child: CircleAvatar(
                radius: 55,
                backgroundColor: Colors.blue.shade100,
                child: const Icon(
                  Icons.person,
                  size: 70,
                  color: Colors.blue,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Full Name
            const Text(
              "Ritik Raushan",
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),

            Text(
              "Elderly Care System User",
              style:
                  TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),

            const SizedBox(height: 25),

            // Information Cards
            _buildInfoTile(
              icon: Icons.phone,
              title: "Phone Number",
              subtitle: "+91 98765 43210",
            ),
            _buildInfoTile(
              icon: Icons.email,
              title: "Email",
              subtitle: "ritik@example.com",
            ),
            _buildInfoTile(
              icon: Icons.location_on,
              title: "Address",
              subtitle: "Punjab, India",
            ),
            _buildInfoTile(
              icon: Icons.health_and_safety,
              title: "Medical Condition",
              subtitle: "No major illness reported",
            ),

            const SizedBox(height: 40),

            // Logout Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(
                    horizontal: 40, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {},
              child: const Text(
                "Logout",
                style:
                    TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Info Tile Widget
  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 30, color: Colors.blue),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                    fontSize: 14, color: Colors.grey.shade600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}