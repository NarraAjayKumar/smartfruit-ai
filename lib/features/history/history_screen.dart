import 'package:flutter/material.dart';
import '../../data/local_storage_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<Map<String, dynamic>>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = LocalStorageService.getHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan History"),
        actions: [
          IconButton(
            onPressed: () async {
              await LocalStorageService.clearHistory();
              setState(() {
                _historyFuture = LocalStorageService.getHistory();
              });
            },
            icon: const Icon(Icons.delete_sweep_rounded),
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState(context);
          }

          final history = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final item = history[index];
              final date = DateTime.parse(item['date']);
              final confidence = item['confidence'] ?? 0.0;
              
              final Color cropColor = _getColor(item['crop']);
              
              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade100),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: cropColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(_getIcon(item['crop']), color: cropColor),
                  ),
                  title: Text(item['crop'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: Text("${date.day}/${date.month}/${date.year} • ${item['count']} Items"),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "${(confidence * 100).toInt()}%",
                        style: TextStyle(
                          color: cropColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Text("Accuracy", style: TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off_rounded, size: 80, color: Colors.grey.withValues(alpha: 0.3)),
          const SizedBox(height: 20),
          const Text(
            "No scans yet",
            style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "Your farming intelligence will appear here.",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  IconData _getIcon(String crop) {
    switch (crop.toLowerCase()) {
      case 'watermelon': return Icons.water_drop_rounded;
      case 'tomato': return Icons.circle;
      case 'cucumber': return Icons.eco_rounded;
      default: return Icons.eco;
    }
  }

  Color _getColor(String crop) {
    switch (crop.toLowerCase()) {
      case 'watermelon': return Colors.red;
      case 'tomato': return Colors.orange;
      case 'cucumber': return Colors.green;
      default: return Colors.green;
    }
  }
}

