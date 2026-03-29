import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class CustomAuthService {
  final String baseUrl = ApiConfig.baseUrl;

  // 0. Health Check (with Retry for Render Cold Start)
  Future<Map<String, dynamic>> checkHealth({int retries = 2}) async {
    for (int i = 0; i <= retries; i++) {
      try {
        final response = await http.get(Uri.parse('$baseUrl/health'))
            .timeout(const Duration(seconds: 30)); // 30s for Render sleep
        return json.decode(response.body);
      } catch (e) {
        if (i == retries) return {'success': false, 'message': _getErrorMessage(e)};
        await Future.delayed(const Duration(seconds: 2)); // Wait before retry
      }
    }
    return {'success': false, 'message': 'Failed to reach server'};
  }

  // 1. Register
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'name': name, 'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': _getErrorMessage(e)};
    }
  }

  // 2. Email Login
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': _getErrorMessage(e)};
    }
  }

  // 3. Send OTP
  Future<Map<String, dynamic>> sendOtp(String phone) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/otp/send'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'phone': phone}),
      ).timeout(const Duration(seconds: 30));

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': _getErrorMessage(e)};
    }
  }

  // 4. Verify OTP
  Future<Map<String, dynamic>> verifyOtp(String phone, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/otp/verify'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'phone': phone, 'otp': otp}),
      ).timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': _getErrorMessage(e)};
    }
  }

  // --- HELPERS ---

  Map<String, dynamic> _handleResponse(http.Response response) {
    final data = json.decode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (data['token'] != null) {
        _saveAuthData(data['token'], data['user']['name']);
      }
      return {'success': true, 'user': data['user']};
    } else {
      return {'success': false, 'message': data['message'] ?? 'Error occurred'};
    }
  }

  String _getErrorMessage(dynamic e) {
    if (e.toString().contains('SocketException')) {
      return 'Cannot connect to server. Check IP in api_config.dart';
    } else if (e.toString().contains('TimeoutException')) {
      return 'Connection timed out. Server might be down.';
    }
    return 'Error: ${e.toString()}';
  }

  Future<void> _saveAuthData(String token, String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
    await prefs.setString('user_name', name);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_name') ?? 'SmartFruit User';
  }

  Future<bool> isLoggedIn() async {
    String? token = await getToken();
    return token != null;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.remove('user_name');
  }
}
