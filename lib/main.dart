import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'routes/route_names.dart';
import 'routes/app_routes.dart';

void main() {
  runApp(const MotoCheckApp());
}

class MotoCheckApp extends StatelessWidget {
  const MotoCheckApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MotoCheck',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: RouteNames.intro1,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
