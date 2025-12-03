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
    // 1. Form Validasyonu
    if (!_formKey.currentState!.validate()) {
      return; 
    }

    // 2. Sözleşme Onay Kontrolü
    if (!_isKvkkAccepted || !_isUserAgreementAccepted || !_isDataPolicyAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
          content: Text('Lütfen tüm sözleşmeleri okuyup onaylayınız.'),
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
      // Backend, e-posta adresine göre bölümü otomatik atayacaktır.
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
              backgroundColor: Color(0xFF4CAF50),
              content: Text('Kayıt başarılı! Şimdi giriş yapabilirsiniz.'),
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
            backgroundColor: Colors.red,
            content: Text(message),
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
              activeColor: Colors.deepPurple.shade900,
              onChanged: onChanged,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 14, height: 1.4, color: Colors.black87),
                  children: [
                    TextSpan(
                      text: text,
                      style: TextStyle(
                        color: Colors.deepPurple.shade900,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    const TextSpan(text: "'nı okudum ve kabul ediyorum."),
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
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 60),
                child: const Text(
                  "Kayıt Ol",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ),
              
              // Form Alanları (Ad Soyad, Kullanıcı Adı, E-posta, Şifre)
              Container(
                width: 375,
                margin: const EdgeInsets.only(top: 60),
                child: TextFormField(
                  controller: _fullNameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
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
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
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
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
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
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
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
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.deepPurple.shade900),
                    foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text("Kayıt Ol"),
                ),
              ),
              
              // Giriş Yap Linki
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Hesabınız var mı? "),
                  TextButton(
                      onPressed: _isLoading ? null : () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()));
                      },
                      child: Text("Giriş Yap", style: TextStyle(color: Colors.deepPurple.shade900))),
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