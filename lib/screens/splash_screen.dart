import 'dart:async';
import 'package:binu_frontend/screens/login_screen.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToLogin();
  }

  /// 3 saniye bekledikten sonra direkt LoginScreen'e yönlendirir.
  void _navigateToLogin() {
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        // Kontrol yapmadan doğrudan LoginScreen'e git
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    
    return Scaffold(
      // Arka plan rengini temadan al
      backgroundColor: theme.scaffoldBackgroundColor, 
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo (varsayalım ki logo koyu modda da görünür)
            Image.asset(
              'assets/images/logo.png',
              width: 200,
              // Gerekirse koyu modda renk filtrelemesi yapılabilir, ancak şimdilik varsayıyoruz.
            ),
            const SizedBox(height: 24),
            // Yükleme göstergesi ekleyelim
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                // Rengi temadan al
                color: colorScheme.primary, 
                strokeWidth: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}