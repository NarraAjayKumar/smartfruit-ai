import 'dart:async';

class DebugLogger {
  static final DebugLogger _instance = DebugLogger._internal();
  factory DebugLogger() => _instance;
  DebugLogger._internal();

  final List<String> _logs = [];
  final _logController = StreamController<List<String>>.broadcast();

  Stream<List<String>> get logStream => _logController.stream;
  List<String> get logs => List.unmodifiable(_logs);

  void log(String message) {
    final timestamp = DateTime.now().toString().split('.').first.split(' ').last;
    final logMessage = '[$timestamp] $message';
    _logs.add(logMessage);
    if (_logs.length > 500) _logs.removeAt(0);
    _logController.add(_logs);
    print(logMessage);
  }

  void clear() {
    _logs.clear();
    _logController.add(_logs);
  }
}

final logger = DebugLogger();
