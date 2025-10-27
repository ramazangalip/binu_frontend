import 'package:flutter/material.dart';


import 'package:image_picker/image_picker.dart'; 

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _bioController;

  @override
  void initState() {
    super.initState();
    // Mevcut kullanıcı verilerini controller'lara yükle (şimdilik statik)
    _nameController = TextEditingController(text: 'Mert Yılmaz');
    _usernameController = TextEditingController(text: '@mertyilmaz');
    _bioController = TextEditingController(text: 'Bilgisayar Bilimleri öğrencisi, teknoloji ve girişimcilik tutkunu. Yeni fikirler keşfetmeyi severim.');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }
  



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Profili Düzenle'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.blue),
            onPressed: () {
              // TODO: Değişiklikleri kaydetme mantığını buraya ekle
              Navigator.of(context).pop(); // Şimdilik sadece geri dön
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildProfilePictureEditor(),
              const SizedBox(height: 32),
              _buildTextFormField(
                controller: _nameController,
                labelText: 'Ad Soyad',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ad Soyad boş bırakılamaz.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _buildTextFormField(
                controller: _usernameController,
                labelText: 'Kullanıcı Adı',
                prefixText: '@',
                 validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kullanıcı Adı boş bırakılamaz.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _buildTextFormField(
                controller: _bioController,
                labelText: 'Bio',
                maxLines: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePictureEditor() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        const CircleAvatar(
          radius: 60,
          backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=12'),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: IconButton(
            icon: const Icon(Icons.edit, color: Colors.white, size: 20),
            onPressed: () {
              // _pickImage(); // Resim seçme fonksiyonunu çağır
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    String? prefixText,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: labelText,
        prefixText: prefixText,
        alignLabelWithHint: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
       validator: validator,
    );
  }
}
