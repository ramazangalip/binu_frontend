import 'package:binu_frontend/components/app_bar.dart';
import 'package:binu_frontend/screens/login_screen.dart';
// Modalları import ediyoruz
import 'package:binu_frontend/screens/modals/kvkk_policy_dialog.dart';
import 'package:binu_frontend/screens/modals/user_agreement_dialog.dart';
import 'package:binu_frontend/screens/modals/data_processing_policy_dialog.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:binu_frontend/providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController(); 
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  
  // 3 Ayrı Onay Durumu
  bool _isKvkkAccepted = false;
  bool _isUserAgreementAccepted = false;
  bool _isDataPolicyAccepted = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  // Modal Gösterici Yardımcı Fonksiyonlar
  void _showKvkkDialog() {
    showDialog(
      context: context,
      builder: (context) => KvkkPolicyDialog(
        onAccepted: () => setState(() => _isKvkkAccepted = true),
      ),
    );
  }

  void _showUserAgreementDialog() {
    showDialog(
      context: context,
      builder: (context) => UserAgreementDialog(
        onAccepted: () => setState(() => _isUserAgreementAccepted = true),
      ),
    );
  }

  void _showDataPolicyDialog() {
    showDialog(
      context: context,
      builder: (context) => DataProcessingPolicyDialog(
        onAccepted: () => setState(() => _isDataPolicyAccepted = true),
      ),
    );
  }

  Future<void> _registerUser() async {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    // 1. Form Validasyonu
    if (!_formKey.currentState!.validate()) {
      return; 
    }

    // 2. Sözleşme Onay Kontrolü
    if (!_isKvkkAccepted || !_isUserAgreementAccepted || !_isDataPolicyAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          // Hata rengini temadan al
          backgroundColor: colorScheme.error,
          content: Text(
            'Lütfen tüm sözleşmeleri okuyup onaylayınız.', 
            style: TextStyle(color: colorScheme.onError)
          ),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });
    
    // Sabit Rol ID'si: 1 (Öğrenci)
    const int studentRoleId = 1; 

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Kayıt İsteği
      final success = await authProvider.register(
        _emailController.text.trim(), 
        _usernameController.text.trim(), 
        _fullNameController.text.trim(), 
        _passwordController.text.trim(), 
        studentRoleId
      );

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              behavior: SnackBarBehavior.floating,
              // Başarı rengi
              backgroundColor: Colors.green,
              content: Text(
                'Kayıt başarılı! Şimdi giriş yapabilirsiniz.',
                style: TextStyle(color: Colors.white)
              ),
            ),
          );
          
          // Başarılı kayıt sonrası direkt LoginScreen'e yönlendir (Doğrulama yok)
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      } 

    } on Exception catch (e) {
      String message = 'Kayıt başarısız oldu.';
      final errorString = e.toString().toLowerCase();
      
      if (errorString.contains('already used') || errorString.contains('unique constraint')) {
          message = "Bu kullanıcı adı veya e-posta zaten kayıtlı.";
      } else if (errorString.contains('length')) {
          message = "Şifre çok kısa veya alanlar hatalı.";
      } else {
          message = "Hata: ${e.toString().replaceAll('Exception:', '')}";
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            // Hata rengini temadan al
            backgroundColor: colorScheme.error,
            content: Text(
              message,
              style: TextStyle(color: colorScheme.onError)
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Validator fonksiyonları
  String? _emailValidator(String? value) {
    if (value == null || value.isEmpty) return 'E-posta adresi boş olamaz';
    final lower = value.toLowerCase().trim();
    if (!lower.endsWith('@bingol.edu.tr')) return 'Sadece @bingol.edu.tr adresleri kabul edilir';
    final parts = lower.split('@');
    if (parts.isEmpty || parts[0].isEmpty) return 'Geçersiz e-posta adresi';
    final studentNumberPart = parts[0];
    if (!studentNumberPart.contains('11610') && !studentNumberPart.contains('00510')) return "Btmyo'ya ait bir öğrenci numarası değil";
    return null;
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) return 'Şifre boş olamaz';
    if (value.length < 6) return 'Şifre en az 6 karakter olmalı';
    return null;
  }

  String? _defaultValidator(String? value, String fieldName) {
    if (value == null || value.isEmpty) return '$fieldName boş bırakılamaz.';
    return null;
  }

  // Yardımcı Widget: Sözleşme Checkbox Satırı
  Widget _buildAgreementCheckbox({
    required bool value,
    required ValueChanged<bool?> onChanged,
    required String text,
    required VoidCallback onTap,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final ThemeData theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.only(top: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 24,
            width: 24,
            child: Checkbox(
              value: value,
              // Checkbox aktif rengini temadan al
              activeColor: colorScheme.primary,
              onChanged: onChanged,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: RichText(
                text: TextSpan(
                  // Varsayılan metin stili temadan al
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.4, 
                    color: colorScheme.onSurface,
                  ),
                  children: [
                    TextSpan(
                      text: text,
                      style: TextStyle(
                        // Link rengini temadan al
                        color: colorScheme.primary, 
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    // Kalan metin için onSurface rengini kullan
                    TextSpan(text: "'nı okudum ve kabul ediyorum.", 
                      style: TextStyle(color: colorScheme.onSurface)
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    
    return Scaffold(
      // Scaffold arka planı varsayılan olarak temadan gelir.
      appBar: const CustomAppBar(),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 60),
                child: Text(
                  "Kayıt Ol",
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontSize: 30, 
                    fontWeight: FontWeight.bold,
                    // Metin rengini temadan al
                    color: colorScheme.onSurface, 
                  ),
                ),
              ),
              
              // Form Alanları (AppTheme'daki inputDecorationTheme'ı kullanacak)
              Container(
                width: 375,
                margin: const EdgeInsets.only(top: 60),
                child: TextFormField(
                  controller: _fullNameController,
                  // InputDecoration stili AppTheme'dan geliyor.
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.person_outline),
                    labelText: 'Ad Soyad',
                  ),
                  validator: (value) => _defaultValidator(value, 'Ad Soyad'),
                ),
              ),
              Container(
                width: 375,
                margin: const EdgeInsets.only(top: 25),
                child: TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.alternate_email),
                    labelText: 'Kullanıcı Adı',
                  ),
                  validator: (value) => _defaultValidator(value, 'Kullanıcı Adı'),
                ),
              ),
              Container(
                width: 375,
                margin: const EdgeInsets.only(top: 25),
                child: TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.email_outlined),
                    labelText: 'Üniversite E-postanız',
                  ),
                  validator: _emailValidator, 
                ),
              ),
              Container(
                width: 375,
                margin: const EdgeInsets.only(top: 25),
                child: TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.lock_outline),
                    labelText: 'Şifreniz',
                  ),
                  validator: _passwordValidator,
                ),
              ),

              // 3 AYRI SÖZLEŞME KUTUSU
              _buildAgreementCheckbox(
                value: _isKvkkAccepted,
                onChanged: (val) => setState(() => _isKvkkAccepted = val ?? false),
                text: "KVKK Aydınlatma Metni",
                onTap: _showKvkkDialog,
              ),
              _buildAgreementCheckbox(
                value: _isUserAgreementAccepted,
                onChanged: (val) => setState(() => _isUserAgreementAccepted = val ?? false),
                text: "Kullanıcı Sözleşmesi",
                onTap: _showUserAgreementDialog,
              ),
              _buildAgreementCheckbox(
                value: _isDataPolicyAccepted,
                onChanged: (val) => setState(() => _isDataPolicyAccepted = val ?? false),
                text: "Veri İşleme Politikası",
                onTap: _showDataPolicyDialog,
              ),

              // Kayıt Ol Butonu
              Container(
                width: 375,
                height: 50,
                margin: const EdgeInsets.only(top: 25),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _registerUser,
                  // Stil bloğu kaldırıldı. Bu sayede stil AppTheme'daki elevatedButtonTheme'dan gelecek.
                  child: _isLoading
                      ? SizedBox(
                          width: 20, 
                          height: 20, 
                          child: CircularProgressIndicator(
                            // Yüklenme göstergesi rengini temadan al
                            color: colorScheme.onPrimary, 
                            strokeWidth: 2
                          )
                        )
                      : const Text("Kayıt Ol"),
                ),
              ),
              
              // Giriş Yap Linki
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Hesabınız var mı? ",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      // Metin rengini temadan al
                      color: colorScheme.onSurface, 
                    ),
                  ),
                  TextButton(
                      onPressed: _isLoading ? null : () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()));
                      },
                      // TextButton rengi temadan otomatik (primary) gelir
                      child: const Text("Giriş Yap")
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}