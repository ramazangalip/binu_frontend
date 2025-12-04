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
        const SnackBar(content: Text('Lütfen bir metin yazın veya dosya ekleyin!')),
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
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Yeni Gönderi Oluştur'),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Gönderi İçeriği
          _buildSectionTitle('Gönderi İçeriği'),
          const SizedBox(height: 8),
          TextField(
            controller: _textController,
            decoration: InputDecoration(
              hintText: 'Düşüncelerini, duyurularını veya sorularını buraya yaz...',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            maxLines: 5,
          ),
          const SizedBox(height: 24),

          // Kategori
          _buildSectionTitle('Kategori'),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            hint: const Text('Bir kategori seçin'),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            items: _categories.map((String category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Text(category),
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
          // Eğer dosya seçildiyse seçilen dosyayı göster, seçilmediyse butonu göster
          if (_pickedFile != null) 
            _buildSelectedFileCard()
          else
            OutlinedButton.icon(
              icon: Icon(Icons.attach_file, color: Colors.grey.shade700),
              label: Text(
                'Görsel veya Dosya Ekle (PDF, JPG, PNG)',
                style: TextStyle(color: Colors.grey.shade800),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: Colors.grey.shade400),
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
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: _sharePost,
          child: const Text('Paylaş', style: TextStyle(fontSize: 16)),
        ),
      ),
    );
  }

  // Seçilen dosyanın önizlemesini gösteren widget
  Widget _buildSelectedFileCard() {
    bool isImage = ['jpg', 'jpeg', 'png'].contains(_pickedFile!.extension?.toLowerCase());

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          // Dosya İkonu veya Küçük Resim
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
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
                : const Icon(Icons.insert_drive_file, color: Colors.blue),
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
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${(_pickedFile!.size / 1024).toStringAsFixed(1)} KB',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
          
          // Kaldır Butonu
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed: _removeFile,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
        color: Colors.black87,
      ),
    );
  }
}