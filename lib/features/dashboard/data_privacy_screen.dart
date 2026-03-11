import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/user_provider.dart';
import '../../data/local_storage_service.dart';
import '../auth/login_screen.dart';

class DataPrivacyScreen extends StatelessWidget {
  const DataPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Data & Privacy")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "How we handle your data",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildInfoCard(
              "Local Data",
              "Your profile info, farm settings, and scan history are stored securely on this device's local storage.",
              Icons.storage_rounded,
            ),
            const SizedBox(height: 15),
            _buildInfoCard(
              "Cloud Logic",
              "Images captured for analysis are sent to our secure backend to detect ripeness. We do not store these images permanently unless you permit us.",
              Icons.cloud_upload_rounded,
            ),
            const SizedBox(height: 40),
            const Text(
              "Data Controls",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            _buildActionTile(
              context,
              "Clear Scan History",
              "Remove all past ripeness reports from this device.",
              Icons.delete_sweep_outlined,
              () => _confirmAction(context, "Clear History", "This will delete all scan history. Continue?", () async {
                await LocalStorageService.clearHistory();
              }),
            ),
            const SizedBox(height: 10),
            _buildActionTile(
              context,
              "Reset All App Data",
              "Wipe all profiles, settings, and credentials.",
              Icons.phonelink_erase_rounded,
              () => _confirmAction(context, "Reset Data", "This will wipe EVERYTHING and logout. Continue?", () async {
                await Provider.of<UserProvider>(context, listen: false).resetAll();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                }
              }),
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String description, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.withValues(alpha: 0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.green),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 5),
                Text(description, style: TextStyle(color: Colors.grey[700], height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(BuildContext context, String title, String subtitle, IconData icon, VoidCallback onTap, {bool isDestructive = false}) {
    return ListTile(
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      tileColor: isDestructive ? Colors.red.withValues(alpha: 0.05) : Colors.grey[100],
      leading: Icon(icon, color: isDestructive ? Colors.red : Colors.green),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isDestructive ? Colors.red : Colors.black87)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.chevron_right, size: 20),
    );
  }

  void _confirmAction(BuildContext context, String title, String message, Future<void> Function() action) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL")),
          TextButton(
            onPressed: () async {
              await action();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$title completed")));
              }
            },
            child: const Text("CONFIRM", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
