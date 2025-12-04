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
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    
    return Scaffold(
      // Arka plan rengini temadan al
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        // AppBar'ın rengi ve stili AppTheme'dan otomatik gelir
        toolbarHeight: 0,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Arama Kutusu
            _buildSearchBar(theme, colorScheme),
            
            // Kategori Filtreleri
            _buildCategoryFilters(theme, colorScheme),

            // İçerik Listesi
            Expanded(
              child: _filteredCourses.isEmpty
                  // Metin rengi temadan gelecek
                  ? Center(child: Text("Sonuç bulunamadı 😔", style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant))) 
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: _filteredCourses.length,
                      itemBuilder: (context, index) {
                        return _buildCourseCard(_filteredCourses[index], theme, colorScheme);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Arama Kutusu Widget'ı
  Widget _buildSearchBar(ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _query = value),
        // Decoration stili AppTheme'dan geliyor.
        decoration: InputDecoration(
          hintText: 'Dersler, konular veya öğretmenler ara...',
          prefixIcon: Icon(Icons.search, color: colorScheme.onSurface.withOpacity(0.6)),
          // fillColor, border ve enabledBorder stilleri AppTheme'dan geliyor.
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  // Kategori Filtreleri Widget'ı
  Widget _buildCategoryFilters(ThemeData theme, ColorScheme colorScheme) {
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
              // Seçili renk temadan çekilecek (primary)
              selectedColor: colorScheme.primary, 
              labelStyle: theme.textTheme.labelMedium?.copyWith(
                // Seçili metin rengi temadan çekilecek (onPrimary)
                color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
              ),
              // Arka plan rengi temadan çekilecek (surface)
              backgroundColor: colorScheme.surface, 
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  // Seçili değilken çerçeve rengi temadan çekilecek
                  color: isSelected ? Colors.transparent : colorScheme.outlineVariant,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Ders Kartı Widget'ı
  Widget _buildCourseCard(Map<String, dynamic> course, ThemeData theme, ColorScheme colorScheme) {
    return Card(
      // Kart rengi ve gölge CardTheme'dan otomatik gelir.
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shadowColor: colorScheme.shadow.withOpacity(theme.brightness == Brightness.light ? 0.1 : 0.4),
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
                // Hata arka planı temadan al
                color: colorScheme.surfaceVariant, 
                child: Center(
                  // Hata ikonu rengi temadan al
                  child: Icon(Icons.image_not_supported, color: colorScheme.onSurfaceVariant)
                ),
              ),
              // Yüklenirken de temaya uygun bir renk gösterilebilir
              loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 150,
                    color: colorScheme.surfaceVariant,
                    child: Center(child: CircularProgressIndicator(color: colorScheme.primary)),
                  );
              },
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
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: 18, 
                    fontWeight: FontWeight.bold,
                    // Başlık metin rengini temadan al
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  course['description'],
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 14, 
                    // Açıklama metin rengini temadan al
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    // Tip etiketi (Mavi)
                    _buildTag(
                      course['type'], 
                      colorScheme.primaryContainer, 
                      colorScheme.onPrimaryContainer,
                      theme
                    ),
                    const SizedBox(width: 8),
                    // Etiketler (Gri)
                    ...(course['tags'] as List<String>).map((tag) => 
                      _buildTag(
                        tag, 
                        colorScheme.surfaceVariant, 
                        colorScheme.onSurfaceVariant,
                        theme
                      )
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


  Widget _buildTag(String text, Color bgColor, Color textColor, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}