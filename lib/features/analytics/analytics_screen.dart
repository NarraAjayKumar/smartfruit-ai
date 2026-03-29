import 'package:flutter/material.dart';
import '../../data/local_storage_service.dart';
import '../../core/animations/anti_gravity_widget.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  List<Map<String, dynamic>> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final history = await LocalStorageService.getHistory();
    if (mounted) {
      setState(() {
        _history = history;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalScans = _history.length;
    int readyCount = _history.where((s) => s['label']?.toString().contains('good-to-harvest') ?? false).length;
    double successRate = totalScans > 0 ? (readyCount / totalScans) * 100 : 0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Farm Analytics", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatCards(totalScans, successRate),
                  const SizedBox(height: 30),
                  const Text("Scan Activity", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  _buildActivityChart(),
                  const SizedBox(height: 30),
                  const Text("Recent History", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  _buildHistoryList(),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCards(int total, double rate) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard("Total Scans", total.toString(), Icons.analytics_rounded, Colors.blue),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildStatCard("Ready Rate", "${rate.toStringAsFixed(1)}%", Icons.eco_rounded, Colors.green),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return AntiGravityWidget(
      amplitude: 5,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 15),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityChart() {
    // Simple mock "chart" using rows/containers for production look without heavy dependencies
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (index) {
          double height = 20.0 + (index * 15.0 % 60);
          return Column(
            children: [
              Container(
                width: 15,
                height: height,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: index == 6 ? 1.0 : 0.3),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              const SizedBox(height: 8),
              Text("D${index + 1}", style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildHistoryList() {
    if (_history.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Text("No scans recorded yet.", style: TextStyle(color: Colors.grey[400])),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _history.length > 5 ? 5 : _history.length,
      itemBuilder: (context, index) {
        final scan = _history[index];
        final isReady = scan['label']?.toString().contains('good-to-harvest') ?? false;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey[100]!),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: (isReady ? Colors.green : Colors.red).withValues(alpha: 0.1),
                child: Icon(isReady ? Icons.check_circle : Icons.cancel, color: isReady ? Colors.green : Colors.red, size: 20),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(scan['crop'] ?? "Unknown Crop", style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(isReady ? "Ready for harvest" : "Not ready yet", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
              ),
              Text(
                scan['date'] != null ? scan['date'].toString().split('T')[0] : "Today",
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        );
      },
    );
  }
}
