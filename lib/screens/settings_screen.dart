// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:image_picker/image_picker.dart';

// class SettingsScreen extends StatefulWidget {
//   const SettingsScreen({super.key});

//   @override
//   State<SettingsScreen> createState() => _SettingsScreenState();
// }

// class _SettingsScreenState extends State<SettingsScreen> {
//   File? _selectedImage;
//   final ImagePicker _picker = ImagePicker();

//   Future<void> _pickImage() async {
//     final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         _selectedImage = File(pickedFile.path);
//       });

//       // TODO: İstersen buraya Firebase Storage’a yükleme kodu ekleyebiliriz.
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final user = FirebaseAuth.instance.currentUser;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Ayarlar"),
//         centerTitle: true,
//         backgroundColor: Colors.deepPurple,
//       ),
//       body: ListView(
//         children: [
//           const SizedBox(height: 20),

//           // 👤 Profil Alanı
//           Center(
//             child: Column(
//               children: [
//                 Stack(
//                   children: [
//                     CircleAvatar(
//                       radius: 55,
//                       backgroundColor: Colors.deepPurple.shade100,
//                       backgroundImage: _selectedImage != null
//                           ? FileImage(_selectedImage!)
//                           : const AssetImage('assets/default_avatar.png')
//                               as ImageProvider,
//                     ),
//                     Positioned(
//                       bottom: 0,
//                       right: 0,
//                       child: InkWell(
//                         onTap: _pickImage,
//                         child: Container(
//                           padding: const EdgeInsets.all(6),
//                           decoration: const BoxDecoration(
//                             color: Colors.deepPurple,
//                             shape: BoxShape.circle,
//                           ),
//                           child: const Icon(Icons.edit, color: Colors.white, size: 20),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 10),
//                 Text(
//                   user?.email ?? "Kayıtlı kullanıcı bulunamadı",
//                   style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//                 ),
//               ],
//             ),
//           ),

//           const SizedBox(height: 20),
//           const Divider(),

//           // 🌗 Tema Ayarı
//           SwitchListTile(
//             title: const Text("Koyu Tema"),
//             secondary: const Icon(Icons.dark_mode),
//             value: false,
//             onChanged: (val) {},
//           ),

//           // 🔔 Bildirim Ayarları
//           SwitchListTile(
//             title: const Text("Bildirimleri Aç"),
//             secondary: const Icon(Icons.notifications),
//             value: true,
//             onChanged: (val) {},
//           ),

//           // 🔒 Şifre Değiştir
//           ListTile(
//             leading: const Icon(Icons.lock),
//             title: const Text("Şifreyi Değiştir"),
//             trailing: const Icon(Icons.arrow_forward_ios, size: 18),
//             onTap: () {},
//           ),

//           // 📞 Destek
//           ListTile(
//             leading: const Icon(Icons.help_outline),
//             title: const Text("Yardım & Destek"),
//             trailing: const Icon(Icons.arrow_forward_ios, size: 18),
//             onTap: () {},
//           ),

//           const Divider(),

//           // 🚪 Çıkış Yap
//           ListTile(
//             leading: const Icon(Icons.logout, color: Colors.red),
//             title: const Text(
//               "Çıkış Yap",
//               style: TextStyle(color: Colors.red),
//             ),
//             onTap: () async {
//               await FirebaseAuth.instance.signOut();
//               if (context.mounted) {
//                 Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
//               }
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }