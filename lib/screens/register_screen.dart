import 'package:binu_frontend/components/app_bar.dart';
import 'package:binu_frontend/screens/login_screen.dart';
import 'package:binu_frontend/screens/main_screen.dart';

import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 60),
              child: const Text(
                "Kayıt Ol",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
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
                    return 'Geçerli bir e-posta adresi giriniz';
                  }

                  // Sadece @bingol.edu.tr kabul et
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
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // E-posta ve şifre doğruysa buraya düşer
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          behavior: SnackBarBehavior.floating,
                          
                        backgroundColor: Color(0xFF4CAF50),
                          content: Text('Kayıt başarılı! Hoş geldiniz 🎓')),
                    );

                    
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => MainScreen()),
                    );
                  }
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all<Color>(
                    Colors.deepPurple.shade900,
                  ),
                  foregroundColor:
                      WidgetStateProperty.all<Color>(Colors.white),
                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                child: const Text("Kayıt Ol"),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              
              children: [
                Text(
                  "Hesabınız var mı? ",),
                  TextButton(onPressed: () {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
                  }, 
                  child: Text(
                    "Giriş Yap",
                    style: TextStyle(color: Colors.deepPurple.shade900),
                  )
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
