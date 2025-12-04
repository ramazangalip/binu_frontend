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
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    
    return Scaffold(
      // Arka planı temadan al
      backgroundColor: theme.scaffoldBackgroundColor, 

      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(theme, colorScheme),
            _buildActionButtons(colorScheme),
            const SizedBox(height: 24),
            _buildFilterTabs(theme, colorScheme),
            _buildPostsGrid(theme, colorScheme),
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
        // FAB rengini temadan al
        backgroundColor: colorScheme.secondary, 
        // İkon rengini temadan al
        child: Icon(Icons.add, color: colorScheme.onSecondary), 
      ),
    );
  }
  
  // -----------------------------------------------------
  // Profil Başlık Bölümü
  // -----------------------------------------------------
  Widget _buildProfileHeader(ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: const NetworkImage('https://i.pravatar.cc/150?img=12'),
            // Avatar placeholder rengini temadan al
            backgroundColor: colorScheme.surfaceVariant, 
          ),
          const SizedBox(height: 12),
          Text(
            'Mert Yılmaz',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontSize: 22, 
              fontWeight: FontWeight.bold,
              // Metin rengini temadan al
              color: colorScheme.onSurface, 
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '@mertyilmaz',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 15, 
              // İkincil metin rengini temadan al
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Bilgisayar Bilimleri öğrencisi, teknoloji ve girişimcilik tutkunu. Yeni fikirler keşfetmeyi severim.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 14, 
              height: 1.5,
              // Metin rengini temadan al
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatItem(value: '1.2K', label: 'Takipçi', theme: theme, colorScheme: colorScheme),
              _StatItem(value: '350', label: 'Takip Edilen', theme: theme, colorScheme: colorScheme),
              _StatItem(value: '58', label: 'Gönderiler', theme: theme, colorScheme: colorScheme),
            ],
          ),
        ],
      ),
    );
  }


  // -----------------------------------------------------
  // Aksiyon Butonları Bölümü
  // -----------------------------------------------------
  Widget _buildActionButtons(ColorScheme colorScheme) {
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
                // Çerçeve rengini temadan al
                side: BorderSide(color: colorScheme.outlineVariant), 
                // Metin rengini temadan al
                foregroundColor: colorScheme.onSurface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Profili Düzenle'),
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
                // Çerçeve rengini temadan al
                side: BorderSide(color: colorScheme.outlineVariant), 
                // Metin rengini temadan al
                foregroundColor: colorScheme.onSurface,
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


  // -----------------------------------------------------
  // Filtre Sekmeleri Bölümü
  // -----------------------------------------------------
  Widget _buildFilterTabs(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          // Alt çizgi rengini temadan al
          bottom: BorderSide(color: colorScheme.outlineVariant, width: 1.0), 
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
          
          final selectedBg = colorScheme.primaryContainer.withOpacity(0.4); // Seçili arka plan
          final selectedFg = colorScheme.primary; // Seçili metin ve çizgi rengi

          return GestureDetector(
            onTap: () => setState(() => _selectedTab = tab),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? selectedBg : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border(
                  bottom: BorderSide(
                    color: isSelected ? selectedFg : Colors.transparent,
                    width: 2.0,
                  ),
                ),
              ),
              child: Center(
                child: Text(
                  tab,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    // Metin rengini dinamik olarak ayarla
                    color: isSelected ? selectedFg : colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }


  // -----------------------------------------------------
  // Gönderi Izgarası Bölümü
  // -----------------------------------------------------
  Widget _buildPostsGrid(ThemeData theme, ColorScheme colorScheme) {
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
        return _buildPostCard(_filteredPosts[index], theme, colorScheme);
      },
    );
  }

  // Tek bir gönderi kartı
  Widget _buildPostCard(Map<String, dynamic> post, ThemeData theme, ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        // Arka plan rengini temadan al (Card veya Surface)
        color: colorScheme.surface, 
        borderRadius: BorderRadius.circular(12),
        // Çerçeve rengini temadan al
        border: Border.all(color: colorScheme.outlineVariant), 
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
              errorBuilder: (context, error, stackTrace) => Container(
                height: 120,
                color: colorScheme.surfaceVariant,
                child: Center(child: Icon(Icons.broken_image, color: colorScheme.onSurface.withOpacity(0.5))),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post['title'],
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    // Metin rengini temadan al
                    color: colorScheme.onSurface, 
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  post['date'],
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 12, 
                    // İkincil metin rengini temadan al
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                _buildStatusIndicator(post['status'], colorScheme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Gönderi durumunu gösteren widget (Yayınlandı, Taslak vb.)
  Widget _buildStatusIndicator(String status, ColorScheme colorScheme) {
    IconData icon;
    Color color;
    
    // Durum renkleri, görsel ayrım için sabit tutulabilir veya temadan çekilebilir.
    // Burada sabit renkleri temadaki ana renklerin eşdeğeriyle değiştiriyoruz.
    switch (status) {
      case 'Yayınlandı':
        icon = Icons.check_circle;
        color = Colors.green.shade600; // Başarı rengi
        break;
      case 'Taslak':
        icon = Icons.edit_note;
        color = Colors.orange.shade600; // Dikkat/Uyarı rengi
        break;
      case 'Planlandı':
        icon = Icons.timer_outlined;
        color = colorScheme.primary; // Ana renk
        break;
      default:
        icon = Icons.circle;
        color = colorScheme.onSurfaceVariant;
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
  final ThemeData theme;
  final ColorScheme colorScheme;

  const _StatItem({
    required this.label, 
    required this.value, 
    required this.theme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold, 
            fontSize: 18,
            // Metin rengini temadan al
            color: colorScheme.onSurface, 
          ),
        ),
        Text(
          label, 
          style: theme.textTheme.bodyMedium?.copyWith(
            // Etiket rengini temadan al
            color: colorScheme.onSurfaceVariant
          )
        ),
      ],
    );
  }
}