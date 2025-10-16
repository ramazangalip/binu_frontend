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

  void _sharePost() {
    if (_textController.text.trim().isEmpty) {
      // Kullanıcıya bir uyarı gösterilebilir
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gönderi içeriği boş olamaz!')),
      );
      return;
    }

    // Yeni gönderi verisini bir Map olarak oluştur
    final newPostData = {
      'username': 'Sen', // Bu bilgi daha sonra kullanıcı verisinden alınabilir
      'title': _selectedCategory ?? 'Genel', // Kategori seçilmemişse varsayılan
      'profilePic': 'https://picsum.photos/50/50?random=10',
      'time': 'şimdi',
      'image': null, // Görsel ekleme işlevi eklendiğinde bu güncellenir
      'text': _textController.text.trim(),
      'likes': 0,
      'comments': 0,
      'shares': 0,
    };

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

          // Görsel veya Dosya Ekle
          // Not: Bu buton şimdilik sadece görseldir.
          // İşlevsellik için image_picker gibi bir paket gerekir.
          OutlinedButton.icon(
            icon: Icon(Icons.add_photo_alternate_outlined, color: Colors.grey.shade700),
            label: Text(
              'Görsel veya Dosya Ekle',
              style: TextStyle(color: Colors.grey.shade800),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: Colors.grey.shade400),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              // TODO: Görsel seçme işlevini buraya ekle
            },
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