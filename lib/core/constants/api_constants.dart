class ApiConstants {
  // Use 10.0.2.2 for Android Emulator to access localhost
  // Use 192.168.x.x (your local IP) for physical devices
  static const String baseUrl = 'http://10.0.2.2:5000/api/auth';
  
  // Endpoint paths
  static const String register = '/register';
  static const String login = '/login';
  static const String profile = '/profile';
}
