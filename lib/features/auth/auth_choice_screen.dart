import 'package:flutter/material.dart';
import 'widgets/auth_button.dart';
import '../../routes/route_names.dart';

class AuthChoiceScreen extends StatelessWidget {
  const AuthChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.motorcycle,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 24),
              const Text(
                'MotoCheck',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Your ultimate motorcycle companion',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),
              AuthButton(
                text: 'Sign In',
                onPressed: () {
                  Navigator.pushNamed(context, RouteNames.login);
                },
              ),
              const SizedBox(height: 16),
              AuthButton(
                text: 'Create Account',
                onPressed: () {
                  Navigator.pushNamed(context, RouteNames.signup);
                },
                isOutline: true,
              ),
              const SizedBox(height: 40),
              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('OR', style: TextStyle(color: Colors.grey)),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, RouteNames.home);
                },
                child: const Text('Continue as Guest'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
