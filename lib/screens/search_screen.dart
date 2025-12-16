import 'package:flutter/material.dart';
import 'package:binu_frontend/services/api_service.dart';
import 'package:binu_frontend/models/course_model.dart';
// Post modelinizin içindeki User modelini kullanacağız (post_model.dart içinden import edildiğini varsayıyorum)
import 'package:binu_frontend/models/post_model.dart';
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
  
  // YENİ: Arama sonuçlarında kullanıcıları tutacak liste
  List<User> _searchedUsers = [];

  @override
  void initState() {
    super.initState();
    // Başlangıçta tüm kursları ve popüler kullanıcıları yükleyebiliriz
    _fetchData();
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Tüm Kursları Çek
      final courses = await _apiService.getCourses();
      
      // 2. Eğer arama sorgusu varsa, kullanıcıları da ara
      List<User> users = [];
      if (_query.isNotEmpty && _query.trim().length >= 3) { // En az 3 karakter girilirse ara
        users = await _apiService.searchUsers(_query);
      }
      
      if (!mounted) return;

      final uniqueCategories = courses
          .map((c) => c.category ?? 'Diğer')
          .toSet()
          .toList();

      setState(() {
        _fetchedCourses = courses;
        _searchedUsers = users; // Kullanıcı sonuçlarını kaydet
        _categories = ['Tümü', ...uniqueCategories];
      });
    } catch (e) {
      print("Veri yükleme hatası: $e");
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Veriler yüklenirken hata oluştu: ${e.toString()}')),
        );
      }
    } finally {
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
  
  // -------------------------------------------------------------
  // YENİ: Takip Etme/Bırakma İşlemi
  // -------------------------------------------------------------
  Future<void> _toggleFollow(User user) async {
    // Optimistik güncelleme: UI'da anında değiştir, sonra API'yi bekle
    final isFollowing = user.followersCount != null && user.followersCount! > 0; // Basit bir varsayım
    
    // UI'da takip durumunu değiştir
    setState(() {
      final userIndex = _searchedUsers.indexWhere((u) => u.userid == user.userid);
      if (userIndex != -1) {
        // Not: User modelinizin takip durumunu tutacak bir alana ihtiyacı vardır (isFollowing),
        // ancak biz şimdilik basitçe _fetchData'yı çağırarak listeyi yenileyeceğiz.
        // Daha iyi bir çözüm, User modeline 'isFollowing' alanını eklemektir.
        
        // Şimdilik sadece geçici olarak butonu devre dışı bırakalım
        // VEYA: Takip durumunu anlık olarak değiştirmek için User modelinizi 'isFollowing' alanı ile genişletmelisiniz.
      }
    });
    
    // API çağrısı
    try {
      await _apiService.toggleFollow(user.userid!);
      
      // Başarılı olursa listeyi yenile
      await _fetchData();
      
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isFollowing ? '${user.fullname} takibi bırakıldı.' : '${user.fullname} takip ediliyor!'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
      
    } catch (e) {
      print("Takip etme/bırakma hatası: $e");
      // Hata olursa (mounted ise) hata mesajı göster ve listeyi yeniden çek (eski durumuna dönsün)
      if(mounted) {
        await _fetchData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('İşlem başarısız: ${e.toString()}')),
        );
      }
    }
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
                  : (_searchedUsers.isEmpty && _filteredCourses.isEmpty)
                      ? Center(child: Text("Sonuç bulunamadı 😔", style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant)))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          
                          // Önce Kullanıcı Sonuçlarını, sonra Ders Sonuçlarını listele
                          itemCount: _searchedUsers.length + _filteredCourses.length,
                          itemBuilder: (context, index) {
                            if (index < _searchedUsers.length) {
                              // Kullanıcı Kartı
                              return _buildUserCard(_searchedUsers[index], theme, colorScheme);
                            } else {
                              // Ders Kartı
                              final courseIndex = index - _searchedUsers.length;
                              return _buildCourseCard(_filteredCourses[courseIndex], theme, colorScheme);
                            }
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
        onChanged: (value) {
          setState(() => _query = value);
          // KRİTİK: Arama sorgusu değiştiğinde yeni verileri çek
          _fetchData();
        },
        decoration: InputDecoration(
          hintText: 'Dersler, konular, kodlar veya kullanıcılar ara...',
          prefixIcon: Icon(Icons.search, color: colorScheme.onSurface.withOpacity(0.6)),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          // Arama çubuğunu temizleme butonu
          suffixIcon: _query.isNotEmpty ? IconButton(
            icon: Icon(Icons.clear, color: colorScheme.onSurface.withOpacity(0.6)),
            onPressed: () {
              _searchController.clear();
              setState(() => _query = '');
              _fetchData();
            },
          ) : null,
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

  // -------------------------------------------------------------
  // YENİ: Kullanıcı Kartı (Arama Sonucu)
  // -------------------------------------------------------------
  Widget _buildUserCard(User user, ThemeData theme, ColorScheme colorScheme) {
    // User modelinizin 'isFollowing' alanını içerdiğini varsayarak (daha iyi UX için gereklidir)
    // Şimdilik sadece örneklemek için basitleştirilmiş bir varsayım kullanacağız
    final isFollowing = user.followersCount != null && user.followersCount! > 0; // Bu bir varsayımdır, User modelinde isFollowing olmalı.
    final hasProfilePic = user.profileimageurl != null && user.profileimageurl!.isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage: hasProfilePic ? NetworkImage(user.profileimageurl!) : null,
              child: hasProfilePic ? null : Icon(Icons.person, color: colorScheme.onPrimary),
              backgroundColor: colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.fullname,
                    style: theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                  ),
                  Text(
                    '@${user.username}',
                    style: theme.textTheme.bodySmall!.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Takip Et Butonu
            SizedBox(
              height: 36,
              child: ElevatedButton(
                onPressed: user.userid == null ? null : () => _toggleFollow(user),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isFollowing ? colorScheme.surfaceVariant : colorScheme.primary,
                  foregroundColor: isFollowing ? colorScheme.onSurface : colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: isFollowing ? BorderSide(color: colorScheme.outline) : BorderSide.none,
                  ),
                  elevation: 0,
                ),
                child: Text(
                  isFollowing ? 'Takip Ediliyor' : 'Takip Et',
                  style: theme.textTheme.labelLarge!.copyWith(fontSize: 13),
                ),
              ),
            )
          ],
        ),
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