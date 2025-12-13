import 'package:binu_frontend/screens/edit_profile_screen.dart';
import 'package:binu_frontend/screens/new_post_screen.dart';
import 'package:flutter/material.dart';
import 'package:binu_frontend/models/post_model.dart'; // User, Post, Comment içerir.
import 'package:binu_frontend/services/api_service.dart';
import 'package:intl/intl.dart'; 

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _selectedTab = 'Hepsi';
  final List<String> _tabs = ['Hepsi']; // API'den gelen kategorilerle dinamik olarak doldurulacak

  // -----------------------------------------------------
  // API ve State Değişkenleri (Dinamik Veri)
  // -----------------------------------------------------
  final ApiService _apiService = ApiService();
  User? _userProfile; 
  List<Post> _allPosts = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    Intl.defaultLocale = 'tr_TR'; 
    _fetchProfileData();
  }
  
  // -----------------------------------------------------
  // Veri Çekme Metodu
  // -----------------------------------------------------
  Future<void> _fetchProfileData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await _apiService.fetchUserProfile();
      final posts = await _apiService.fetchUserPosts(); 

      // Sekmeleri dinamik olarak güncelle
      final postCategories = posts.map((p) => p.category).toSet().toList();
      _tabs.clear();
      _tabs.add('Hepsi');
      _tabs.addAll(postCategories);
      _selectedTab = _tabs.first;

      setState(() {
        _userProfile = user;
        _allPosts = posts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Profil verileri yüklenemedi. Hata: ${e.toString().split(':').last.trim()}';
        _isLoading = false;
      });
    }
  }

  // Filtrelenmiş gönderiler artık Post modelini kullanır
  List<Post> get _filteredPosts {
    if (_selectedTab == 'Hepsi') {
      return _allPosts;
    }
    return _allPosts
        .where((post) => post.category == _selectedTab)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, 

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_errorMessage!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _fetchProfileData,
                          child: const Text('Tekrar Dene'),
                        )
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchProfileData,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // DİNAMİK: _userProfile'ı gönderiyoruz
                        _buildProfileHeader(theme, colorScheme, _userProfile), 
                        _buildActionButtons(colorScheme),
                        const SizedBox(height: 24),
                        _buildFilterTabs(theme, colorScheme),
                        _buildPostsGrid(theme, colorScheme),
                        const SizedBox(height: 80), // FAB için boşluk
                      ],
                    ),
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NewPostScreen()),
          );
          // Yeni gönderi eklenince verileri yenile
          _fetchProfileData(); 
        },
        backgroundColor: colorScheme.secondary, 
        child: Icon(Icons.add, color: colorScheme.onSecondary), 
      ),
    );
  }
  
  // -----------------------------------------------------
  // Profil Başlık Bölümü (DİNAMİK)
  // -----------------------------------------------------
  Widget _buildProfileHeader(ThemeData theme, ColorScheme colorScheme, User? user) {
    final String fullName = user?.fullname ?? 'Kullanıcı Adı';
    final String username = user?.username ?? '@kullanici';
    
    // DİNAMİK: Biography bilgisini API'den çek
    final String bio = user?.biography ?? 'Henüz biyografi eklenmedi.'; 
    
    // DİNAMİK: Profil fotoğrafı URL'sini API'den çek
    final String avatarUrl = user?.profileimageurl ?? 'https://i.pravatar.cc/150?img=12'; 
    
    final String followers = NumberFormat.compact().format(user?.followersCount ?? 0);
    final String following = NumberFormat.compact().format(user?.followingCount ?? 0);
    final String postsCount = NumberFormat.compact().format(_allPosts.length);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            // DİNAMİK: NetworkImage kullanıldı
            backgroundImage: NetworkImage(avatarUrl), 
            backgroundColor: colorScheme.surfaceVariant, 
          ),
          const SizedBox(height: 12),
          Text(
            fullName,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontSize: 22, 
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface, 
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '@$username',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 15, 
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            // DİNAMİK: Biyografi kullanıldı
            bio, 
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 14, 
              height: 1.5,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatItem(value: followers, label: 'Takipçi', theme: theme, colorScheme: colorScheme),
              _StatItem(value: following, label: 'Takip Edilen', theme: theme, colorScheme: colorScheme),
              _StatItem(value: postsCount, label: 'Gönderiler', theme: theme, colorScheme: colorScheme),
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
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditProfileScreen(),
                  ),
                );
                // Profil düzenlendikten sonra veriyi yenile
                _fetchProfileData(); 
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: BorderSide(color: colorScheme.outlineVariant), 
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
                side: BorderSide(color: colorScheme.outlineVariant), 
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
          
          final selectedBg = colorScheme.primaryContainer.withOpacity(0.4); 
          final selectedFg = colorScheme.primary; 

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
    if (_filteredPosts.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(64.0),
        child: Center(
          child: Text('Seçili kategoride henüz bir gönderi yok.'),
        ),
      );
    }
    
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
        // DİNAMİK: Post modelini gönderiyoruz
        return _buildPostCard(_filteredPosts[index], theme, colorScheme);
      },
    );
  }

  // Tek bir gönderi kartı (Post modelini kullanır)
  Widget _buildPostCard(Post post, ThemeData theme, ColorScheme colorScheme) {
    
    // API'dan çekilen Post modelinden imageurl alanını çek
    final String? imageUrl = post.imageurl;
    final formattedDate = DateFormat('dd MMMM yyyy').format(post.createdat);
    
    // Resim var mı kontrol et
    final bool hasImage = imageUrl != null && imageUrl.isNotEmpty;
    
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface, 
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant), 
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sadece resim varsa göster
          if (hasImage)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                imageUrl,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 120,
                  color: colorScheme.surfaceVariant,
                  child: Center(
                    child: Icon(
                      Icons.broken_image, 
                      color: colorScheme.onSurface.withOpacity(0.5)
                    )
                  ),
                ),
              ),
            ),
          
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface, 
                  ),
                  maxLines: hasImage ? 2 : 4,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  formattedDate,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 12, 
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                _buildStatusIndicator(post.status, colorScheme),
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
    
    switch (status) {
      case 'Yayınlandı':
        icon = Icons.check_circle;
        color = Colors.green.shade600; 
        break;
      case 'Taslak':
        icon = Icons.edit_note;
        color = Colors.orange.shade600; 
        break;
      case 'Planlandı':
        icon = Icons.timer_outlined;
        color = colorScheme.primary; 
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
            color: colorScheme.onSurface, 
          ),
        ),
        Text(
          label, 
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant
          )
        ),
      ],
    );
  }
}