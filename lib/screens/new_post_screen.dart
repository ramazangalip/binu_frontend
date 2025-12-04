import 'dart:io'; // Dosya işlemleri için
import 'package:file_picker/file_picker.dart'; // Dosya seçmek için
import 'package:flutter/material.dart';

class NewPostScreen extends StatefulWidget {
  const NewPostScreen({super.key});

  @override
  State<NewPostScreen> createState() => _NewPostScreenState();
}

class _NewPostScreenState extends State<NewPostScreen> {
  final TextEditingController _textController = TextEditingController();
  String? _selectedCategory;
  final List<String> _categories = ['Duyuru', 'Soru', 'Etkinlik', 'Genel'];
  
  // Seçilen dosyayı tutmak için değişkenler
  PlatformFile? _pickedFile;
  String? _filePath;

  // Dosya Seçme Fonksiyonu
  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'], // İzin verilen uzantılar
      );

      if (result != null) {
        setState(() {
          _pickedFile = result.files.first;
          _filePath = result.files.first.path;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Dosya seçilirken hata oluştu: $e")),
      );
    }
  }

  // Seçilen dosyayı kaldırma
  void _removeFile() {
    setState(() {
      _pickedFile = null;
      _filePath = null;
    });
  }

  void _sharePost() {
    if (_textController.text.trim().isEmpty && _pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lütfen bir metin yazın veya dosya ekleyin!')),
      );
      return;
    }

    // Yeni gönderi verisini bir Map olarak oluştur
    final newPostData = {
      'username': 'Sen',
      'title': _selectedCategory ?? 'Genel',
      'profilePic': 'https://i.pravatar.cc/150?img=12', // Varsayılan profil resmi
      'time': 'şimdi',
      // Eğer bir dosya seçildiyse onun yolunu, yoksa null gönder
      'image': null, // Şimdilik sadece frontend simülasyonu olduğu için null bırakıyoruz
      'filePath': _filePath, // Dosya yolunu ekledik (Backend'e gönderilirken kullanılır)
      'fileName': _pickedFile?.name, // Dosya adı
      'text': _textController.text.trim(),
      'likes': 0,
      'comments': 0,
      'shares': 0,
    };

    // Dosya seçildiyse kullanıcıya bilgi ver (Simülasyon)
    if (_pickedFile != null) {
      print("Seçilen Dosya: ${_pickedFile!.name} (Yol: $_filePath)");
    }

    // Sayfayı kapat ve veriyi HomeScreen'e geri gönder
    Navigator.pop(context, newPostData);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    
    return Scaffold(
      // Arka plan rengini temadan al
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Yeni Gönderi Oluştur'),
        // AppBar stili (renk ve elevation) AppTheme'dan otomatik gelir
        elevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Gönderi İçeriği
          _buildSectionTitle('Gönderi İçeriği', theme),
          const SizedBox(height: 8),
          TextField(
            controller: _textController,
            // InputDecoration stili AppTheme'dan geliyor.
            decoration: InputDecoration(
              hintText: 'Düşüncelerini, duyurularını veya sorularını buraya yaz...',
              // fillColor: Colors.white, kaldırıldı. AppTheme'dan geliyor.
              // border stili AppTheme'dan geliyor.
              // enabledBorder stili AppTheme'dan geliyor.
            ),
            maxLines: 5,
          ),
          const SizedBox(height: 24),

          // Kategori
          _buildSectionTitle('Kategori', theme),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            hint: Text('Bir kategori seçin', style: TextStyle(color: colorScheme.onSurfaceVariant)),
            // InputDecoration stili AppTheme'dan geliyor.
            decoration: const InputDecoration(
              // fillColor: Colors.white, kaldırıldı. AppTheme'dan geliyor.
              // border stili AppTheme'dan geliyor.
              // enabledBorder stili AppTheme'dan geliyor.
            ),
            items: _categories.map((String category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Text(
                  category,
                  // Metin rengini temadan al
                  style: TextStyle(color: colorScheme.onSurface), 
                ),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                _selectedCategory = newValue;
              });
            },
          ),
          const SizedBox(height: 24),

          // Görsel veya Dosya Ekle Butonu
          if (_pickedFile != null) 
            _buildSelectedFileCard(colorScheme)
          else
            OutlinedButton.icon(
              icon: Icon(
                Icons.attach_file, 
                // İkon rengini temadan al
                color: colorScheme.onSurfaceVariant,
              ),
              label: Text(
                'Görsel veya Dosya Ekle (PDF, JPG, PNG)',
                style: TextStyle(
                  // Metin rengini temadan al
                  color: colorScheme.onSurface, 
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                // Çerçeve rengini temadan al
                side: BorderSide(color: colorScheme.outline, width: 1), 
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _pickFile,
            ),
        ],
      ),
      
      // Paylaş Butonu
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          // Stil bloğu kaldırıldı. Bu sayede stil AppTheme'daki elevatedButtonTheme'dan gelecek.
          onPressed: _sharePost,
          child: Text(
            'Paylaş', 
            style: theme.textTheme.labelLarge?.copyWith(
              fontSize: 16,
              // Metin rengi ElevatedButtonTheme'dan otomatik gelir.
            ),
          ),
        ),
      ),
    );
  }

  // Seçilen dosyanın önizlemesini gösteren widget
  Widget _buildSelectedFileCard(ColorScheme colorScheme) {
    bool isImage = ['jpg', 'jpeg', 'png'].contains(_pickedFile!.extension?.toLowerCase());

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        // Kart arka planını temadan al
        color: colorScheme.surface, 
        borderRadius: BorderRadius.circular(12),
        // Çerçeve rengini temadan al
        border: Border.all(color: colorScheme.outlineVariant), 
      ),
      child: Row(
        children: [
          // Dosya İkonu veya Küçük Resim
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              // İkon/Placeholder arka planını temadan al
              color: colorScheme.primaryContainer.withOpacity(0.5), 
              borderRadius: BorderRadius.circular(8),
              image: isImage && _filePath != null
                  ? DecorationImage(
                      image: FileImage(File(_filePath!)),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: isImage && _filePath != null 
                ? null 
                : Icon(
                    Icons.insert_drive_file, 
                    // İkon rengini temadan al
                    color: colorScheme.primary,
                  ),
          ),
          const SizedBox(width: 12),
          
          // Dosya Adı ve Boyutu
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _pickedFile!.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  // Metin rengini temadan al
                  style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface), 
                ),
                Text(
                  // Dosya boyutu metin rengini temadan al
                  '${(_pickedFile!.size / 1024).toStringAsFixed(1)} KB',
                  style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
                ),
              ],
            ),
          ),
          
          // Kaldır Butonu
          IconButton(
            // Kapat ikon rengini temadan al (Hata/Danger rengi, Colors.red)
            icon: Icon(Icons.close, color: colorScheme.error), 
            onPressed: _removeFile,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Text(
      title,
      style: theme.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
        fontSize: 16,
        // Metin rengini temadan al
        color: theme.colorScheme.onSurface, 
      ),
    );
  }
}