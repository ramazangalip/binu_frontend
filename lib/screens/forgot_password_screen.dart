import 'package:binu_frontend/components/app_bar.dart';
import 'package:binu_frontend/screens/login_screen.dart';
import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
      // Arka plan rengini temadan al
      backgroundColor: theme.scaffoldBackgroundColor, 
      appBar: const CustomAppBar(), // CustomAppBar'ın kendi içinde temaya uyumlu olması gerekir.
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Şifrenizi Sıfırlayın",
                style: theme.textTheme.headlineMedium?.copyWith(
                  // Metin rengini temadan al
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 15),

              Text(
                "Üniversite e-posta adresinizi girin, şifre sıfırlama bağlantısını size gönderelim.",
                style: theme.textTheme.bodyMedium?.copyWith(
                  // Metin rengini temadan al
                  color: colorScheme.onSurfaceVariant, 
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 25),

              // TextFormField, AppTheme'daki inputDecorationTheme'ı kullanacak
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  // fillColor AppTheme'dan geliyor (Colors.grey[100] veya Colors.grey[800])
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    // İkon rengini temadan al
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                  hintText: "ogrenci mailinizi giriniz.",
                  hintStyle: TextStyle(
                    // Hint metin rengini temadan al
                    color: colorScheme.onSurfaceVariant,
                  ),
                  // border ve focusedBorder stilleri AppTheme'dan gelir,
                  // ancak FocusedBorder'da elle atanmış renkleri dinamikleştirelim.
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    // Odaklandığında ana rengi kullan
                    borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
                  ),
                ),

                // 🔹 validator artık Form ile çalışır
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'E-posta adresi boş olamaz';
                  }

                  final emailRegex = RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  );
                  if (!emailRegex.hasMatch(value)) {
                    return 'Geçerli bir e-posta adresi giriniz';
                  }

                  // Sadece @bingol.edu.tr kabul et
                  if (!value.endsWith('@bingol.edu.tr')) {
                    return 'Sadece @bingol.edu.tr adresleri kabul edilir';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 25),

              // ℹ️ Bilgilendirme Kutusu
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  // Arka plan rengini temadan al (primaryContainer: açık modda açık mavi/mor, koyu modda koyu mavi/mor)
                  color: colorScheme.primaryContainer.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                  // Çerçeve rengini temadan al
                  border: Border.all(color: colorScheme.primary, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Bilgilendirme",
                      style: theme.textTheme.bodyLarge?.copyWith(
                        // Başlık rengini temadan al
                        color: colorScheme.primary, 
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Şifre sıfırlama bağlantısı e-posta adresinize gönderilecektir. "
                      "Lütfen gelen kutunuzu (ve spam klasörünüzü) kontrol etmeyi unutmayın.",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        // İçerik metin rengini temadan al
                        color: colorScheme.onSurface, 
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Gönder Butonu
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  // Stil bloğu kaldırıldı. Bu sayede stil AppTheme'dan gelecek.
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Snackbar renkleri dinamikleştirildi
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          behavior: SnackBarBehavior.floating,
                          // Başarı rengi için Green (Vurgu rengi değil, genel başarı rengi)
                          backgroundColor: Colors.green, 
                          content: Text(
                            'Sıfırlama bağlantısı e-posta adresinize gönderildi',
                            // Metin rengi, yeşil üzerinde kontrast renk
                            style: TextStyle(color: Colors.white), 
                          ),
                        ),
                      );
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen()),
                      );
                    }
                  },
                  child: Text(
                    "Sıfırlama Bağlantısı Gönder",
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      // Metin rengi temadan (onPrimary) otomatik gelecek, bu satır kaldırılsın.
                      // color: Colors.white, 
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}