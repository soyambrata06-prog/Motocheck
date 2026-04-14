import 'package:flutter/material.dart';
import '../../routes/route_names.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.black),
              ),
              const SizedBox(height: 24),
              const Text(
                'Sign In',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              _buildInputField(
                icon: Icons.person_outline,
                hint: 'Name',
              ),
              const SizedBox(height: 16),
              _buildInputField(
                icon: Icons.email_outlined,
                hint: 'Email',
                suffix: const Icon(Icons.visibility_off_outlined, color: Colors.black38, size: 20),
              ),
              const SizedBox(height: 16),
              _buildInputField(
                icon: Icons.lock_outline,
                hint: 'Password',
                trailing: TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Forgot password?',
                    style: TextStyle(color: Colors.black45, fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.pushReplacementNamed(context, RouteNames.home),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Sign In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 24),
              const Text(
                'By signing up, you agree to our Terms of Service and Privacy Policy.',
                style: TextStyle(color: Colors.black54, fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account? ', style: TextStyle(color: Colors.black54)),
                    GestureDetector(
                      onTap: () {
                        // Navigate to Sign Up
                        Navigator.pushReplacementNamed(context, RouteNames.signup);
                      },
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required IconData icon,
    required String hint,
    Widget? suffix,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.black45, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
                border: InputBorder.none,
              ),
            ),
          ),
          if (suffix != null) suffix,
          if (trailing != null) trailing,
        ],
      ),
    );
  }
}
