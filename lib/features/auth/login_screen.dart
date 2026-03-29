import 'package:flutter/material.dart';
import '../../core/services/custom_auth_service.dart';
import '../../core/constants/app_constants.dart';
import '../dashboard/main_screen.dart';
import 'signup_screen.dart';
import 'otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _usePhoneLogin = false;
  bool? _isServerOnline;

  @override
  void initState() {
    super.initState();
    _checkServerStatus();
  }

  Future<void> _checkServerStatus() async {
    final authService = CustomAuthService();
    final res = await authService.checkHealth();
    if (mounted) {
      setState(() => _isServerOnline = res['success']);
    }
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Quick re-check before login if offline
    if (_isServerOnline == false) {
      await _checkServerStatus();
      if (_isServerOnline == false) {
        _showError("Server is still unreachable. Check your IP!");
        return;
      }
    }

    setState(() => _isLoading = true);
    try {
      final authService = CustomAuthService();
      
      if (_usePhoneLogin) {
        final res = await authService.sendOtp(_phoneController.text.trim());
        if (mounted) {
          if (res['success']) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OtpScreen(phone: _phoneController.text.trim()),
              ),
            );
          } else {
            _showError(res['message']);
          }
        }
      } else {
        final result = await authService.login(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        if (mounted) {
          if (result['success']) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const MainScreen()),
              (route) => false,
            );
          } else {
            _showError(result['message']);
          }
        }
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 48),
                Image.asset('assets/images/logo.png', height: 100),
                const SizedBox(height: 32),
                Text(
                  _usePhoneLogin ? "Phone Login" : "Welcome Back",
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "Login to your ${AppConstants.appName} account",
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                ),
                const SizedBox(height: 16),
                
                // Connection Status Indicator
                GestureDetector(
                  onTap: _checkServerStatus,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isServerOnline == null ? Colors.orange : (_isServerOnline! ? Colors.green : Colors.red),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isServerOnline == null ? "Waking up server (Wait 30s)..." : (_isServerOnline! ? "Server Online" : "Server Offline (Tap to Retry)"),
                        style: TextStyle(
                          fontSize: 12, 
                          fontWeight: FontWeight.bold,
                          color: _isServerOnline == null ? Colors.orange : (_isServerOnline! ? Colors.green : Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),

                if (!_usePhoneLogin) ...[
                  _buildTextField(
                    controller: _emailController,
                    label: "Email Address",
                    icon: Icons.email_outlined,
                    validator: (v) => (v?.isEmpty ?? true) ? "Enter email" : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _passwordController,
                    label: "Password",
                    icon: Icons.lock_outline,
                    isPassword: true,
                    obscureText: !_isPasswordVisible,
                    onToggleVisibility: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                    validator: (v) => (v?.isEmpty ?? true) ? "Enter password" : null,
                  ),
                ] else
                  _buildTextField(
                    controller: _phoneController,
                    label: "Phone Number",
                    icon: Icons.phone_android_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (v) => (v?.length ?? 0) < 10 ? "Enter valid phone" : null,
                  ),

                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(_usePhoneLogin ? "SEND OTP" : "LOGIN", 
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),

                const SizedBox(height: 24),
                
                TextButton(
                  onPressed: () => setState(() => _usePhoneLogin = !_usePhoneLogin),
                  child: Text(
                    _usePhoneLogin ? "Login with Email instead" : "Login with Phone (OTP) instead",
                    style: const TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.w600),
                  ),
                ),

                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("New to ${AppConstants.appName}? ", style: TextStyle(color: Colors.grey.shade600)),
                    TextButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SignupScreen())),
                      child: const Text("Sign Up", style: TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF2E7D32)),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                onPressed: onToggleVisibility,
              )
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }
}
