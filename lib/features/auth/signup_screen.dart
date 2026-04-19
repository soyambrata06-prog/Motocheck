import 'package:flutter/material.dart';
import '../../routes/route_names.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new, color: isDark ? Colors.white : Colors.black),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                'Create\nAccount',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : Colors.black,
                  height: 1.1,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Join MotoCheck community',
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white54 : Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 40),
              _buildInputField(
                isDark: isDark,
                icon: FontAwesomeIcons.user,
                hint: 'Full Name',
              ),
              const SizedBox(height: 20),
              _buildInputField(
                isDark: isDark,
                icon: FontAwesomeIcons.envelope,
                hint: 'Email Address',
              ),
              const SizedBox(height: 20),
              _buildInputField(
                isDark: isDark,
                icon: FontAwesomeIcons.lock,
                hint: 'Password',
                isPassword: true,
                obscureText: _obscurePassword,
                onToggleVisibility: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.pushReplacementNamed(context, RouteNames.home),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? Colors.white : Colors.black,
                  foregroundColor: isDark ? Colors.black : Colors.white,
                  minimumSize: const Size.fromHeight(64),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Create Account', 
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'By signing up, you agree to our Terms of Service and Privacy Policy.',
                style: TextStyle(
                  color: isDark ? Colors.white38 : Colors.black38, 
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pushReplacementNamed(context, RouteNames.login),
                  child: RichText(
                    text: TextSpan(
                      text: "Already have an account? ",
                      style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 16),
                      children: [
                        TextSpan(
                          text: 'Sign In',
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required bool isDark,
    required IconData icon,
    required String hint,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF121212) : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white24 : Colors.transparent,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          FaIcon(icon, color: isDark ? Colors.white54 : Colors.black54, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              obscureText: obscureText,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  color: isDark ? Colors.white24 : Colors.black26, 
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          if (isPassword)
            IconButton(
              onPressed: onToggleVisibility,
              icon: FaIcon(
                obscureText ? FontAwesomeIcons.eyeSlash : FontAwesomeIcons.eye,
                color: isDark ? Colors.white54 : Colors.black54,
                size: 18,
              ),
            ),
        ],
      ),
    );
  }
}
