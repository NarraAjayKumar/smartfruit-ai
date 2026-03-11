import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class LocalAiService {
  static Interpreter? _interpreter;
  static String? _currentModelPath;

  static final Map<String, List<String>> _cropLabels = {
    'watermelon': ['good-to-harvest', 'not-good-to-harvest'],
    'tomato': ['ripe', 'unripe', 'semiripe'],
    'cucumber': ['ripe', 'unripe'],
  };

  // Unified labels for assets/models/fruit_detector.tflite
  static final List<Map<String, String>> _unifiedLabels = [
    {'fruit': 'watermelon', 'label': 'good-to-harvest'},
    {'fruit': 'watermelon', 'label': 'not-good-to-harvest'},
    {'fruit': 'tomato', 'label': 'ripe'},
    {'fruit': 'tomato', 'label': 'unripe'},
    {'fruit': 'tomato', 'label': 'semiripe'},
    {'fruit': 'cucumber', 'label': 'ripe'},
    {'fruit': 'cucumber', 'label': 'unripe'},
  ];

  // Specific labels for assets/models/tomato.tflite
  static final List<Map<String, String>> _tomatoLabels = [
    {'fruit': 'tomato', 'label': 'unripe'},
    {'fruit': 'tomato', 'label': 'semi-ripe'},
    {'fruit': 'tomato', 'label': 'ripe'},
  ];

  // Specific labels for assets/models/cucumber.tflite
  static final List<Map<String, String>> _cucumberLabels = [
    {'fruit': 'cucumber', 'label': 'developing'},
    {'fruit': 'cucumber', 'label': 'maturing'},
  ];

  static const double _confThreshold = 0.40;
  static const double _iouThreshold = 0.45;
  static const int _inputSize = 640;

  static Future<void> init(String cropName) async {
    final crop = cropName.toLowerCase();
    String modelPath;
    
    if (crop == 'tomato') {
      modelPath = 'assets/models/tomato.tflite';
    } else if (crop == 'cucumber') {
      modelPath = 'assets/models/cucumber.tflite';
    } else {
      modelPath = 'assets/models/fruit_detector.tflite';
    }

    // Check if already loaded
    if (_interpreter != null && _currentModelPath == modelPath) return;

    try {
      final opts = InterpreterOptions()..threads = 4;
      bool assetExists = await _checkAssetExists(modelPath);
      final finalPath = assetExists ? modelPath : 'assets/models/fruit_detector.tflite';

      _interpreter?.close();
      _interpreter = await Interpreter.fromAsset(finalPath, options: opts);
      // IMPORTANT: Store the ACTUAL loaded path, not the requested one
      _currentModelPath = finalPath;
      debugPrint('Loaded model: $finalPath (requested: $modelPath)');
    } catch (e) {
      _interpreter = null;
      _currentModelPath = null;
      debugPrint('Failed to load model: $e');
    }
  }


  static Future<bool> _checkAssetExists(String path) async {
    try {
      await rootBundle.load(path);
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<Map<String, dynamic>?> predict(String imagePath, String cropName) async {
    // 1. Load the CORRECT model for this section directly
    await init(cropName);
    if (_interpreter == null) return null;

    final originalBytes = File(imagePath).readAsBytesSync();
    img.Image? originalImg = img.decodeImage(originalBytes);
    if (originalImg == null) return null;
    originalImg = img.bakeOrientation(originalImg);
    final origW = originalImg.width;
    final origH = originalImg.height;

    // 2. Run inference with the section's own model
    final allResults = await _runRawInference(originalImg);
    if (allResults == null || allResults.isEmpty) return null;

    final requestedFruit = cropName.toLowerCase();

    // 3. Filter detections: keep ONLY detections matching the requested fruit
    final matchingDets = allResults.where((d) => d.fruit == requestedFruit).toList();
    final otherDets = allResults.where((d) => d.fruit != requestedFruit && d.fruit != 'unknown').toList();

    // 4. Wrong fruit logic: if NO matching detections but OTHER fruit found
    final bool isWrongFruit = matchingDets.isEmpty && otherDets.isNotEmpty;
    final String suggestedCrop = isWrongFruit ? otherDets.first.fruit : requestedFruit;

    // Use matching detections if available, otherwise use all results for drawing
    final List<_Det> finalKept = matchingDets.isNotEmpty ? matchingDets : allResults;
    final _Det finalDet = finalKept.first;

    // 5. Draw boxes with STAGE-SPECIFIC COLORS
    final thickness = (origW / 150).toInt().clamp(4, 25);
    final fontSize = (origW / 1000) > 1.5 ? img.arial48 : img.arial24;
    final paddingH = thickness * 2;
    final paddingV = thickness;

    for (final det in finalKept) {
      final x1 = det.left.toInt();
      final y1 = det.top.toInt();
      final x2 = (det.left + det.width).toInt();
      final y2 = (det.top + det.height).toInt();

      final color = _getStageColor(det.fruit, det.label);
      
      img.drawRect(originalImg, x1: x1, y1: y1, x2: x2, y2: y2, color: color, thickness: thickness);

      final labelStr = isWrongFruit 
          ? "${det.fruit} ${det.label} ${det.conf.toStringAsFixed(2)}"
          : "${det.label} ${det.conf.toStringAsFixed(2)}";
      
      final charW = (origW / 1000) > 1.5 ? 28 : 14; 
      final charH = (origW / 1000) > 1.5 ? 50 : 30;
      final tw = labelStr.length * charW + paddingH; 
      final th = charH + paddingV;
      
      final bx1 = x1;
      final by1 = (y1 - th).clamp(0, origH);
      final bx2 = (x1 + tw).clamp(0, origW);
      final by2 = (y1).clamp(0, origH);

      img.fillRect(originalImg, x1: bx1, y1: by1, x2: bx2, y2: by2, color: color);
      img.drawString(originalImg, labelStr, font: fontSize, x: bx1 + (paddingH ~/ 2), y: by1 + (paddingV ~/ 2), color: img.ColorRgb8(0, 0, 0));
    }

    // 6. Save and return
    final tempDir = await getTemporaryDirectory();
    final fileName = "annotated_${DateTime.now().millisecondsSinceEpoch}.jpg";
    final annotatedPath = p.join(tempDir.path, fileName);
    File(annotatedPath).writeAsBytesSync(img.encodeJpg(originalImg));

    return {
      'fruit': cropName,
      'confidence': finalDet.conf,
      'box': [finalDet.left, finalDet.top, finalDet.width, finalDet.height],
      'freshness': finalDet.label,
      'crop': cropName,
      'isWrongFruit': isWrongFruit,
      'suggestedCrop': suggestedCrop,
      'originalWidth': origW,
      'originalHeight': origH,
      'annotatedPath': annotatedPath,
      'allDetections': finalKept.map((d) => {
        'fruit': d.fruit,
        'label': d.label,
        'confidence': d.conf,
        'box': [d.left, d.top, d.width, d.height],
      }).toList(),
    };
  }

  static Future<List<_Det>?> _runRawInference(img.Image originalImg) async {
    final origW = originalImg.width;
    final origH = originalImg.height;
    final resized = img.copyResize(originalImg, width: _inputSize, height: _inputSize);

    final input = List.generate(1, (b) => 
      List.generate(_inputSize, (y) =>
        List.generate(_inputSize, (x) {
          final p = resized.getPixel(x, y);
          return [p.r / 255.0, p.g / 255.0, p.b / 255.0];
        })
      )
    );

    final outShape = _interpreter!.getOutputTensor(0).shape;
    final raw3d = List.generate(outShape[0], (_) =>
      List.generate(outShape[1], (_) =>
        List.generate(outShape[2], (_) => 0.0)));
    
    _interpreter!.run(input, raw3d);

    final bool isNCX = outShape[1] < outShape[2];
    final int channels = isNCX ? outShape[1] : outShape[2];
    final int anchors = isNCX ? outShape[2] : outShape[1];

    final List<_Det> raws = [];
    List<Map<String, String>> currentLabels;
    if (_currentModelPath!.contains('tomato.tflite')) {
      currentLabels = _tomatoLabels;
    } else if (_currentModelPath!.contains('cucumber.tflite')) {
      currentLabels = _cucumberLabels;
    } else {
      currentLabels = _unifiedLabels;
    }

    for (int i = 0; i < anchors; i++) {
        double maxClassScore = 0;
        int bestClassIdx = -1;
        for (int c = 4; c < channels; c++) {
          final score = isNCX ? raw3d[0][c][i] : raw3d[0][i][c];
          if (score > maxClassScore) {
            maxClassScore = score;
            bestClassIdx = c - 4;
          }
        }
        if (maxClassScore < _confThreshold) continue;

        final info = (bestClassIdx >= 0 && bestClassIdx < currentLabels.length) 
            ? currentLabels[bestClassIdx] 
            : {'fruit': 'unknown', 'label': 'unknown'};
        
        final xc = isNCX ? raw3d[0][0][i] : raw3d[0][i][0];
        final yc = isNCX ? raw3d[0][1][i] : raw3d[0][i][1];
        final bw = isNCX ? raw3d[0][2][i] : raw3d[0][i][2];
        final bh = isNCX ? raw3d[0][3][i] : raw3d[0][i][3];

        // Adaptive scaling: detect if coords are in pixel space (0-640) or normalized (0-1)
        final bool isPixelSpace = xc > 2.0 || yc > 2.0;
        final double sx = isPixelSpace ? origW / _inputSize.toDouble() : origW.toDouble();
        final double sy = isPixelSpace ? origH / _inputSize.toDouble() : origH.toDouble();

        raws.add(_Det(
          classId: bestClassIdx,
          fruit: info['fruit']!,
          label: info['label']!,
          conf: maxClassScore,
          left: (xc - bw / 2) * sx,
          top: (yc - bh / 2) * sy,
          width: bw * sx,
          height: bh * sy,
        ));
    }
    return _nms(raws);
  }

  static img.ColorRgb8 _getStageColor(String fruit, String label) {
    if (fruit.toLowerCase() == 'tomato') {
      final l = label.toLowerCase();
      if (l.contains('unripe'))   return img.ColorRgb8(67, 160, 71); // Green
      if (l.contains('semi'))     return img.ColorRgb8(255, 179, 0); // Amber/Orange
      if (l.contains('ripe'))     return img.ColorRgb8(229, 57, 53); // Red
    }
    
    switch (fruit.toLowerCase()) {
      case 'watermelon': return img.ColorRgb8(27, 94, 32);    // Dark Green
      case 'cucumber':   return img.ColorRgb8(67, 160, 71);   // Green
      default:           return img.ColorRgb8(0, 255, 255);   // Cyan
    }
  }


  static img.ColorRgb8 _getImgColor(String fruit) {
    switch (fruit.toLowerCase()) {
      case 'tomato':     return img.ColorRgb8(229, 57, 53);   // Red
      case 'watermelon': return img.ColorRgb8(27, 94, 32);    // Dark Green
      case 'cucumber':   return img.ColorRgb8(67, 160, 71);   // Green
      default:           return img.ColorRgb8(0, 255, 255);   // Cyan fallback
    }
  }


  static List<_Det> _nms(List<_Det> dets) {
    if (dets.isEmpty) return [];
    dets.sort((a, b) => b.conf.compareTo(a.conf));
    final List<_Det> out = [];
    final suppressed = List.filled(dets.length, false);

    for (int i = 0; i < dets.length; i++) {
      if (suppressed[i]) continue;
      out.add(dets[i]);
      for (int j = i + 1; j < dets.length; j++) {
        if (_iou(dets[i], dets[j]) > _iouThreshold) suppressed[j] = true;
      }
    }
    return out;
  }

  static double _iou(_Det a, _Det b) {
    final x1 = max(a.left, b.left);
    final y1 = max(a.top, b.top);
    final x2 = min(a.left + a.width, b.left + b.width);
    final y2 = min(a.top + a.height, b.top + b.height);
    final inter = max(0.0, x2 - x1) * max(0.0, y2 - y1);
    final union = a.width * a.height + b.width * b.height - inter;
    return union <= 0 ? 0 : inter / union;
  }
}

class _Det {
  final int classId;
  final String fruit;
  final String label;
  final double conf, left, top, width, height;
  _Det({
    required this.classId,
    required this.fruit,
    required this.label,
    required this.conf,
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });
}

