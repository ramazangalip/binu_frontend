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
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 🔍 Arama Kutusu
          TextField(
            decoration: InputDecoration(
              hintText: "Kurs ara...",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 🧑‍🤝‍🧑 Takip Ettiklerin
          _buildSectionTitle("Takip Ettiklerin"),
          const SizedBox(height: 8),
          ...posts.map((post) => _buildPostCard(post)).toList(),
          const SizedBox(height: 20),

          // 💻 Popüler Kurslar
          _buildSectionTitle("Popüler Kurslar"),
          const SizedBox(height: 12),
          SizedBox(
            height: 130,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: popularCourses.length,
              itemBuilder: (context, index) {
                return _buildSingleCourseCard(context, popularCourses[index]);
              },
            ),
          ),
          const SizedBox(height: 20),

          const SizedBox(height: 8),
          _buildScoreCard(),
          const SizedBox(height: 8),
          _buildProjectStatusCard(),
        ],
      ),
      // ... HomeScreen içinde ...

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
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
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // 🔹 Başlık + Tümünü Gör satırı
  Widget _buildSectionTitle(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SearchScreen(),
              ),
            );
          },
          child: const Text(
            "Tümünü Gör",
            style: TextStyle(color: Colors.blueAccent),
          ),
        )
      ],
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post) {
    // DEĞİŞİKLİK: Card widget'ı GestureDetector ile sarmalandı
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
        color: Colors.white,
        margin: const EdgeInsets.only(bottom: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        shadowColor: Colors.grey.withOpacity(0.1),
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
                    backgroundColor: Colors.grey.shade200,
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post['username'],
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.black87),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          post['title']!,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.blue.shade700,
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
                    color: Colors.grey.shade200,
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                        strokeWidth: 2,
                        color: Colors.blueAccent,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 220,
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              ),
            ],
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                post['text'],
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
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
                      Icon(Icons.thumb_up_alt_outlined,
                          size: 20, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text('${post['likes']}',
                          style: TextStyle(color: Colors.grey.shade700)),
                      const SizedBox(width: 16),
                      Icon(Icons.chat_bubble_outline,
                          size: 20, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text('${post['comments']}',
                          style: TextStyle(color: Colors.grey.shade700)),
                      const SizedBox(width: 16),
                      Icon(Icons.share_outlined,
                          size: 20, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text('${post['shares']}',
                          style: TextStyle(color: Colors.grey.shade700)),
                    ],
                  ),
                  Text(
                    post['time'],
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSingleCourseCard(
      BuildContext context, Map<String, String> courseData) {
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
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
                color: Colors.blue.shade700,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  courseData['title']!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  courseData['instructor']!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCard() {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      shadowColor: Colors.grey.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.emoji_events_outlined,
                  color: Colors.blue.shade700,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Puan Durumu',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Sıralamanız',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '12. Sıra (540 puan)',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
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
                style: TextStyle(
                  color: Colors.blue.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectStatusCard() {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      shadowColor: Colors.grey.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.assignment_turned_in_outlined,
                  color: Colors.green.shade700,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Proje Durumu',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Teslim Edilen Projeler',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              '2 / 3',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
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
                style: TextStyle(
                  color: Colors.blue.shade600,
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

