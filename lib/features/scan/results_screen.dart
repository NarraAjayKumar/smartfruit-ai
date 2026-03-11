import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../data/local_storage_service.dart';

class ResultsScreen extends StatefulWidget {
  final File imageFile;
  final Map<String, dynamic> scanResult;
  final int originalWidth;
  final int originalHeight;

  const ResultsScreen({
    super.key,
    required this.imageFile,
    required this.scanResult,
    required this.originalWidth,
    required this.originalHeight,
  });

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  late List<Map<String, dynamic>> _detections;
  late String? _annotatedPath;

  @override
  void initState() {
    super.initState();
    final all = widget.scanResult['allDetections'];
    if (all != null && all is List) {
      _detections = List<Map<String, dynamic>>.from(all);
    } else {
      _detections = [];
    }
    _annotatedPath = widget.scanResult['annotatedPath'];
  }

  Color _getCropColor(String crop) {
    switch (crop.toLowerCase()) {
      case 'tomato':     return const Color(0xFFE53935); // Red
      case 'watermelon': return const Color(0xFF1B5E20); // Dark Green
      case 'cucumber':   return const Color(0xFF43A047); // Green
      default:           return const Color(0xFF43A047);
    }
  }


  @override
  Widget build(BuildContext context) {
    final String cropName = widget.scanResult['crop'] ?? 'Fruit';
    // Use the primary crop color (Green for watermelon/cucumber, red for tomato)
    final Color primaryColor = _getCropColor(cropName);
    
    // Calculate display values
    final double topConfidence = _detections.isNotEmpty 
        ? (_detections.first['confidence'] as double? ?? 0.0) 
        : (widget.scanResult['confidence'] as double? ?? 0.0);
    
    final displayFile = _annotatedPath != null ? File(_annotatedPath!) : widget.imageFile;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9), // Light green background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Analysis Result",
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 22),
        ),

        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report_outlined, color: Color(0xFF2E7D32)),
            onPressed: () {}, // Debug log placeholder
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Annotated Image (Permanent Bounding Boxes)
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: InteractiveViewer(
                  child: Image.file(
                    displayFile,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),

          // 2. Mockup-style Results Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(28, 36, 28, 28),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(50)),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, -5))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Crop Name & Score Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          cropName.toLowerCase() == 'watermelon' ? Icons.water_drop : Icons.eco,
                          color: primaryColor, 
                          size: 32,
                        ),

                        const SizedBox(width: 12),
                        Text(
                          cropName,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Colors.grey[800],
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Text(
                        "${(topConfidence * 100).toStringAsFixed(1)}% Score",
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),

                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  "Insights Detected:",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Detection List matched to mockup wording
                  ..._detections.take(1).map((det) {
                    final label = det['label'] ?? 'unknown';
                    final conf = (det['confidence'] as double? ?? 0.0);
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: primaryColor, width: 2),
                        ),
                        child: Icon(Icons.check, color: primaryColor, size: 16),
                      ),
                      title: Text(
                        "$label recognized",

                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        color: primaryColor,
                      ),
                    ),

                    subtitle: Text(
                      "${(conf * 100).toStringAsFixed(0)}% match",
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Colors.black45,
                      ),
                    ),
                  );
                }),
                
                const SizedBox(height: 32),
                
                // Big Red 'FINISH & SAVE' Button
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () async {
                      // Save to history before exiting
                      await LocalStorageService.saveScan({
                        'crop': cropName,
                        'confidence': topConfidence,
                        'count': _detections.length,
                        'freshness': _detections.isNotEmpty ? _detections.first['label'] : 'unknown',
                      });
                      
                      if (mounted) {
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 0,
                    ),
                    child: const Text(
                      "FINISH & SAVE",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        letterSpacing: 1,
                      ),
                    ),

                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

