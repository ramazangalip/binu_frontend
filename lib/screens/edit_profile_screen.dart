import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart'; // Resim seçme için gerekebilir

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
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    
    return Scaffold(
      // Arka plan rengini temadan al
      backgroundColor: theme.scaffoldBackgroundColor, 
      appBar: AppBar(
        title: const Text('Profili Düzenle'),
        centerTitle: true,
        // AppBar stili AppTheme'dan otomatik gelir
        elevation: 0.5,
        // İkon rengi temadan gelir
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.check, 
              // İkon rengini temadan al
              color: colorScheme.primary
            ),
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
              _buildProfilePictureEditor(colorScheme),
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
                theme: theme,
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
                theme: theme,
              ),
              const SizedBox(height: 20),
              _buildTextFormField(
                controller: _bioController,
                labelText: 'Bio',
                maxLines: 4,
                theme: theme,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePictureEditor(ColorScheme colorScheme) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          radius: 60,
          backgroundImage: const NetworkImage('https://i.pravatar.cc/150?img=12'),
          // Avatar placeholder rengini temadan al
          backgroundColor: colorScheme.surfaceVariant, 
        ),
        Container(
          decoration: BoxDecoration(
            // Arka plan rengini temadan al
            color: colorScheme.primary, 
            shape: BoxShape.circle,
            // Çerçeve rengini temadan al
            border: Border.all(color: colorScheme.background, width: 2), 
          ),
          child: IconButton(
            // İkon rengi temadan (onPrimary) alınır, genelde beyaz
            icon: Icon(Icons.edit, color: colorScheme.onPrimary, size: 20),
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
    required ThemeData theme,
    String? prefixText,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    // TextFormField'lar AppTheme'da tanımlanan InputDecorationTheme'ı kullanır.
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: labelText,
        prefixText: prefixText,
        alignLabelWithHint: true,
        // Border stili AppTheme'dan gelir.
        // Eğer AppTheme'da border tanımlanmamışsa, bu blok varsayılan olarak kullanılır.
        // Ama biz AppTheme'da tanımladığımız için bu satırları kaldırmalıyız.
        // Ancak bu fonksiyon TextFormfield'ları manuel oluşturduğu için:
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        // Odaklanma rengi temadan gelecek
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
        ),
        // Prefix metin stili
        prefixStyle: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        )
      ),
        validator: validator,
    );
  }
}