import 'package:binu_frontend/screens/edit_profile_screen.dart';
import 'package:binu_frontend/screens/new_post_screen.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _selectedTab = 'Hepsi';
  final List<Map<String, dynamic>> _userPosts = [
    {
      'title': 'Akademik Proje Yönetimi',
      'date': '26 Ekim 2023',
      'status': 'Yayınlandı',
      'category': 'Proje Raporları',
      'image':
          'https://images.unsplash.com/photo-1517048676732-d65bc937f952?w=500&q=80',
    },
    {
      'title': 'Veri Yapıları ve Algoritmalar',
      'date': '05 Kasım 2023',
      'status': 'Taslak',
      'category': 'Ders Notları',
      'image':
          'https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=500&q=80',
    },
    {
      'title': 'Grup Çalışması İpuçları',
      'date': '12 Aralık 2023',
      'status': 'Yayınlandı',
      'category': 'Hepsi',
      'image':
          'https://images.unsplash.com/photo-1543269865-cbf427effbad?w=500&q=80',
    },
    {
      'title': 'Gelecek Etkinlikler Takvimi',
      'date': '15 Ocak 2024',
      'status': 'Planlandı',
      'category': 'Hepsi',
      'image':
          'https://images.unsplash.com/photo-1506126613408-eca07ce68773?w=500&q=80',
    },
    {
      'title': 'Etkili Not Alma Teknikleri',
      'date': '01 Şubat 2024',
      'status': 'Yayınlandı',
      'category': 'Ders Notları',
      'image':
          'https://images.unsplash.com/photo-1456324504439-367cee3b3c32?w=500&q=80',
    },
    {
      'title': 'Bitirme Projesi Belirlemesi',
      'date': '10 Mart 2024',
      'status': 'Taslak',
      'category': 'Proje Raporları',
      'image':
          'https://images.unsplash.com/photo-1519389950473-47ba0277781c?w=500&q=80',
    },
  ];

  final List<String> _tabs = ['Hepsi', 'Proje Raporları', 'Ders Notları'];

  List<Map<String, dynamic>> get _filteredPosts {
    if (_selectedTab == 'Hepsi') {
      return _userPosts;
    }
    return _userPosts
        .where((post) => post['category'] == _selectedTab)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(),
            _buildActionButtons(),
            const SizedBox(height: 24),
            _buildFilterTabs(),
            _buildPostsGrid(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NewPostScreen()),
          );
        },
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=12'),
          ),
          const SizedBox(height: 12),
          const Text(
            'Mert Yılmaz',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            '@mertyilmaz',
            style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 12),
          const Text(
            'Bilgisayar Bilimleri öğrencisi, teknoloji ve girişimcilik tutkunu. Yeni fikirler keşfetmeyi severim.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              _StatItem(value: '1.2K', label: 'Takipçi'),
              _StatItem(value: '350', label: 'Takip Edilen'),
              _StatItem(value: '58', label: 'Gönderiler'),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 4.0, left: 16.0),
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditProfileScreen(),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child:  Text('Profili Düzenle'),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 4.0, right: 16.0),
            child: OutlinedButton(
              onPressed: () {},
              child: const Text('Paylaş'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildFilterTabs() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1.0),
        ),
      ),
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _tabs.length,
        itemBuilder: (context, index) {
          final tab = _tabs[index];
          final isSelected = tab == _selectedTab;
          return GestureDetector(
            onTap: () => setState(() => _selectedTab = tab),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.deepPurple.shade50
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border(
                  bottom: BorderSide(
                    color: isSelected
                        ? Colors.deepPurple.shade900
                        : Colors.transparent,
                    width: 2.0,
                  ),
                ),
              ),
              child: Center(
                child: Text(
                  tab,
                  style: TextStyle(
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isSelected
                        ? Colors.deepPurple.shade900
                        : Colors.grey.shade600,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }


  Widget _buildPostsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: _filteredPosts.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75, // Kartların en-boy oranı
      ),
      itemBuilder: (context, index) {
        return _buildPostCard(_filteredPosts[index]);
      },
    );
  }

  // Tek bir gönderi kartı
  Widget _buildPostCard(Map<String, dynamic> post) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              post['image'],
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post['title'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  post['date'],
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 8),
                _buildStatusIndicator(post['status']),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Gönderi durumunu gösteren widget (Yayınlandı, Taslak vb.)
  Widget _buildStatusIndicator(String status) {
    IconData icon;
    Color color;
    switch (status) {
      case 'Yayınlandı':
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case 'Taslak':
        icon = Icons.edit_note;
        color = Colors.orange;
        break;
      case 'Planlandı':
        icon = Icons.timer_outlined;
        color = Colors.blue;
        break;
      default:
        icon = Icons.circle;
        color = Colors.grey;
    }

    return Row(
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 4),
        Text(
          status,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// İstatistikleri gösteren yardımcı widget
class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}
