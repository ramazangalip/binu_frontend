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
import 'package:provider/provider.dart';
import 'package:binu_frontend/providers/auth_provider.dart';
import 'package:binu_frontend/services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, String>> _fetchedPopularCourses = [];
  bool _isLoadingCourses = true;

  List<Map<String, dynamic>> _fetchedPosts = [];
  bool _isLoadingPosts = true;

  int? _userRank;

  static const String _baseUrl = 'http://10.0.2.2:8000/api/';
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchPopularCourses();
    _fetchPosts();
    _fetchUserRank();
  }

  String _getFileExtensionFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final path = uri.path;
      final parts = path.split('.');
      if (parts.length > 1) {
        return parts.last.toLowerCase();
      }
      return '';
    } catch (e) {
      return '';
    }
  }

  Future<void> _fetchUserRank() async {
    final currentUser =
        Provider.of<AuthProvider>(context, listen: false).currentUser;

    if (currentUser == null || currentUser.score == null) {
      setState(() {
        _userRank = null;
      });
      return;
    }

    try {
      final List<User> leaderboard =
          await _apiService.fetchLeaderboard();

      final int rankIndex = leaderboard.indexWhere(
        (user) => user.userid == currentUser.userid,
      );

      setState(() {
        _userRank = rankIndex != -1 ? rankIndex + 1 : null;
      });
    } catch (e) {
      print('Siralama cekme hatasi: $e');
      setState(() {
        _userRank = null;
      });
    }
  }

  Future<void> _fetchPopularCourses() async {
    setState(() {
      _isLoadingCourses = true;
    });

    try {
      final response =
          await http.get(Uri.parse('${_baseUrl}courses/'));

      if (response.statusCode == 200) {
        final List<dynamic> jsonList =
            json.decode(utf8.decode(response.bodyBytes));

        final List<Map<String, String>> courses =
            jsonList.map((item) {
          final teacherData = item['teacher'];
          String instructorName = 'Ogretmen Yok';

          if (teacherData != null &&
              teacherData is Map &&
              teacherData.containsKey('fullname')) {
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
        print(
          'Kurslar yuklenirken hata olustu. Durum kodu: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Ag hatasi: $e');
    } finally {
      setState(() {
        _isLoadingCourses = false;
      });
    }
  }

  Future<void> _fetchPosts() async {
    setState(() {
      _isLoadingPosts = true;
    });

    try {
      final response =
          await http.get(Uri.parse('${_baseUrl}posts/'));

      if (response.statusCode == 200) {
        final List<dynamic> jsonList =
            json.decode(utf8.decode(response.bodyBytes));

        final List<Map<String, dynamic>> posts =
            jsonList.map((item) {
          final userData = item['user'] as Map<String, dynamic>;

          return {
            'postid': item['postid'],
            'username': userData['fullname'] as String,
            'title': userData['role']?['rolename'] ?? 'Kullanici',
            'profilePic': userData['profileimageurl'],
            'createdat': item['createdat'],
            'time': _formatTimeAgo(item['createdat'] as String),
            'category': item['category'],
            'is_liked_by_user': item['is_liked_by_user'] ?? false,
            'user_details': userData,
            'image': item['imageurl'],
            'text': item['textcontent'] as String,
            'likes': item['likes_count'] as int,
            'comments': (item['comments'] as List).length,
            'shares': item['sharecount'] as int,
          };
        }).toList();

        setState(() {
          _fetchedPosts = posts;
        });
      } else {
        print(
          'Gonderiler yuklenirken hata olustu. Durum kodu: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Ag hatasi: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gonderiler yuklenemedi.'),
          ),
        );
      }
    } finally {
      setState(() {
        _isLoadingPosts = false;
      });
    }
  }

  String _formatTimeAgo(String iso8601String) {
    try {
      final dateTime = DateTime.parse(iso8601String);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 7) {
        return '${difference.inDays ~/ 7} hafta once';
      } else if (difference.inDays > 0) {
        return '${difference.inDays} gun once';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} saat once';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} dakika once';
      } else {
        return 'simdi';
      }
    } catch (e) {
      return 'Bilinmeyen zaman';
    }
  }

  // build() aşağıda devam edecek

@override
Widget build(BuildContext context) {
  final ThemeData theme = Theme.of(context);
  final ColorScheme colorScheme = theme.colorScheme;

  return Scaffold(
    backgroundColor: theme.scaffoldBackgroundColor,
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          decoration: InputDecoration(
            hintText: "Kurs ara...",
            prefixIcon: Icon(
              Icons.search,
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 0,
            ),
          ),
        ),
        const SizedBox(height: 16),

        _buildSectionTitle("Takip Ettiklerin", theme, colorScheme),
        const SizedBox(height: 8),

        if (_isLoadingPosts)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: CircularProgressIndicator(
                color: colorScheme.primary,
              ),
            ),
          )
        else if (_fetchedPosts.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text(
                "Gonderi akisi bos.",
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          )
        else
          ..._fetchedPosts
              .map(
                (post) =>
                    _buildPostCard(post, theme, colorScheme),
              )
              .toList(),

        const SizedBox(height: 20),

        _buildSectionTitle(
          "Populer Kurslar",
          theme,
          colorScheme,
          isSearchable: true,
        ),
        const SizedBox(height: 12),

        SizedBox(
          height: 130,
          child: _isLoadingCourses
              ? Center(
                  child: CircularProgressIndicator(
                    color: colorScheme.primary,
                  ),
                )
              : _fetchedPopularCourses.isEmpty
                  ? Center(
                      child: Text(
                        "Populer kurs bulunamadi.",
                        style: TextStyle(
                          color:
                              colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount:
                          _fetchedPopularCourses.length,
                      itemBuilder: (context, index) {
                        return _buildSingleCourseCard(
                          context,
                          _fetchedPopularCourses[index],
                          theme,
                          colorScheme,
                        );
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
          MaterialPageRoute(
            builder: (context) =>
                const NewPostScreen(),
          ),
        );

        if (result == true) {
          _fetchPosts();
          _fetchUserRank();
        }
      },
      child: Icon(
        Icons.add,
        color: colorScheme.onSecondary,
      ),
    ),
  );
}

// -----------------------------------------------------------------
// YARDIMCI WIDGET METOTLARI
// -----------------------------------------------------------------

Widget _buildSectionTitle(
  String title,
  ThemeData theme,
  ColorScheme colorScheme, {
  bool isSearchable = false,
}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        title,
        style: theme.textTheme.headlineMedium
            ?.copyWith(fontSize: 17),
      ),
      TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => isSearchable
                  ? const SearchScreen()
                  : const LeaderboardScreen(),
            ),
          );
        },
        child: Text(
          "Tumunu Gor",
          style: TextStyle(
            color: colorScheme.primary,
          ),
        ),
      ),
    ],
  );
}

// -----------------------------------------------------------------
// POST CARD
// -----------------------------------------------------------------

Widget _buildPostCard(
  Map<String, dynamic> post,
  ThemeData theme,
  ColorScheme colorScheme,
) {
  final imageUrl = post['image'] as String?;
  final hasImage =
      imageUrl != null && imageUrl.isNotEmpty;

  final extension = hasImage
      ? _getFileExtensionFromUrl(imageUrl!)
      : '';
  final isMediaImage = [
    'jpg',
    'jpeg',
    'png',
    'gif',
    'bmp',
  ].contains(extension);

  final profilePicUrl = post['profilePic'];
  final bool hasProfilePic =
      profilePicUrl != null &&
          (profilePicUrl as String).isNotEmpty;

  return GestureDetector(
    onTap: () {
      try {
        final Post postModel = Post.fromJson({
          'postid': post['postid'],
          'textcontent': post['text'],
          'imageurl': post['image'],
          'sharecount': post['shares'],
          'likes_count': post['likes'],
          'is_liked_by_user':
              post['is_liked_by_user'] ?? false,
          'createdat': post['createdat'] ??
              DateTime.now().toIso8601String(),
          'category': post['category'] ?? 'Genel',
          'comments': [],
          'user': post['user_details'],
        });

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                PostDetailScreen(post: postModel),
          ),
        );
      } catch (e) {
        print('Post modeline donusturme hatasi: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Gonderi detaylari yuklenirken bir hata olustu.',
            ),
          ),
        );
      }
    },
    child: Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.all(12.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: hasProfilePic
                      ? NetworkImage(profilePicUrl)
                      : null,
                  backgroundColor: hasProfilePic
                      ? colorScheme.surfaceVariant
                      : colorScheme.primary,
                  child: hasProfilePic
                      ? null
                      : Icon(
                          Icons.person,
                          size: 25,
                          color:
                              colorScheme.onPrimary,
                        ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      post['username'],
                      style: theme
                          .textTheme.bodyLarge
                          ?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color:
                            colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme
                            .primaryContainer,
                        borderRadius:
                            BorderRadius.circular(4),
                      ),
                      child: Text(
                        post['title']!,
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme
                              .onPrimaryContainer,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          if (hasImage)
            isMediaImage
                ? _buildNetworkImage(
                    imageUrl!,
                    colorScheme,
                  )
                : _buildFileDownloadCardForNetwork(
                    imageUrl!,
                    extension,
                    colorScheme,
                    theme,
                  ),

          Padding(
            padding:
                const EdgeInsets.all(12.0),
            child: Text(
              post['text'],
              style: theme.textTheme.bodyLarge
                  ?.copyWith(
                fontSize: 16,
                color:
                    colorScheme.onSurface,
                height: 1.5,
              ),
            ),
          ),

          Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 8.0,
            ),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildActionIcon(
                      Icons.thumb_up_alt_outlined,
                      colorScheme,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${post['likes']}',
                      style: TextStyle(
                        color: colorScheme
                            .onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 16),
                    _buildActionIcon(
                      Icons.chat_bubble_outline,
                      colorScheme,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${post['comments']}',
                      style: TextStyle(
                        color: colorScheme
                            .onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 16),
                    _buildActionIcon(
                      Icons.share_outlined,
                      colorScheme,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${post['shares']}',
                      style: TextStyle(
                        color: colorScheme
                            .onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                Text(
                  post['time'],
                  style: TextStyle(
                    fontSize: 13,
                    color:
                        colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

// -----------------------------------------------------------------
// IMAGE HELPERS
// -----------------------------------------------------------------

Widget _buildNetworkImage(
  String url,
  ColorScheme colorScheme,
) {
  return Image.network(
    url,
    width: double.infinity,
    height: 220,
    fit: BoxFit.cover,
    loadingBuilder:
        (context, child, loadingProgress) {
      if (loadingProgress == null) return child;
      return Container(
        height: 220,
        color: colorScheme.surfaceVariant,
        child: Center(
          child: CircularProgressIndicator(
            value:
                loadingProgress.expectedTotalBytes !=
                        null
                    ? loadingProgress
                            .cumulativeBytesLoaded /
                        loadingProgress
                            .expectedTotalBytes!
                    : null,
            strokeWidth: 2,
            color: colorScheme.primary,
          ),
        ),
      );
    },
    errorBuilder:
        (context, error, stackTrace) =>
            Container(
      height: 220,
      color: colorScheme.surfaceVariant,
      child: Center(
        child: Icon(
          Icons.broken_image,
          color: colorScheme.onSurface
              .withOpacity(0.5),
        ),
      ),
    ),
  );
}

Widget _buildLocalImage(
  String filePath,
  ColorScheme colorScheme,
) {
  return Image.file(
    File(filePath),
    width: double.infinity,
    height: 220,
    fit: BoxFit.cover,
    errorBuilder:
        (context, error, stackTrace) =>
            Container(
      height: 220,
      color: colorScheme.surfaceVariant,
      child: Center(
        child: Text(
          'Gorsel yuklenemedi (Yerel dosya)',
          style: TextStyle(
            color:
                colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    ),
  );
}
// YENİ WIDGET: Ağ Üzerinden İndirilebilir Dosya Kartı (URL LAUNCHER AKTİF)
Widget _buildFileDownloadCardForNetwork(
  String url,
  String extension,
  ColorScheme colorScheme,
  ThemeData theme,
) {
  IconData icon;

  if (extension == 'pdf') {
    icon = Icons.picture_as_pdf;
  } else if (['doc', 'docx'].contains(extension)) {
    icon = Icons.description;
  } else {
    icon = Icons.insert_drive_file;
  }

  final fileName = 'Dosya.${extension.toUpperCase()}';

  return Padding(
    padding: const EdgeInsets.symmetric(
      horizontal: 12.0,
      vertical: 8.0,
    ),
    child: InkWell(
      onTap: () async {
        final uri = Uri.parse(url);

        if (await canLaunchUrl(uri)) {
          await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Dosya açılamadı veya indirilemedi. Bağlantı geçersiz olabilir.',
              ),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: colorScheme.primary.withOpacity(0.5),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: colorScheme.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                fileName,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.open_in_new,
              color: colorScheme.primary,
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildFileDownloadCard(
  String fileName,
  String filePath,
  ColorScheme colorScheme,
  ThemeData theme,
) {
  return Padding(
    padding: const EdgeInsets.symmetric(
      horizontal: 12.0,
      vertical: 8.0,
    ),
    child: InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Dosya indirme simulasyonu baslatildi: $fileName',
            ),
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
          border: Border.all(
            color: colorScheme.primary.withOpacity(0.5),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.insert_drive_file,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                fileName,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.download,
              color: colorScheme.primary,
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildActionIcon(
  IconData icon,
  ColorScheme colorScheme,
) {
  return Icon(
    icon,
    size: 20,
    color: colorScheme.onSurface.withOpacity(0.6),
  );
}

Widget _buildSingleCourseCard(
  BuildContext context,
  Map<String, String> courseData,
  ThemeData theme,
  ColorScheme colorScheme,
) {
  return GestureDetector(
    onTap: () {
      final courseId =
          int.tryParse(courseData['id'] ?? '0');

      if (courseId != null && courseId != 0) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                CourseDetailScreen(courseId: courseId),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kurs ID bilgisi eksik.'),
          ),
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
            color: colorScheme.shadow.withOpacity(
              theme.brightness == Brightness.light
                  ? 0.1
                  : 0.4,
            ),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
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
              Text(
                courseData['title']!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style:
                    theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                courseData['instructor']!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    theme.textTheme.bodySmall?.copyWith(
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

Widget _buildScoreCard(
  ThemeData theme,
  ColorScheme colorScheme,
) {
  final authProvider =
      Provider.of<AuthProvider>(context);
  final int? score =
      authProvider.currentUser?.score;
  final int? rank = _userRank;

  final String scoreText =
      score != null ? '$score puan' : '0 puan';

  String rankDisplay;
  if (rank != null) {
    rankDisplay = '$rank. Sira ($scoreText)';
  } else if (score != null) {
    rankDisplay =
        'Siralama hesaplaniyor ($scoreText)';
  } else {
    rankDisplay = 'Veriler yukleniyor...';
  }

  return Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
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
                style: theme.textTheme.headlineMedium
                    ?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Siralamaniz',
            style: theme.textTheme.bodyMedium
                ?.copyWith(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            rankDisplay,
            style: theme.textTheme.headlineSmall
                ?.copyWith(
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
                  builder: (context) =>
                      const LeaderboardScreen(),
                ),
              );
            },
            child: Text(
              'Detaylari Gor',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(
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

Widget _buildProjectStatusCard(
  ThemeData theme,
  ColorScheme colorScheme,
) {
  return Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
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
                style: theme.textTheme.headlineMedium
                    ?.copyWith(
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
            style: theme.textTheme.bodyMedium
                ?.copyWith(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '2 / 3',
            style: theme.textTheme.headlineSmall
                ?.copyWith(
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
                  builder: (context) =>
                      const ReportsScreen(),
                ),
              );
            },
            child: Text(
              'Detaylari Gor',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(
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