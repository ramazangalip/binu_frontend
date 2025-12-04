import 'package:binu_frontend/screens/course_detail_screen.dart';
import 'package:binu_frontend/screens/leaderboard_screen.dart';
import 'package:binu_frontend/screens/new_post_screen.dart';
import 'package:binu_frontend/screens/post_detail_screen.dart'; // YENİ EKLENDİ
import 'package:binu_frontend/screens/reports_screen.dart';
import 'package:binu_frontend/screens/search_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
    },
  ];

  final List<Map<String, String>> popularCourses = [
    {
      'code': 'COMP101',
      'title': 'Programlamaya Giriş',
      'instructor': 'Prof. Dr. Elif Kaya',
    },
    {
      'code': 'MATH203',
      'title': 'İleri Analiz',
      'instructor': 'Doç. Dr. Can Uçar',
    },
    {
      'code': 'PHYS101',
      'title': 'Fizik I',
      'instructor': 'Prof. Dr. Ahmet Kurt',
    },
    {
      'code': 'EE201',
      'title': 'Devre Teorisi',
      'instructor': 'Dr. Zeynep Çelik',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
      // 1. Arka Plan Rengi: Temanın ana arka plan rengi kullanılacak.
      backgroundColor: theme.scaffoldBackgroundColor,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 🔍 Arama Kutusu
          TextField(
            // theme.inputDecorationTheme'ı kullanacak
            decoration: InputDecoration(
              hintText: "Kurs ara...",
              prefixIcon: Icon(
                Icons.search,
                // İkon rengi temadan çekilecek.
                color: colorScheme.onSurface.withOpacity(0.6), 
              ),
              // fillColor, AppTheme'daki inputDecorationTheme'dan geliyor.
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              // border stili AppTheme'dan geliyor.
            ),
          ),
          const SizedBox(height: 16),

          // 🧑‍🤝‍🧑 Takip Ettiklerin
          _buildSectionTitle("Takip Ettiklerin", theme, colorScheme),
          const SizedBox(height: 8),
          ...posts.map((post) => _buildPostCard(post, theme, colorScheme)).toList(),
          const SizedBox(height: 20),

          // 💻 Popüler Kurslar
          _buildSectionTitle("Popüler Kurslar", theme, colorScheme, isSearchable: true),
          const SizedBox(height: 12),
          SizedBox(
            height: 130,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: popularCourses.length,
              itemBuilder: (context, index) {
                return _buildSingleCourseCard(context, popularCourses[index], theme, colorScheme);
              },
            ),
          ),
          const SizedBox(height: 20),

          _buildScoreCard(theme, colorScheme),
          const SizedBox(height: 8),
          _buildProjectStatusCard(theme, colorScheme),
        ],
      ),
      // ... HomeScreen içinde ...

      floatingActionButton: FloatingActionButton(
        // FAB rengi: Colors.blueAccent yerine primary veya secondary kullanılabilir.
        backgroundColor: colorScheme.secondary,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NewPostScreen()),
          );
          if (result != null && result is Map<String, dynamic>) {
            setState(() {
              posts.insert(0, result);
            });
          }
        },
        // İkon rengi: `onSecondary` rengi, `secondary` üzerindeki rengi belirler.
        child: Icon(Icons.add, color: colorScheme.onSecondary),
      ),
    );
  }

  // 🔹 Başlık + Tümünü Gör satırı
  Widget _buildSectionTitle(String title, ThemeData theme, ColorScheme colorScheme, {bool isSearchable = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          // 2. Başlık metin rengi temadan çekilecek.
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
            // 3. TextButton metin rengi temadan çekilecek (primary).
            style: TextStyle(color: colorScheme.primary),
          ),
        )
      ],
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post, ThemeData theme, ColorScheme colorScheme) {
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
        // 4. Card rengi: Sabit Colors.white yerine tema kart rengi kullanılacak.
        // CardTheme'da zaten tanımladınız, bu yüzden sadece Card() yeterli.
        margin: const EdgeInsets.only(bottom: 14),
        // shape, elevation, shadowColor CardTheme'dan geliyor.
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
                    // CircleAvatar arka plan rengi temadan çekilecek.
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
                          // 5. Metin rengi temadan çekilecek (onSurface).
                          color: colorScheme.onSurface, 
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          // 6. Badge arka plan rengi temadan çekilecek (primary'nin hafif versiyonu).
                          color: colorScheme.primaryContainer, 
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          post['title']!,
                          style: TextStyle(
                            fontSize: 11,
                            // 7. Badge metin rengi temadan çekilecek (onPrimaryContainer).
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
              Image.network(
                post['image'],
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 220,
                    // 8. Placeholder arka plan rengi temadan çekilecek.
                    color: colorScheme.surfaceVariant, 
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                        strokeWidth: 2,
                        // 9. Progress Indicator rengi temadan çekilecek.
                        color: colorScheme.primary, 
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 220,
                  // 10. Hata arka plan rengi temadan çekilecek.
                  color: colorScheme.surfaceVariant, 
                  child: Center(
                    // 11. Hata ikon rengi temadan çekilecek.
                    child: Icon(Icons.broken_image, color: colorScheme.onSurface.withOpacity(0.5)), 
                  ),
                ),
              ),
            ],
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                post['text'],
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontSize: 16,
                  // 12. İçerik metin rengi temadan çekilecek.
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
                    // 13. Zaman metin rengi temadan çekilecek.
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

  // Dinamik ikon oluşturucu
  Widget _buildActionIcon(IconData icon, ColorScheme colorScheme) {
    // 14. İkon rengi temadan çekilecek.
    return Icon(icon, size: 20, color: colorScheme.onSurface.withOpacity(0.6));
  }

  Widget _buildSingleCourseCard(
      BuildContext context, Map<String, String> courseData, ThemeData theme, ColorScheme colorScheme) {
    return GestureDetector(
      onTap: () {
        // Tıklanınca CourseDetailScreen'e git
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CourseDetailScreen()),
        );
      },
      child: Container(
        width: 180,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          // 15. Container rengi: Sabit Colors.white yerine tema yüzey rengi kullanılacak.
          color: colorScheme.surface, 
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              // 16. Shadow rengi temadan çekilecek.
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
                // 17. Kurs kodu rengi temadan çekilecek.
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
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    // 18. Kurs başlık rengi temadan çekilecek.
                    color: colorScheme.onSurface, 
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  courseData['instructor']!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 13,
                    // 19. Eğitmen adı rengi temadan çekilecek.
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
      // Card Theme'da renkler tanımlı olduğu için Card() yeterli.
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
                  // 20. İkon rengi temadan çekilecek.
                  color: colorScheme.primary, 
                ),
                const SizedBox(width: 8),
                Text(
                  'Puan Durumu',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    // 21. Başlık rengi temadan çekilecek.
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
                // 22. Metin rengi temadan çekilecek.
                color: colorScheme.onSurfaceVariant, 
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '12. Sıra (540 puan)',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                // 23. Önemli metin rengi temadan çekilecek.
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
                  // 24. TextButton rengi temadan çekilecek.
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
      // Card Theme'da renkler tanımlı olduğu için Card() yeterli.
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
                  // 25. İkon rengi: Sabit yeşil yerine temadan çekilecek (ya da success/tertiary renk).
                  color: colorScheme.tertiary, // Örn. primary, secondary veya tertiary
                ),
                const SizedBox(width: 8),
                Text(
                  'Proje Durumu',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    // 26. Başlık rengi temadan çekilecek.
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
                // 27. Metin rengi temadan çekilecek.
                color: colorScheme.onSurfaceVariant, 
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '2 / 3',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                // 28. Önemli metin rengi temadan çekilecek.
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
                  // 29. TextButton rengi temadan çekilecek.
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