import 'package:binu_frontend/components/app_bar.dart';
import 'package:binu_frontend/screens/forgot_password_screen.dart';
import 'package:binu_frontend/screens/main_screen.dart';
import 'package:binu_frontend/screens/register_screen.dart';
import 'package:binu_frontend/screens/verify_email_screen.dart'; // ✅ doğrulama ekranı
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ✅ Firebase eklendi

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false; 

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final auth = FirebaseAuth.instance;
      final UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final user = userCredential.user;

      if (user != null) {
        if (user.emailVerified) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Color(0xFF4CAF50),
              content: Text('Giriş başarılı! Hoş geldiniz 🎓'),
            ),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.orange,
              content: Text('Lütfen e-postanızı doğrulayın 📧'),
            ),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => VerifyEmailScreen()),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Bir hata oluştu.';
      if (e.code == 'user-not-found') {
        message = 'Kullanıcı bulunamadı.';
      } else if (e.code == 'wrong-password') {
        message = 'Şifre hatalı.';
      } else if (e.code == 'invalid-email') {
        message = 'Geçersiz e-posta adresi.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.red, content: Text(message)),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 60),
              const Text(
                "Giriş Yap",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),

              // 📧 E-posta alanı
              Container(
                width: 375,
                height: 70,
                margin: const EdgeInsets.only(left: 20, right: 20, top: 60),
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'E-posta adresi boş olamaz';
                    }

                    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                    if (!emailRegex.hasMatch(value)) {
                      return 'Geçerli bir e-posta giriniz';
                    }

                    if (!value.endsWith('@bingol.edu.tr')) {
                      return 'Sadece @bingol.edu.tr adresleri kabul edilir';
                    }

                    return null;
                  },
                ),
              ),

              // 🔒 Şifre alanı
              Container(
                width: 375,
                height: 50,
                margin: const EdgeInsets.only(left: 20, right: 20, top: 25),
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Şifre boş olamaz';
                    }
                    if (value.length < 6) {
                      return 'Şifre en az 6 karakter olmalı';
                    }
                    return null;
                  },
                ),
              ),

              // 🚀 Giriş butonu
              Container(
                width: 375,
                height: 50,
                margin: const EdgeInsets.only(left: 20, right: 20, top: 25),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all<Color>(
                      Colors.deepPurple.shade900,
                    ),
                    foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Giriş Yap"),
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Parolanızı mı unuttunuz? "),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ForgotPasswordScreen(),
                        ),
                      );
                    },
                    child: Text(
                      "Sıfırla",
                      style: TextStyle(color: Colors.deepPurple.shade900),
                    ),
                  ),
                ],
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Hesabınız yok mu? "),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: Text(
                      "Kayıt Ol",
                      style: TextStyle(color: Colors.deepPurple.shade900),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}