import 'package:flutter/material.dart';
import '../utils/debug_logger.dart';

class DebugConsole extends StatelessWidget {
  const DebugConsole({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("System Debug Console"),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.greenAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: () => logger.clear(),
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: StreamBuilder<List<String>>(
        stream: logger.logStream,
        initialData: logger.logs,
        builder: (context, snapshot) {
          final logs = snapshot.data ?? [];
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            reverse: true, // Show latest logs at the bottom/start
            itemCount: logs.length,
            itemBuilder: (context, index) {
              // Since it's reversed, index 0 is the last item
              final log = logs[logs.length - 1 - index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  log,
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
