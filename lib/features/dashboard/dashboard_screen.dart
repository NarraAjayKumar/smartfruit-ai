import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/animations/anti_gravity_widget.dart';
import '../../core/providers/user_provider.dart';
import '../../core/services/location_service.dart';
import '../../core/services/weather_service.dart';
import '../history/history_screen.dart';
import '../scan/scan_screen.dart';
import '../advisor/advisor_screen.dart';
import '../analytics/analytics_screen.dart';
import '../../core/widgets/debug_console.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  WeatherData? _weather;
  String _currentDistrict = "Detecting...";
  String _currentState = "";

  @override
  void initState() {
    super.initState();
    _loadWeather();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    final bool hasOnboarded = prefs.getBool('has_onboarded') ?? false;
    if (!hasOnboarded) {
      Future.delayed(const Duration(seconds: 1), () => _showOnboarding());
    }
  }

  void _showOnboarding() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AntiGravityWidget(
        amplitude: 15,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.green[50], shape: BoxShape.circle),
                child: const Icon(Icons.auto_awesome, color: Colors.green, size: 50),
              ),
              const SizedBox(height: 20),
              const Text("Welcome Farmer!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text(
                "Your SmartFruit AI is ready. Scan your crops, get advice, and track your harvest trends!",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, height: 1.5),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('has_onboarded', true);
                    Navigator.pop(context);
                  },
                  child: const Text("LET'S GO", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _loadWeather() async {
    try {
      // 1. Fetch real GPS and Address context
      final loc = await LocationService.getCurrentLocation();
      
      // 2. Fetch weather using lat/lon
      final weather = await WeatherService.getWeather(loc.latitude, loc.longitude);

      if (mounted) {
        setState(() {
          _weather = weather;
          _currentDistrict = loc.district;
          _currentState = loc.state;
        });
      }
    } catch (e) {
      debugPrint("Weather Load Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 10),
                  _buildSessionInfo(userProvider),
                  const SizedBox(height: 20),
                  _buildGreeting(context, userProvider),
                  const SizedBox(height: 30),
                  _buildLocationAndWeather(context, userProvider),
                  const SizedBox(height: 35),
                  _buildSectionTitle(context, "Agricultural Intelligence"),
                  const SizedBox(height: 15),
                  _buildAdvisorCard(context),
                  const SizedBox(height: 35),
                  _buildSectionTitle(context, "Active Crop Analysis"),
                  const SizedBox(height: 20),
                  _buildCropGrid(context),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onLongPress: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DebugConsole()),
            );
          },
          child: Image.asset('assets/images/logo.png', height: 50),
        ),
        Row(
          children: [
            IconButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AnalyticsScreen()),
              ),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.blue[50], shape: BoxShape.circle),
                child: const Icon(Icons.bar_chart_rounded, color: Colors.blue),
              ),
            ),
            IconButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistoryScreen()),
              ),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.history_rounded,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSessionInfo(UserProvider userProvider) {
    if (userProvider.lastLogin == null) return const SizedBox.shrink();
    final date = DateTime.parse(userProvider.lastLogin!);
    final formatted = DateFormat('MMM d, h:mm a').format(date);
    return Text(
      "Last Login: $formatted",
      style: TextStyle(color: Colors.grey[500], fontSize: 12),
    );
  }

  Widget _buildGreeting(BuildContext context, UserProvider userProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Happy Farming, ${userProvider.name.split(' ').first}!",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: Theme.of(context).primaryColor,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Let's predict your harvest outcome",
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationAndWeather(
    BuildContext context,
    UserProvider userProvider,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2E7D32),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on_rounded, color: Colors.white, size: 32),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$_currentDistrict${_currentState.isNotEmpty ? ', $_currentState' : ''}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _weather != null
                      ? "${_weather!.condition}, ${_weather!.temp.toInt()}°C"
                      : "Fetching weather...",
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          if (_weather != null)
            Icon(
              _getWeatherIcon(_weather!.icon),
              color: Colors.white,
              size: 30,
            ),
        ],
      ),
    );
  }

  IconData _getWeatherIcon(String name) {
    switch (name) {
      case 'wb_sunny_rounded':
        return Icons.wb_sunny_rounded;
      case 'cloud_queue_rounded':
        return Icons.cloud_queue_rounded;
      case 'water_drop_rounded':
        return Icons.water_drop_rounded;
      default:
        return Icons.wb_cloudy_rounded;
    }
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildCropGrid(BuildContext context) {
    final List<Map<String, dynamic>> cropData = [
      {
        "name": "Watermelon",
        "icon": Icons.water_drop_rounded,
        "image": "assets/images/watermelon.png",
        "isLocal": true,
        "status": "Ready",
        "delay": 0,
      },
      {
        "name": "Tomato",
        "icon": Icons.circle,
        "image": "assets/images/tomato.png",
        "isLocal": true,
        "status": "Ready",
        "delay": 200,
      },
      {
        "name": "Cucumber",
        "icon": Icons.eco_rounded,
        "image": "assets/images/cucumber.png",
        "isLocal": true,
        "status": "Ready",
        "delay": 400,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 0.8,
      ),
      itemCount: cropData.length,
      itemBuilder: (context, index) {
        final crop = cropData[index];
        return AntiGravityWidget(
          amplitude: 8,
          speed: Duration(seconds: 3 + index),
          delay: Duration(milliseconds: crop['delay']),
          child: InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ScanScreen(cropName: crop['name']),
              ),
            ),
            borderRadius: BorderRadius.circular(24),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade100),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    spreadRadius: 1,
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 3,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                      child: crop['isLocal'] == true
                          ? Image.asset(
                              crop['image'] as String,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    color: Colors.green.withValues(alpha: 0.1),
                                    child: Icon(
                                      crop['icon'] as IconData,
                                      size: 40,
                                      color: Colors.green,
                                    ),
                                  ),
                            )
                          : Image.network(
                              crop['image'] as String,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    color: Colors.green.withValues(alpha: 0.1),
                                    child: Icon(
                                      crop['icon'] as IconData,
                                      size: 40,
                                      color: Colors.green,
                                    ),
                                  ),
                            ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            crop['name'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6),
                          _buildStatusIndicator(context, crop['status']),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAdvisorCard(BuildContext context) {
    return AntiGravityWidget(
      amplitude: 10,
      child: InkWell(
        onTap: () {
          // Navigate to Advisor Screen (which is at index 1 in MainScreen)
          // For now, just show a Dialog or navigate directly if we want
          // Since we added it to bottom nav, we can just switch tabs or navigate.
          // Let's navigate directly for better UX from dashboard.
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AdvisorScreen()),
          );
        },
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Theme.of(context).primaryColor, const Color(0xFF1B5E20)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.psychology_rounded, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 15),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Chat with AI Advisor",
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Get expert farming tips instantly",
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(BuildContext context, String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status.toUpperCase(),
        style: const TextStyle(
          color: Colors.green,
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
