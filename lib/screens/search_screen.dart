import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String _selectedCategory = 'Tümü';
  final List<Map<String, dynamic>> _allCourses = [
    {
      'title': 'Diferansiyel Denklemler',
      'description': 'Mühendislik ve fen bilimlerinde uygulamalarıyla',
      'image': 'https://images.unsplash.com/photo-1581092921434-098d3a044398?w=500&q=80',
      'type': 'Belge',
      'tags': ['Matematik I'],
      'category': 'Matematik',
    },
    {
      'title': 'Kuantum Fiziği Temelleri',
      'description': 'Kuantum mekaniğinin temel prensipleri ve...',
      'image': 'https://placehold.co/600x400/e2e8f0/e2e8f0', // Placeholder
      'type': 'Video',
      'tags': ['Fizik II'],
      'category': 'Fizik',
    },
    {
      'title': 'Python ile Veri Yapıları',
      'description': 'Temel veri yapıları ve algoritmaların Python programlama...',
      'image': 'https://images.unsplash.com/photo-1555949963-ff9fe0c870eb?w=500&q=80',
      'type': 'Belge',
      'tags': ['Bilgisayar Bilimi Giriş'],
      'category': 'Bilgisayar Bilimi',
    },
    {
      'title': 'Dünya Edebiyatında Modernizm',
      'description': '20. yüzyıl ve sonrası dünya edebiyatındaki ana akımlar.',
      'image': 'https://images.unsplash.com/photo-1532012197267-da84d127e765?w=500&q=80',
      'type': 'Belge',
      'tags': ['Edebiyat Tarihi'],
      'category': 'Edebiyat',
    },
    {
      'title': 'Osmanlı İmparatorluğu',
      'description': 'Osmanlı İmparatorluğu\'nun kuruluşu, yükselişi ve...',
      'image': 'https://images.unsplash.com/photo-1618829519096-7b83f0db7344?w=500&q=80',
      'type': 'Video',
      'tags': ['Tarih I'],
      'category': 'Tarih',
    },
    {
      'title': 'Makroekonominin Temeli',
      'description': 'Gayri Safi Yurt İçi Hasıla, enflasyon ve işsizlik gibi...',
      'image': 'https://images.unsplash.com/photo-1600427145926-58379b32ca4f?w=500&q=80',
      'type': 'Belge',
      'tags': ['Ekonomi I'],
      'category': 'Ekonomi',
    },
  ];


  final List<String> _categories = ['Tümü', 'Matematik', 'Fizik', 'Bilgisayar Bilimi', 'Edebiyat', 'Tarih', 'Ekonomi'];
  List<Map<String, dynamic>> get _filteredCourses {
    List<Map<String, dynamic>> courses = _allCourses;
    if (_selectedCategory != 'Tümü') {
      courses = courses.where((course) => course['category'] == _selectedCategory).toList();
    }
    if (_query.isNotEmpty) {
      courses = courses.where((course) {
        final titleLower = course['title'].toLowerCase();
        final descriptionLower = course['description'].toLowerCase();
        final queryLower = _query.toLowerCase();
        return titleLower.contains(queryLower) || descriptionLower.contains(queryLower);
      }).toList();
    }
    
    return courses;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Arama Kutusu
            _buildSearchBar(),
            
            // Kategori Filtreleri
            _buildCategoryFilters(),

            // İçerik Listesi
            Expanded(
              child: _filteredCourses.isEmpty
                  ? const Center(child: Text("Sonuç bulunamadı 😔"))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: _filteredCourses.length,
                      itemBuilder: (context, index) {
                        return _buildCourseCard(_filteredCourses[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Arama Kutusu Widget'ı
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _query = value),
        decoration: InputDecoration(
          hintText: 'Dersler, konular veya öğretmenler ara...',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
      ),
    );
  }

  // Kategori Filtreleri Widget'ı
  Widget _buildCategoryFilters() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedCategory = category;
                  });
                }
              },
              selectedColor: Colors.deepPurple.shade900,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
              ),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: isSelected ? Colors.transparent : Colors.grey.shade300),
              ),
            ),
          );
        },
      ),
    );
  }

  // Ders Kartı Widget'ı
  Widget _buildCourseCard(Map<String, dynamic> course) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      shadowColor: Colors.grey.withOpacity(0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kart Resmi
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              course['image'],
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 150,
                color: Colors.grey.shade200,
                child: const Center(child: Icon(Icons.image_not_supported, color: Colors.grey)),
              ),
            ),
          ),
          // Kart İçeriği
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course['title'],
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  course['description'],
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildTag(course['type'], Colors.blue.shade50, Colors.blue.shade800),
                    const SizedBox(width: 8),
                    ...(course['tags'] as List<String>).map((tag) => 
                      _buildTag(tag, Colors.grey.shade200, Colors.grey.shade800)
                    ).toList(),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }


  Widget _buildTag(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
