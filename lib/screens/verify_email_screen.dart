
// import 'package:flutter/material.dart';
// import 'login_screen.dart';

// class VerifyEmailScreen extends StatefulWidget {
//   const VerifyEmailScreen({super.key});

//   @override
//   State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
// }

// class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
//   User? _user;
//   bool _isEmailVerified = false;
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();

//     // Kullanıcı oturumu var mı kontrol et
//     final currentUser = FirebaseAuth.instance.currentUser;

//     if (currentUser == null) {
//       // ❌ Kullanıcı null (örneğin kayıt sonrası signOut yapılmış)
//       // Bu durumda login ekranına yönlendir
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => const LoginScreen()),
//         );
//       });
//     } else {
//       // ✅ Kullanıcı var, doğrulama durumunu kontrol et
//       _user = currentUser;
//       _checkEmailVerification();
//     }
//   }

//   // E-postanın doğrulanıp doğrulanmadığını kontrol eden fonksiyon
//   Future<void> _checkEmailVerification() async {
//     await _user!.reload(); // Firebase verisini yenile
//     final refreshedUser = FirebaseAuth.instance.currentUser;
//     setState(() {
//       _isEmailVerified = refreshedUser?.emailVerified ?? false;
//       _isLoading = false;
//     });
//   }

//   // Kullanıcı doğrulamamışsa tekrar mail gönderebilsin
//   Future<void> _resendVerificationEmail() async {
//     try {
//       await _user?.sendEmailVerification();
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Doğrulama e-postası yeniden gönderildi.'),
//           backgroundColor: Colors.green,
//         ),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Hata: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       // 🔄 Yüklenme ekranı
//       return const Scaffold(
//         body: Center(
//           child: CircularProgressIndicator(),
//         ),
//       );
//     }

//     if (_isEmailVerified) {
//       // ✅ E-posta doğrulanmışsa
//       return const Scaffold(
//         body: Center(
//           child: Text(
//             "E-posta adresiniz doğrulandı! Giriş yapabilirsiniz.",
//             style: TextStyle(fontSize: 18, color: Colors.green),
//             textAlign: TextAlign.center,
//           ),
//         ),
//       );
//     }

//     // ❌ E-posta doğrulanmamışsa
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("E-posta Doğrulama"),
//         backgroundColor: Colors.deepPurple.shade900,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(24.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.email_outlined, size: 80, color: Colors.deepPurple),
//             const SizedBox(height: 20),
//             Text(
//               "E-posta adresinize bir doğrulama bağlantısı gönderildi.\n"
//               "Lütfen gelen kutunuzu kontrol edin.",
//               style: const TextStyle(fontSize: 16),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 30),
//             ElevatedButton(
//               onPressed: _resendVerificationEmail,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.deepPurple.shade900,
//                 foregroundColor: Colors.white,
//               ),
//               child: const Text("Doğrulama E-postasını Tekrar Gönder"),
//             ),
//             const SizedBox(height: 15),
//             ElevatedButton(
//               onPressed: _checkEmailVerification,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.green.shade700,
//                 foregroundColor: Colors.white,
//               ),
//               child: const Text("Doğrulamayı Kontrol Et"),
//             ),
//             const SizedBox(height: 15),
//             TextButton(
//               onPressed: () async {
//                 await FirebaseAuth.instance.signOut();
//                 if (mounted) {
//                   Navigator.pushReplacement(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => const LoginScreen(),
//                     ),
//                   );
//                 }
//               },
//               child: const Text(
//                 "Çıkış Yap",
//                 style: TextStyle(color: Colors.red),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
