import 'package:binu_frontend/components/app_bar.dart';
import 'package:binu_frontend/screens/forgot_password_screen.dart';
import 'package:binu_frontend/screens/main_screen.dart';
import 'package:binu_frontend/screens/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:binu_frontend/providers/auth_provider.dart';

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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
    
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final success = await authProvider.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (success) {
        if (mounted) {
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: Color(0xFF4CAF50),
              content: Text('Giriş başarılı! Hoş geldiniz 🎓'),
            ),
          );

          // Ana ekrana yönlendir
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        }
      } else {
     
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.red,
              content: Text('Hata: E-posta veya şifre hatalı.'),
            ),
          );
        }
      }
    } catch (e) {
    
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
            content: Text('Sunucuya bağlanılamadı. Lütfen internet bağlantınızı kontrol edin.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
              
            
              Padding(
                padding: const EdgeInsets.only(right: 20.0, top: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Parolanızı mı unuttunuz?"),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
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
              ),

              // 🚀 Giriş butonu
              Container(
                width: 375,
                height: 50,
                margin: const EdgeInsets.only(left: 20, right: 20, top: 10),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                      Colors.deepPurple.shade900,
                    ),
                    foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white, 
                            strokeWidth: 2,
                          )
                        )
                      : const Text("Giriş Yap"),
                ),
              ),

              const SizedBox(height: 20),

             
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
              
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}