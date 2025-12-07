import 'dart:io'; 
import 'dart:convert'; // JSON işlemleri için eklendi
import 'package:http/http.dart' as http; // HTTP istekleri için eklendi
import 'package:binu_frontend/screens/course_detail_screen.dart';
import 'package:binu_frontend/screens/leaderboard_screen.dart';
import 'package:binu_frontend/screens/new_post_screen.dart';
import 'package:binu_frontend/screens/post_detail_screen.dart';
import 'package:binu_frontend/screens/reports_screen.dart';
import 'package:binu_frontend/screens/search_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  
  // -----------------------------------------------------------------
  // ⚙️ BACKEND ENTEGRASYONU İÇİN GEREKLİ ALANLAR
  // -----------------------------------------------------------------
  List<Map<String, String>> _fetchedPopularCourses = []; 
  bool _isLoadingCourses = true; 
  
  // Django sunucunuzun temel adresi (Emulator için 10.0.2.2)
  static const String _baseUrl = 'http://10.0.2.2:8000/api/'; 
  // -----------------------------------------------------------------

  final List<Map<String, dynamic>> posts = [
    {
      'username': 'Ayşe Yıldız',
      'title': 'Bilgisayar Mühendisliği',
      'profilePic': 'https://picsum.photos/50/50?random=1',
      'time': '2 saat önce',
      'image': 'https://picsum.photos/400/250?1',
      'text':
          'Yapılan son hackathon\'dan anılar... Harika bir deneyimdi!',
      'likes': 124,
      'comments': 32,
      'shares': 5,
      'filePath': null, 
      'fileName': null, 
    },
    {
      'username': 'Mehmet Demir',
      'title': 'Makine Mühendisliği',
      'profilePic': 'https://picsum.photos/50/50?random=2',
      'time': '3 saat önce',
      'image': 'https://picsum.photos/400/250?2',
      'text':
          'Yeni laboratuvar çalışmamız tamamlandı. Çok yakında denemelere başlıyoruz.',
      'likes': 22,
      'comments': 1,
      'shares': 2,
      'filePath': null, 
      'fileName': null, 
    },
    {
      'username': 'Zeynep Kara',
      'title': 'Endüstri Mühendisliği',
      'profilePic': 'https://picsum.photos/50/50?random=3',
      'time': '5 saat önce',
      'image': null,
      'text': 'Öğle yemeği molası! Kampüs kafeteryasından selamlar 👋',
      'likes': 15,
      'comments': 3,
      'shares': 1,
      'filePath': null, 
      'fileName': null, 
    },
  ];
  
  @override
  void initState() {
    super.initState();
    _fetchPopularCourses();
  }

  // -----------------------------------------------------------------
  // API'den Popüler Kurs Verilerini Çeken Metot (GÜNCELLENDİ)
  // -----------------------------------------------------------------
  Future<void> _fetchPopularCourses() async {
    setState(() {
      _isLoadingCourses = true;
    });

    try {
      // CourseViewSet için standart URL: /courses/
      final response = await http.get(Uri.parse('${_baseUrl}courses/')); 
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(utf8.decode(response.bodyBytes));
        
        final List<Map<String, String>> courses = jsonList.map((item) {
          
          final teacherData = item['teacher'];
          String instructorName = "Öğretmen Yok";
          if (teacherData != null && teacherData is Map && teacherData.containsKey('fullname')) {
            instructorName = teacherData['fullname'] as String;
          }
          
          return {
            'id': item['courseid'].toString(),    // Course Detail için gerekli ID
            'code': item['coursecode'] as String,    // Django Model: coursecode
            'title': item['coursename'] as String,  // Django Model: coursename
            'instructor': instructorName,           // Django Serializer: teacher.fullname
          };
        }).toList();

        setState(() {
          _fetchedPopularCourses = courses;
        });

      } else {
        print('Kurslar yüklenirken hata oluştu. Durum kodu: ${response.statusCode}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Popüler kurslar yüklenemedi. Sunucu hatası.')),
          );
        }
      }
    } catch (e) {
      print('Ağ hatası: $e');
      if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sunucuya bağlanılamadı. Backend adresini kontrol edin.')),
          );
        }
    } finally {
      setState(() {
        _isLoadingCourses = false; // Yükleme bitti
      });
    }
  }
  
  // -----------------------------------------------------------------
  // WIDGET BUILD METODU
  // -----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 🔍 Arama Kutusu
          TextField(
            decoration: InputDecoration(
              hintText: "Kurs ara...",
              prefixIcon: Icon(
                Icons.search,
                color: colorScheme.onSurface.withOpacity(0.6), 
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            ),
          ),
          const SizedBox(height: 16),

          // 🧑‍🤝‍🧑 Takip Ettiklerin
          _buildSectionTitle("Takip Ettiklerin", theme, colorScheme),
          const SizedBox(height: 8),
          ...posts.map((post) => _buildPostCard(post, theme, colorScheme)).toList(),
          const SizedBox(height: 20),

          // 💻 Popüler Kurslar (DİNAMİK BÖLÜM)
          _buildSectionTitle("Popüler Kurslar", theme, colorScheme, isSearchable: true),
          const SizedBox(height: 12),
          SizedBox(
            height: 130,
            child: _isLoadingCourses
                ? Center(child: CircularProgressIndicator(color: colorScheme.primary)) 
                : _fetchedPopularCourses.isEmpty 
                    ? Center(child: Text("Popüler kurs bulunamadı.", style: TextStyle(color: colorScheme.onSurfaceVariant))) 
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _fetchedPopularCourses.length,
                        itemBuilder: (context, index) {
                          return _buildSingleCourseCard(context, _fetchedPopularCourses[index], theme, colorScheme);
                        },
                      ),
          ),
          const SizedBox(height: 20),

          _buildScoreCard(theme, colorScheme),
          const SizedBox(height: 8),
          _buildProjectStatusCard(theme, colorScheme),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: colorScheme.secondary,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NewPostScreen()),
          );
          if (result != null && result is Map<String, dynamic>) {
            setState(() {
              posts.insert(0, {
                'username': result['username'] ?? 'Sen',
                'title': result['title'] ?? 'Genel',
                'profilePic': result['profilePic'] ?? 'https://i.pravatar.cc/150?img=12',
                'time': result['time'] ?? 'şimdi',
                'image': result['image'], 
                'filePath': result['filePath'], 
                'fileName': result['fileName'], 
                'text': result['text'],
                'likes': result['likes'] ?? 0,
                'comments': result['comments'] ?? 0,
                'shares': result['shares'] ?? 0,
              });
            });
          }
        },
        child: Icon(Icons.add, color: colorScheme.onSecondary),
      ),
    );
  }
  
  // -----------------------------------------------------------------
  // YARDIMCI WIDGET METOTLARI
  // -----------------------------------------------------------------

  Widget _buildSectionTitle(String title, ThemeData theme, ColorScheme colorScheme, {bool isSearchable = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: theme.textTheme.headlineMedium?.copyWith(fontSize: 17),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => isSearchable ? const SearchScreen() : const LeaderboardScreen(),
              ),
            );
          },
          child: Text(
            "Tümünü Gör",
            style: TextStyle(color: colorScheme.primary),
          ),
        )
      ],
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post, ThemeData theme, ColorScheme colorScheme) {
     final hasFile = post['filePath'] != null && post['fileName'] != null;
    final isImageFile = hasFile && 
                        (post['fileName'].toString().toLowerCase().endsWith('.jpg') ||
                         post['fileName'].toString().toLowerCase().endsWith('.jpeg') ||
                         post['fileName'].toString().toLowerCase().endsWith('.png'));

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostDetailScreen(postData: post),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(post['profilePic']!),
                    backgroundColor: colorScheme.surfaceVariant, 
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post['username'],
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: colorScheme.onSurface, 
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer, 
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          post['title']!,
                          style: TextStyle(
                            fontSize: 11,
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            
            if (post['image'] != null) ...[ 
              _buildNetworkImage(post['image'], colorScheme),
            ] else if (hasFile) ...[
              if (isImageFile) 
                _buildLocalImage(post['filePath'], colorScheme)
              else
                _buildFileDownloadCard(post['fileName'], post['filePath'], colorScheme, theme),
            ],

            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                post['text'],
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontSize: 16,
                  color: colorScheme.onSurface, 
                  height: 1.5,
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _buildActionIcon(Icons.thumb_up_alt_outlined, colorScheme),
                      const SizedBox(width: 4),
                      Text('${post['likes']}',
                          style: TextStyle(color: colorScheme.onSurfaceVariant)),
                      const SizedBox(width: 16),
                      _buildActionIcon(Icons.chat_bubble_outline, colorScheme),
                      const SizedBox(width: 4),
                      Text('${post['comments']}',
                          style: TextStyle(color: colorScheme.onSurfaceVariant)),
                      const SizedBox(width: 16),
                      _buildActionIcon(Icons.share_outlined, colorScheme),
                      const SizedBox(width: 4),
                      Text('${post['shares']}',
                          style: TextStyle(color: colorScheme.onSurfaceVariant)),
                    ],
                  ),
                  Text(
                    post['time'],
                    style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant), 
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
  
  // URL'den yüklenen resim
  Widget _buildNetworkImage(String url, ColorScheme colorScheme) {
      return Image.network(
        url,
        width: double.infinity,
        height: 220,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            height: 220,
            color: colorScheme.surfaceVariant,
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
                strokeWidth: 2,
                color: colorScheme.primary, 
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => Container(
          height: 220,
          color: colorScheme.surfaceVariant,
          child: Center(
            child: Icon(Icons.broken_image, color: colorScheme.onSurface.withOpacity(0.5)), 
          ),
        ),
      );
  }

  // Yerel dosyadan yüklenen resim
  Widget _buildLocalImage(String filePath, ColorScheme colorScheme) {
      return Image.file(
        File(filePath),
        width: double.infinity,
        height: 220,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          height: 220,
          color: colorScheme.surfaceVariant,
          child: Center(
            child: Text(
              'Görsel yüklenemedi (Yerel dosya)',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ),
        ),
      );
  }

  // Dosya indirme kartı (Resim dışındaki dosyalar için)
  Widget _buildFileDownloadCard(String fileName, String filePath, ColorScheme colorScheme, ThemeData theme) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: InkWell(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Dosya indirme simülasyonu başlatıldı: $fileName'),
                backgroundColor: colorScheme.secondary,
                duration: const Duration(seconds: 1),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colorScheme.primary.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                Icon(Icons.insert_drive_file, color: colorScheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    fileName,
                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.download, color: colorScheme.primary),
              ],
            ),
          ),
        ),
      );
  }


  // Dinamik ikon oluşturucu
  Widget _buildActionIcon(IconData icon, ColorScheme colorScheme) {
    return Icon(icon, size: 20, color: colorScheme.onSurface.withOpacity(0.6));
  }

  // Popüler Kurs Kartı (GÜNCELLENDİ: Navigasyon ve Metin Kısıtlaması)
  Widget _buildSingleCourseCard(
      BuildContext context, Map<String, String> courseData, ThemeData theme, ColorScheme colorScheme) {
    return GestureDetector(
      onTap: () {
        // ID'yi al ve CourseDetailScreen'e gönder
        final courseId = int.tryParse(courseData['id'] ?? '0');
        
        if (courseId != null && courseId != 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CourseDetailScreen(courseId: courseId), 
              ),
            );
        } else {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Kurs ID bilgisi eksik.')),
            );
        }
      },
      child: Container(
        width: 180,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.surface, 
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity(theme.brightness == Brightness.light ? 0.1 : 0.4), 
              spreadRadius: 1,
              blurRadius: 5,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              courseData['code']!,
              style: TextStyle(
                color: colorScheme.primary, 
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Kurs Adı: Max 2 satır, sığmazsa "..."
                Text(
                  courseData['title']!, 
                  maxLines: 2, 
                  overflow: TextOverflow.ellipsis, 
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: colorScheme.onSurface, 
                  ),
                ),
                const SizedBox(height: 4),
                // Eğitmen Adı: Max 1 satır, sığmazsa "..."
                Text(
                  courseData['instructor']!, 
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 13,
                    color: colorScheme.onSurfaceVariant, 
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCard(ThemeData theme, ColorScheme colorScheme) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.emoji_events_outlined,
                  color: colorScheme.primary, 
                ),
                const SizedBox(width: 8),
                Text(
                  'Puan Durumu',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: colorScheme.onSurface, 
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Sıralamanız',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant, 
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '12. Sıra (540 puan)',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary, 
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LeaderboardScreen()));
              },
              child: Text(
                'Detayları Gör',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.primary, 
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectStatusCard(ThemeData theme, ColorScheme colorScheme) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.assignment_turned_in_outlined,
                  color: colorScheme.tertiary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Proje Durumu',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: colorScheme.onSurface, 
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Teslim Edilen Projeler',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant, 
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '2 / 3',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface, 
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ReportsScreen()));
              },
              child: Text(
                'Detayları Gör',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.primary, 
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}