import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/debug_console.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("App Settings"),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.offline_bolt_rounded, size: 64, color: Colors.green),
            const SizedBox(height: 20),
            const Text(
              "Fully Offline Mode",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "SmartFruit AI is now running entirely on your device using TensorFlow Lite. No internet connection is required to scan fruits.",
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: const Column(
                children: [
                   Row(
                    children: [
                      Icon(Icons.check_circle_outline, color: Colors.green),
                      SizedBox(width: 12),
                      Text("System Status", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    "All AI models (Watermelon, Tomato, Cucumber) are loaded locally and optimized for mobile performance.",
                    style: TextStyle(fontSize: 13, color: Colors.green),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            _buildDebugSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDebugSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Diagnostics",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.bug_report_outlined, color: Colors.orange),
          title: const Text("Open System Debug Console"),
          subtitle: const Text("View real-time technical logs from the application."),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
             Navigator.push(
               context,
               MaterialPageRoute(builder: (context) => const DebugConsole()),
             );
          },
        ),
      ],
    );
  }
}
