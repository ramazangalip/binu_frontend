import 'dart:io'; 
import 'dart:convert';
import 'package:binu_frontend/models/post_model.dart';
import 'package:http/http.dart' as http;
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

  // 🌟 GÖNDERİLER İÇİN YENİ ALANLAR
  List<Map<String, dynamic>> _fetchedPosts = [];
  bool _isLoadingPosts = true; 
  
  static const String _baseUrl = 'http://10.0.2.2:8000/api/'; 
  // -----------------------------------------------------------------

  // Artık kullanılan `posts` listesi yerine dinamik olarak çekilen _fetchedPosts kullanılacak.
  // Ancak `NewPostScreen`'den gelen yeni postları geçici olarak listeye eklemek için
  // bu listeyi canlı tutabiliriz. Şimdilik eski yerel post listesini kaldırıyorum.

  @override
  void initState() {
    super.initState();
    _fetchPopularCourses();
    _fetchPosts(); // 👈 Gönderileri çekmeyi başlat
  }
  
  // -----------------------------------------------------------------
  // API'den Popüler Kurs Verilerini Çeken Metot (MEVCUT)
  // -----------------------------------------------------------------
  Future<void> _fetchPopularCourses() async {
    setState(() {
      _isLoadingCourses = true;
    });

    try {
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
            'id': item['courseid'].toString(),
            'code': item['coursecode'] as String,
            'title': item['coursename'] as String,
            'instructor': instructorName,
          };
        }).toList();

        setState(() {
          _fetchedPopularCourses = courses;
        });

      } else {
        print('Kurslar yüklenirken hata oluştu. Durum kodu: ${response.statusCode}');
      }
    } catch (e) {
      print('Ağ hatası: $e');
    } finally {
      setState(() {
        _isLoadingCourses = false; 
      });
    }
  }

  // -----------------------------------------------------------------
  // API'den Gönderi Verilerini Çeken Metot (YENİ)
  // -----------------------------------------------------------------
  Future<void> _fetchPosts() async {
    setState(() {
      _isLoadingPosts = true;
    });
    
    // API'den gönderileri çekmek için token gerekebilir. 
    // Basitlik adına şimdilik token'ı atlıyoruz, ancak gerçek uygulamada Authorization header eklenmeli.
    try {
      final response = await http.get(Uri.parse('${_baseUrl}posts/')); 
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(utf8.decode(response.bodyBytes));
        
        // Gelen API verisini uygulama formatına dönüştürme
        final List<Map<String, dynamic>> posts = jsonList.map((item) {
          
          // API'den gelen verileri Flutter'da beklenen alanlarla eşleştirme
          final userData = item['user'] as Map<String, dynamic>;
          
          return {
            'postid': item['postid'], // Post Detail'a gitmek için
            'username': userData['fullname'] as String,
            'title': userData['role']?['rolename'] ?? 'Kullanıcı', // Kullanıcı rolünü başlık olarak kullan
            // 👈 BURASI GÜNCELLENDİ: Eğer boşsa null olarak bırakın
            'profilePic': userData['profileimageurl'],
            'time': _formatTimeAgo(item['createdat'] as String), // Zamanı formatlamak için yardımcı metot
            'image': item['imageurl'], // API'den gelen imageurl
            'text': item['textcontent'] as String,
            
            // Etkileşim verileri
            'likes': item['likes_count'] as int,
            'comments': (item['comments'] as List).length, // Yorum listesinin uzunluğu
            'shares': item['sharecount'] as int, 
            'filePath': null, 
            'fileName': null, 
          };
        }).toList();

        setState(() {
          _fetchedPosts = posts;
        });
      } else {
        print('Gönderiler yüklenirken hata oluştu. Durum kodu: ${response.statusCode}');
      }
    } catch (e) {
      print('Ağ hatası: $e');
      if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gönderiler yüklenemedi. Sunucuya bağlanılamadı.')),
          );
        }
    } finally {
      setState(() {
        _isLoadingPosts = false; 
      });
    }
  }
  
  // -----------------------------------------------------------------
  // YARDIMCI ZAMAN METODU
  // -----------------------------------------------------------------
  String _formatTimeAgo(String iso8601String) {
    try {
      final dateTime = DateTime.parse(iso8601String);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 7) {
        return '${difference.inDays ~/ 7} hafta önce';
      } else if (difference.inDays > 0) {
        return '${difference.inDays} gün önce';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} saat önce';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} dakika önce';
      } else {
        return 'şimdi';
      }
    } catch (e) {
      return 'Bilinmeyen zaman';
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

          // 🧑‍🤝‍🧑 Takip Ettiklerin (DİNAMİK BÖLÜM - _fetchedPosts kullanılıyor)
          _buildSectionTitle("Takip Ettiklerin", theme, colorScheme),
          const SizedBox(height: 8),
          
          if (_isLoadingPosts)
            Center(child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: CircularProgressIndicator(color: colorScheme.primary),
            ))
          else if (_fetchedPosts.isEmpty)
            Center(child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text("Gönderi akışı boş.", style: TextStyle(color: colorScheme.onSurfaceVariant)),
            ))
          else 
            ..._fetchedPosts.map((post) => _buildPostCard(post, theme, colorScheme)).toList(),
          
          const SizedBox(height: 20),

          // 💻 Popüler Kurslar (DİNAMİK BÖLÜM - _fetchedPopularCourses kullanılıyor)
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
          // Yeni post eklendikten sonra post akışını yenilemek için kullanılır.
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NewPostScreen()),
          );
          if (result == true) { // Eğer başarılı bir gönderi oluşturulduysa (örneğin NewPostScreen'den döndüğünde true dönerse)
            _fetchPosts(); // Post akışını yenile
          }
        },
        child: Icon(Icons.add, color: colorScheme.onSecondary),
      ),
    );
  }
  
  // -----------------------------------------------------------------
  // YARDIMCI WIDGET METOTLARI (Aynı Kaldı)
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

  // HomeScreen > _HomeScreenState içinde

// HomeScreen > _HomeScreenState içinde

Widget _buildPostCard(Map<String, dynamic> post, ThemeData theme, ColorScheme colorScheme) {
    // ... (dosya ve resim kontrolleri aynı kalır)
    final hasFile = post['filePath'] != null && post['fileName'] != null;
    final hasImage = post['image'] != null && (post['image'] as String).isNotEmpty;
    final isImageFile = hasFile && 
                        (post['fileName'].toString().toLowerCase().endsWith('.jpg') ||
                         post['fileName'].toString().toLowerCase().endsWith('.jpeg') ||
                         post['fileName'].toString().toLowerCase().endsWith('.png'));

    // Profil fotoğrafı URL'si var mı kontrolü
    // API'den gelen veride 'profilePic' alanı genellikle NetworkImage'a uygundur.
    final profilePicUrl = post['profilePic'];
    final bool hasProfilePic = profilePicUrl != null && (profilePicUrl as String).isNotEmpty;


    return GestureDetector(
      onTap: () {
        try {
          // 🌟 ÇÖZÜM: Map'i (post) Post modeline dönüştürme
          final Post postModel = Post.fromJson(post); 
          
          Navigator.push(
            context,
            MaterialPageRoute(
              // Artık PostDetailScreen, beklediği Post modelini alıyor.
              builder: (context) => PostDetailScreen(post: postModel), 
            ),
          );
        } catch (e) {
            // Dönüşüm hatası durumunda (örneğin eksik alanlar varsa)
            print('Post modeline dönüştürme hatası: $e');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Gönderi detayları yüklenirken bir hata oluştu.')),
            );
        }
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
                  // 🌟 GÜNCELLENEN KISIM: Profil Fotoğrafı Kontrolü
                  CircleAvatar(
                    radius: 20,
                    // Eğer fotoğraf URL'si varsa NetworkImage kullan
                    backgroundImage: hasProfilePic 
                        ? NetworkImage(profilePicUrl) 
                        : null, // Yoksa backgroundImage null kalır, child gösterilir.
                    
                    // Eğer fotoğraf yoksa ikon göster
                    child: hasProfilePic
                        ? null // Fotoğraf varsa child null olmalı
                        : Icon(
                            Icons.person, // Varsayılan kişi ikonu
                            size: 25, 
                            color: colorScheme.onPrimary, // İkon rengini temadan çekiyoruz
                          ),
                          
                    // Profil avatarının arka plan rengini temadan çekiyoruz
                    // Eğer fotoğraf yoksa, ikonun arka planı primary renk olabilir.
                    backgroundColor: hasProfilePic 
                        ? colorScheme.surfaceVariant 
                        : colorScheme.primary, 
                  ),
                  // 🌟 GÜNCELLEME SONU

                  const SizedBox(width: 10),
                  Column(
                    // ... (Kullanıcı Adı ve Başlık (Rol) kısmı aynı kalır) ...
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
            
            // ... (Resim/Dosya Görüntüleme Mantığı aynı kalır) ...
            if (hasImage) ...[ 
              _buildNetworkImage(post['image'], colorScheme),
            ] else if (hasFile) ...[
              if (isImageFile) 
                _buildLocalImage(post['filePath'], colorScheme)
              else
                _buildFileDownloadCard(post['fileName'], post['filePath'], colorScheme, theme),
            ],
            // ... (Metin ve Etkileşim İkonları aynı kalır) ...

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

  // Popüler Kurs Kartı
  Widget _buildSingleCourseCard(
      BuildContext context, Map<String, String> courseData, ThemeData theme, ColorScheme colorScheme) {
    return GestureDetector(
      onTap: () {
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