import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/user_provider.dart';
import 'features/auth/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase.initializeApp() removed for custom backend transition
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => UserProvider())],
      child: const SmartFruitApp(),
    ),
  );
}

class SmartFruitApp extends StatelessWidget {
  const SmartFruitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SmartFruit AI',
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
