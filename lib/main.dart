import 'package:binu_frontend/providers/auth_provider.dart';

import 'package:binu_frontend/providers/notification_provider.dart'; // 💡 Eklenecek
import 'package:binu_frontend/providers/post_providers.dart';
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
  
  // 🚀 KRİTİK DÜZELTME: MultiProvider Kullanımı
  runApp(
    MultiProvider(
      providers: [
        // 1. AuthProvider (Zaten vardı)
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        
        // 2. PostProvider (Genellikle Post'lar için en üstte tanımlanır)
        ChangeNotifierProvider(create: (context) => PostProvider()),
        
        // 3. NotificationProvider (Hata veren Provider)
        ChangeNotifierProvider(create: (context) => NotificationProvider()),
      ],
      // MultiProvider'ın child'ı olarak MyApp'i veriyoruz
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