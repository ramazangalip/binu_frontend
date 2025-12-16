import 'dart:io'; // Dosya işlemleri için
import 'dart:convert'; // JSON decoding için
import 'package:file_picker/file_picker.dart'; // Dosya seçmek için
import 'package:flutter/material.dart';

import 'package:provider/provider.dart'; // Provider kullanmak için gerekli
import '../services/api_service.dart'; // ApiService import'u
import '../providers/auth_provider.dart'; // AuthProvider import'u

class NewPostScreen extends StatefulWidget {
  const NewPostScreen({super.key});

  @override
  State<NewPostScreen> createState() => _NewPostScreenState();
}

class _NewPostScreenState extends State<NewPostScreen> {
  final TextEditingController _textController = TextEditingController();
  String? _selectedCategory;
  
  // Tüm olası kategoriler (Backend'e uygun olmalı)
  final List<String> _allCategories = ['Duyuru', 'Soru', 'Etkinlik', 'Genel'];
  
  // Seçilen dosyayı tutmak için değişkenler
  PlatformFile? _pickedFile;
  String? _filePath;
  
  // Kullanıcının rolüne göre filtre uygulanmış kategori listesi
  List<String> _filteredCategories = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _filterCategoriesByRole();
  }
  
  // ------------------------------------------------------------------
  // 🎯 METOT: Role ID'ye göre kategori filtreleme
  // ------------------------------------------------------------------
  void _filterCategoriesByRole() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final int? roleId = authProvider.currentUser?.role?.roleid;
    
    List<String> categories = [];

    if (roleId == 1) { // Öğrenci
      categories = _allCategories
          .where((cat) => cat == 'Etkinlik' || cat == 'Genel')
          .toList();
    } else if (roleId == 2 || roleId == 3) { // Öğretmen veya İdareci
      categories = _allCategories;
    } else {
      categories = ['Genel'];
    }

    if (_selectedCategory != null && !categories.contains(_selectedCategory)) {
      _selectedCategory = null;
    }

    setState(() {
      _filteredCategories = categories;
    });
  }

  // Dosya Seçme Fonksiyonu
  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'],
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

  // ------------------------------------------------------------------
  // 🎯 KRİTİK GÜNCELLEME: İki Aşamalı Paylaşım Mantığı
  // ------------------------------------------------------------------
  void _sharePost() async {
    final apiService = ApiService();
    
    // 1. Validasyon
    final textEmpty = _textController.text.trim().isEmpty;

    if (textEmpty && _pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Metin veya dosya eklemelisin!')),
      );
      return;
    }
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bir kategori seçin!')),
      );
      return;
    }

    // Yükleme sırasında kullanıcıyı bilgilendir
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gönderi paylaşılıyor...')),
    );

    String? finalImageUrl;

    try {
      // 2. AŞAMA: Dosya Varsa, Önce Yükle ve URL'yi Al
      if (_filePath != null) {
        // Dosya yükleme başarılı değilse exception fırlatır
        finalImageUrl = await apiService.uploadImage(File(_filePath!));
        
        if (finalImageUrl == null) {
          // Bu durum, uploadImage'in null döndüğü ancak hata fırlatmadığı durumdur
          throw Exception('Dosya yüklendi ancak geçerli bir URL alınamadı.');
        }
      }

      // 3. AŞAMA: Post Verisini ve URL'yi Gönder
      // createPost metodu, artık File değil, URL bekler.
      final response = await apiService.createPost(
        text: _textController.text.trim(),
        category: _selectedCategory!,
        imageUrl: finalImageUrl, // Yüklenen URL'yi gönder
      );
      
      // 4. Başarılı İşlem
      // http.Response döndüğü için bodyBytes'ı decode edip gönderiyoruz
      final decodedBody = jsonDecode(response.body);
      Navigator.pop(context, decodedBody);

    } catch (e) {
      // Hata yönetimi
      String errorMessage = e.toString();
      
      // Hata mesajının başlığını temizle
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring('Exception: '.length);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $errorMessage')),
      );
    }
  }
  // ------------------------------------------------------------------


  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Yeni Gönderi Oluştur'),
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
            decoration: const InputDecoration(
              hintText: 'Düşüncelerini, duyurularını veya sorularını buraya yaz...',
            ),
            maxLines: 5,
          ),
          const SizedBox(height: 24),

          // Kategori (Filtrelenmiş Liste Kullanılıyor)
          _buildSectionTitle('Kategori', theme),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            hint: Text('Bir kategori seçin', style: TextStyle(color: colorScheme.onSurfaceVariant)),
            decoration: const InputDecoration(),
            items: _filteredCategories.map((String category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Text(
                  category,
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
                color: colorScheme.onSurfaceVariant,
              ),
              label: Text(
                'Görsel veya Dosya Ekle (PDF, JPG, PNG)',
                style: TextStyle(
                  color: colorScheme.onSurface,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
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
          onPressed: _sharePost,
          child: Text(
            'Paylaş',
            style: theme.textTheme.labelLarge?.copyWith(
              fontSize: 16,
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
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          // Dosya İkonu veya Küçük Resim
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
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
                  style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                ),
                Text(
                  '${(_pickedFile!.size / 1024).toStringAsFixed(1)} KB',
                  style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
                ),
              ],
            ),
          ),
          
          // Kaldır Butonu
          IconButton(
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
        color: theme.colorScheme.onSurface,
      ),
    );
  }
}