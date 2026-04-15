import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme_provider.dart';
import 'screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MotoCheckApp(),
    ),
  );
}

class MotoCheckApp extends StatelessWidget {
  const MotoCheckApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'MotoCheck',
          debugShowCheckedModeBanner: false,
          themeMode: themeProvider.themeMode,
          theme: ThemeData(
            useMaterial3: true,
            scaffoldBackgroundColor: Colors.white,
            fontFamily: 'Inter',
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.black,
              primary: Colors.black,
              secondary: Colors.black,
              surface: Colors.white,
              onSurface: Colors.black,
              brightness: Brightness.light,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFF121212),
            fontFamily: 'Inter',
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF20C997),
              primary: const Color(0xFF20C997),
              secondary: const Color(0xFF20C997),
              surface: const Color(0xFF1E1E1E),
              onSurface: Colors.white,
              brightness: Brightness.dark,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF121212),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
          ),
          home: const OnboardingScreen(),
        );
      },
    );
  }
}
