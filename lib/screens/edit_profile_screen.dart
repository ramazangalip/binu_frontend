import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart'; 
import 'dart:io'; 
import '../models/post_model.dart'; // User modelini almak için
import '../providers/auth_provider.dart';
import '../services/api_service.dart'; // ApiService'ı kullanmak için

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controller'lar
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _bioController;

  // Resim ve Durum Değişkenleri
  File? _pickedImageFile;
  late User _initialUser;
  bool _isSaving = false;
  String? _profileImageUrl;
  
  // YENİ: Değişiklik yapılıp yapılmadığını takip eder.
  bool _hasChanges = false; 

  // ApiService örneğini initState içinde başlatmak daha temizdir
  late final ApiService _apiService; 


  @override
  void initState() {
    super.initState();
    // ApiService örneğini başlat
    _apiService = ApiService(); 
    
    // Controller'ları başlat
    _nameController = TextEditingController();
    _usernameController = TextEditingController();
    _bioController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Veri çekme ve controller'ları doldurma
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    // Yalnızca ilk yüklemede veriyi set et
    if (user != null && _nameController.text.isEmpty) {
      _initialUser = user;
      _nameController.text = user.fullname;
      _usernameController.text = user.username;
      _bioController.text = (user.biography ?? ''); 
      _profileImageUrl = user.profileimageurl;
      
      // YENİ: Dinleyicileri ekle
      _nameController.addListener(_checkIfDataChanged);
      _usernameController.addListener(_checkIfDataChanged);
      _bioController.addListener(_checkIfDataChanged);
    }
  }

  // YENİ: Verinin değişip değişmediğini kontrol eden metot
 // GÜNCELLENMİŞ VE HATASIZ _checkIfDataChanged METODU
void _checkIfDataChanged() {
  // Eğer henüz ilk kullanıcı verisi yüklenmediyse (didChangeDependencies çalışmadıysa) çık.
  // _nameController boşsa, _initialUser muhtemelen set edilmemiştir.
  if (_nameController.text.isEmpty) { 
      return; 
  }
  
  // Not: Eğer _initialUser'ın null olma ihtimali varsa (late değilse), 
  // burada kontrol etmek gerekirdi. (late olduğu için şimdilik atlıyoruz)
  
  final bool currentlyHasChanges = 
      _nameController.text != _initialUser.fullname ||
      _usernameController.text != _initialUser.username ||
      _bioController.text != (_initialUser.biography ?? '') ||
      _pickedImageFile != null; // Yeni resim seçilmişse de değişiklik var demektir

  if (_hasChanges != currentlyHasChanges) {
    setState(() {
      _hasChanges = currentlyHasChanges;
    });
  }
}

  @override
  void dispose() {
    // YENİ: Dinleyicileri kaldır
    _nameController.removeListener(_checkIfDataChanged);
    _usernameController.removeListener(_checkIfDataChanged);
    _bioController.removeListener(_checkIfDataChanged);
    
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }
  
  // -----------------------------------------------------
  // 1. Resim Seçme İşlevi (Kamera/Galeri)
  // -----------------------------------------------------
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 70);

    if (pickedFile != null) {
      setState(() {
        _pickedImageFile = File(pickedFile.path);
        _hasChanges = true; // YENİ: Resim seçimi de değişiklik demektir
      });
    }
  }

  // -----------------------------------------------------
  // 2. Kaydetme İşlevi (Backend'e Bağlantı)
  // -----------------------------------------------------
  // lib/screens/edit_profile_screen.dart dosyası

// ... (Mevcut kod)

// -----------------------------------------------------
// 2. Kaydetme İşlevi (Backend'e Bağlantı)
// -----------------------------------------------------
Future<void> _saveChanges() async {
  if (!_formKey.currentState!.validate()) {
    return;
  }

  setState(() => _isSaving = true);
  final apiService = ApiService();
  final authProvider = Provider.of<AuthProvider>(context, listen: false);

  try {
    final newFullName = _nameController.text;
    final newUsername = _usernameController.text;
    final newBio = _bioController.text;
    
    String? finalImageUrl;

    // CRITICAL FIX: Yeni resim seçilmişse, önce resmi sunucuya yükle.
    if (_pickedImageFile != null) {
      // 1. Resim yükleme servisini çağır
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil resmi yükleniyor...')),
      );
      finalImageUrl = await apiService.uploadImage(_pickedImageFile!); // Yeni metodu çağır
    }

    // 2. Profil bilgilerini ve varsa yeni URL'yi güncelleme
    await apiService.updateProfile(
      fullName: newFullName,
      username: newUsername,
      biography: newBio,
      // Eğer resim yüklendi ve URL döndüyse, bu URL'yi göndeririz.
      // Yüklenmediyse (null ise), backend profileImageUrl'i güncellemez.
      profileImageUrl: finalImageUrl, 
    );

    // AuthProvider'daki kullanıcı verisini, backend'den güncelleyerek tekrar çek
    // Bu, EditProfileScreen'in güncel veriye sahip olmasını sağlar
    await authProvider.checkAuthStatus(); 

    // Başarılı mesaj göster
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profil başarıyla güncellendi!')),
    );

    // Geri dön
    Navigator.of(context).pop();

  } catch (e) {
    // Profil güncelleme veya resim yükleme hatası
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Hata: Profil güncellenemedi veya resim yüklenirken hata oluştu. ${e.toString()}')),
    );
  } finally {
    setState(() => _isSaving = false);
  }
}

  // -----------------------------------------------------
  // 3. UI Bileşenleri ve Yapı
  // -----------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, 
      appBar: AppBar(
        title: const Text('Profili Düzenle'),
        centerTitle: true,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          _isSaving
              ? Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.primary),
                    ),
                  ),
                )
              // YENİ: Kaydetme düğmesi
              : IconButton(
                  icon: Icon(
                    Icons.check, 
                    // YENİ: Değişiklik varsa primary renk, yoksa soluk renk kullan
                    color: _hasChanges 
                        ? colorScheme.primary 
                        : colorScheme.onSurfaceVariant.withOpacity(0.5),
                  ),
                  // YENİ: Yalnızca değişiklik varsa kaydetme metodunu çağır
                  onPressed: _hasChanges ? _saveChanges : null, 
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
    // Avatar resmi kaynağını belirle
    Widget avatarImage;
    if (_pickedImageFile != null) {
      avatarImage = Image.file(_pickedImageFile!, fit: BoxFit.cover);
    } else if (_profileImageUrl != null && _profileImageUrl!.isNotEmpty) {
      avatarImage = Image.network(_profileImageUrl!, fit: BoxFit.cover, errorBuilder: (c, o, s) => Icon(Icons.person, size: 50, color: colorScheme.onSurfaceVariant));
    } else {
      avatarImage = Icon(Icons.person, size: 50, color: colorScheme.onSurfaceVariant);
    }

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          radius: 60,
          // Avatarı yerel dosya veya network URL'den göster
          backgroundColor: colorScheme.surfaceVariant, 
          child: ClipOval(
            child: SizedBox(
              width: 120,
              height: 120,
              child: avatarImage,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.primary, 
            shape: BoxShape.circle,
            border: Border.all(color: colorScheme.background, width: 2), 
          ),
          child: IconButton(
            icon: Icon(Icons.edit, color: colorScheme.onPrimary, size: 20),
            onPressed: () => _showImageSourceDialog(context), // Dialogu aç
          ),
        ),
      ],
    );
  }
  
  // -----------------------------------------------------
  // 4. Resim Kaynağı Seçim Diyaloğu
  // -----------------------------------------------------
  void _showImageSourceDialog(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library, color: colorScheme.primary),
                title: const Text('Galeriden Seç'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt, color: colorScheme.primary),
                title: const Text('Kamera ile Çek'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
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
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
        ),
        prefixStyle: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        )
      ),
      validator: validator,
    );
  }
}