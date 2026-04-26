import 'package:flutter/material.dart';
import 'route_names.dart';
import '../shared/layout/base_screen.dart';
import '../features/check/result_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/signup_screen.dart';
import '../features/auth/auth_choice_screen.dart';
import '../features/onboarding/intro_screen_1.dart';
import '../features/onboarding/intro_screen_2.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> get routes => {
    RouteNames.intro1: (context) => const IntroScreen1(),
    RouteNames.intro2: (context) => const IntroScreen2(),
    RouteNames.authChoice: (context) => const AuthChoiceScreen(),
    RouteNames.login: (context) => const LoginScreen(),
    RouteNames.signup: (context) => const SignupScreen(),
    RouteNames.home: (context) => const BaseScreen(),
    RouteNames.result: (context) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      return ResultScreen(plateNumber: args?['plateNumber'] ?? 'N/A');
    },
  };

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.intro1:
        return MaterialPageRoute(builder: (_) => const IntroScreen1());
      case RouteNames.intro2:
        return MaterialPageRoute(builder: (_) => const IntroScreen2());
      case RouteNames.authChoice:
        return MaterialPageRoute(builder: (_) => const AuthChoiceScreen());
      case RouteNames.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case RouteNames.signup:
        return MaterialPageRoute(builder: (_) => const SignupScreen());
      case RouteNames.home:
        return MaterialPageRoute(builder: (_) => const BaseScreen());
      case RouteNames.result:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ResultScreen(plateNumber: args?['plateNumber'] ?? 'N/A'),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}

