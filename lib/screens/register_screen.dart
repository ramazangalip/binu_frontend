import 'package:binu_frontend/components/app_bar.dart';
import 'package:binu_frontend/screens/login_screen.dart';
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) {
      return; 
    }

    setState(() {
      _isLoading = true;
    });
    
  
    const int studentRoleId = 1; 

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
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
         message = "Sunucuya bağlanılamadı veya genel bir hata oluştu: ${e.toString()}";
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


  String? _emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'E-posta adresi boş olamaz';
    }
    final lower = value.toLowerCase().trim();
    if (!lower.endsWith('@bingol.edu.tr')) {
      return 'Sadece @bingol.edu.tr adresleri kabul edilir';
    }
    final parts = lower.split('@');
    if (parts.isEmpty || parts[0].isEmpty) {
      return 'Geçersiz e-posta adresi';
    }
    final studentNumberPart = parts[0];
    if (!studentNumberPart.contains('11610') && !studentNumberPart.contains('00510')) {
      return "Btmyo'ya ait bir öğrenci numarası değil";
    }
    return null;
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Şifre boş olamaz';
    }
    if (value.length < 6) {
      return 'Şifre en az 6 karakter olmalı';
    }
    return null;
  }

  String? _defaultValidator(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName boş bırakılamaz.';
    }
    return null;
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

              // Ad Soyad
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

              // Kullanıcı Adı
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


              // E-posta Alanı
              Container(
                width: 375,
                margin: const EdgeInsets.only(top: 25),
                child: TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                    prefixIcon: Icon(Icons.email_outlined),
                    labelText: 'Üniversite E-postanız',
                  ),
                  validator: _emailValidator, 
                ),
              ),

              // Şifre Alanı
              Container(
                width: 375,
                margin: const EdgeInsets.only(top: 25),
                child: TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                    prefixIcon: Icon(Icons.lock_outline),
                    labelText: 'Şifreniz',
                  ),
                  validator: _passwordValidator,
                ),
              ),

              // Kayıt Ol Butonu
              Container(
                width: 375,
                height: 50,
                margin: const EdgeInsets.only(top: 25),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _registerUser,
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                      Colors.deepPurple.shade900,
                    ),
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.white),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text("Kayıt Ol"),
                ),
              ),
              
              // Giriş Yap Linki
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Hesabınız var mı? ",
                  ),
                  TextButton(
                      onPressed: _isLoading ? null : () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginScreen()));
                      },
                      child: Text(
                        "Giriş Yap",
                        style: TextStyle(color: Colors.deepPurple.shade900),
                      )),
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