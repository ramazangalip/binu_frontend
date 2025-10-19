import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String query = '';

  // Örnek içerik listesi
  final List<Map<String, dynamic>> allPosts = [
    {'title': 'Doğa Yürüyüşü', 'category': 'Spor', 'image': 'https://picsum.photos/200?1'},
    {'title': 'Yeni Flutter Özellikleri', 'category': 'Teknoloji', 'image': 'https://picsum.photos/200?2'},
    {'title': 'Kahve Molası ☕', 'category': 'Yaşam', 'image': 'https://picsum.photos/200?3'},
    {'title': 'Kamp Günlüğü', 'category': 'Seyahat', 'image': 'https://picsum.photos/200?4'},
    {'title': 'Kedi Fotoğrafları', 'category': 'Hayvanlar', 'image': 'https://picsum.photos/200?5'},
    {'title': 'Bisiklet Turu', 'category': 'Spor', 'image': 'https://picsum.photos/200?6'},
    {'title': 'Yapay Zeka İle Sanat', 'category': 'Teknoloji', 'image': 'https://picsum.photos/200?7'},
  ];

  List<Map<String, dynamic>> get filteredPosts {
    if (query.isEmpty) return allPosts;
    return allPosts
        .where((p) =>
            p['title'].toLowerCase().contains(query.toLowerCase()) ||
            p['category'].toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Keşfet & Arama',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          // 🔍 Arama kutusu
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => query = value),
              decoration: InputDecoration(
                hintText: 'Kişi veya içerik ara...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // 🔥 Keşfet başlığı
          if (query.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 4, left: 16, bottom: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Senin için önerilen içerikler 🔥",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),

          // 📸 İçerik grid’i
          Expanded(
            child: filteredPosts.isEmpty
                ? const Center(child: Text("Sonuç bulunamadı 😔"))
                : GridView.builder(
                    padding: const EdgeInsets.all(10),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: filteredPosts.length,
                    itemBuilder: (context, index) {
                      final post = filteredPosts[index];
                      return GestureDetector(
                        onTap: () {
                          // Tıklanınca benzer içerikleri önerme simülasyonu
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  "${post['category']} kategorisinde benzer içerikler gösteriliyor..."),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: NetworkImage(post['image']),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: LinearGradient(
                                colors: [Colors.black.withOpacity(0.5), Colors.transparent],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            ),
                            child: Align(
                              alignment: Alignment.bottomLeft,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  post['title'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
