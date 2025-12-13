import 'package:binu_frontend/providers/auth_provider.dart';
import 'package:binu_frontend/theme/app_theme.dart';
import 'package:binu_frontend/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  // Flutter'ın widget'larını başlatmadan önce initializeDateFormatting'i çağırın
  WidgetsFlutterBinding.ensureInitialized(); 
  
  try {
      // Türkiye (Türkçe) yerel ayar verilerini başlat
      await initializeDateFormatting('tr', null);
  } catch (e) {
      print('Yerel veri başlatılırken hata oluştu: $e');
  }
  
  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Binu App',
      
      // Açık tema
      theme: AppTheme.lightTheme,
      
      // Koyu tema
      darkTheme: AppTheme.darkTheme,
      
      // Sistem temasını otomatik takip et
      themeMode: ThemeMode.system,
      
      // Uygulamanın başlangıç ekranı SplashScreen
      home: const SplashScreen(),
    );
  }
}