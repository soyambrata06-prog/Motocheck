import 'package:flutter/material.dart';
import '../../routes/route_names.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AuthChoiceScreen extends StatelessWidget {
  const AuthChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),

              Center(
                child: Text(
                  'motocheck',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : Colors.black,
                    letterSpacing: -2,
                  ),
                ),
              ),
              const Spacer(flex: 2),

              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, RouteNames.login),
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
                  'Sign In', 
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => Navigator.pushNamed(context, RouteNames.signup),
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDark ? Colors.white : Colors.black,
                  side: BorderSide(
                    color: isDark ? Colors.white : Colors.black, 
                    width: 3.0
                  ),
                  minimumSize: const Size.fromHeight(64),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Create Account', 
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)
                ),
              ),
              
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(child: Divider(color: isDark ? Colors.white24 : Colors.black12, thickness: 2)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'OR CONTINUE WITH', 
                      style: TextStyle(
                        color: isDark ? Colors.white54 : Colors.black38, 
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        letterSpacing: 1.2,
                      )
                    ),
                  ),
                  Expanded(child: Divider(color: isDark ? Colors.white24 : Colors.black12, thickness: 2)),
                ],
              ),
              const SizedBox(height: 32),

              Row(
                children: [
                  Expanded(
                    child: _buildSocialButton(
                      onPressed: () {},
                      icon: FontAwesomeIcons.google,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSocialButton(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context, 
                          RouteNames.home, 
                          (route) => false,
                        );
                      },
                      icon: FontAwesomeIcons.apple,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required VoidCallback onPressed,
    required IconData icon,
    required bool isDark,
  }) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF121212) : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white24 : Colors.transparent,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: FaIcon(
              icon, 
              color: isDark ? Colors.white : Colors.black,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}

