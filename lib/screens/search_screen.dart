import 'package:flutter/material.dart';
import 'package:binu_frontend/services/api_service.dart';
import 'package:binu_frontend/models/course_model.dart';
import 'package:binu_frontend/screens/course_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  
  String _query = '';
  String _selectedCategory = 'Tümü';
  bool _isLoading = true;
  
  List<Course> _fetchedCourses = [];
  List<String> _categories = ['Tümü'];

  @override
  void initState() {
    super.initState();
    _fetchCourses();
  }

  Future<void> _fetchCourses() async {
    // İşlem başlarken yükleniyor durumunu ayarla
    setState(() {
      _isLoading = true;
    });

    try {
      final courses = await _apiService.getCourses();
      
      // 🌟 ÖNEMLİ DÜZELTME: setState'ten önce mounted kontrolü
      if (!mounted) return; 

      final uniqueCategories = courses
          .map((c) => c.category ?? 'Diğer')
          .toSet()
          .toList();

      setState(() {
        _fetchedCourses = courses;
        _categories = ['Tümü', ...uniqueCategories];
        // _isLoading = false; // Finally bloğunda ele alıyoruz
      });
    } catch (e) {
      print("Kurs yükleme hatası: $e");
      
      // Hata durumunda da mounted kontrolü yap
      if (mounted) { 
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kurslar yüklenirken hata oluştu: ${e.toString()}')),
        );
        // _isLoading = false; // Finally bloğunda ele alıyoruz
      }
    } finally {
      // 🌟 CRITICAL: Hata olsa da olmasa da, widget mount edilmişse yükleniyor durumunu kapat
      if (mounted) { 
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  List<Course> get _filteredCourses {
    List<Course> courses = _fetchedCourses;
    
    if (_selectedCategory != 'Tümü') {
      courses = courses.where((course) => course.category == _selectedCategory).toList();
    }
    
    if (_query.isNotEmpty) {
      final queryLower = _query.toLowerCase();
      courses = courses.where((course) {
        final titleLower = course.courseName.toLowerCase();
        final codeLower = course.courseCode.toLowerCase();
        return titleLower.contains(queryLower) || codeLower.contains(queryLower);
      }).toList();
    }
    
    return courses;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        toolbarHeight: 0,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(theme, colorScheme),
            
            _buildCategoryFilters(theme, colorScheme),

            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
                  : _filteredCourses.isEmpty
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

  Widget _buildSearchBar(ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _query = value),
        decoration: InputDecoration(
          hintText: 'Dersler, konular veya kodlar ara...',
          prefixIcon: Icon(Icons.search, color: colorScheme.onSurface.withOpacity(0.6)),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

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
              selectedColor: colorScheme.primary,
              labelStyle: theme.textTheme.labelMedium?.copyWith(
                color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
              ),
              backgroundColor: colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: isSelected ? Colors.transparent : colorScheme.outlineVariant,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCourseCard(Course course, ThemeData theme, ColorScheme colorScheme) {
    final imageUrl = 'https://picsum.photos/seed/${course.courseCode}/600/400';
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CourseDetailScreen(courseId: course.courseid),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 2,
        shadowColor: colorScheme.shadow.withOpacity(theme.brightness == Brightness.light ? 0.1 : 0.4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                imageUrl,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 150,
                  color: colorScheme.surfaceVariant,
                  child: Center(
                    child: Icon(Icons.computer, color: colorScheme.onSurfaceVariant)
                  ),
                ),
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
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.courseName,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    course.description ?? 'Açıklama mevcut değil.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildTag(
                        course.courseCode,
                        colorScheme.primaryContainer,
                        colorScheme.onPrimaryContainer,
                        theme
                      ),
                      const SizedBox(width: 8),
                      _buildTag(
                        course.category ?? 'Genel',
                        colorScheme.surfaceVariant,
                        colorScheme.onSurfaceVariant,
                        theme
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
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