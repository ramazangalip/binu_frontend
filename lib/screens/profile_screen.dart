import 'package:binu_frontend/screens/chat_detail_screen.dart';
import 'package:binu_frontend/screens/edit_profile_screen.dart';
import 'package:binu_frontend/screens/new_post_screen.dart';
import 'package:flutter/material.dart';
import 'package:binu_frontend/models/post_model.dart'; // User, Post, Comment içerir.
import 'package:binu_frontend/services/api_service.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {
  // 🎯 Liderlik tablosundan geliniyorsa bu ID dolu gelecek.
  final int? userId; 

  const ProfileScreen({Key? key, this.userId}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _selectedTab = 'Hepsi';
  final List<String> _tabs = ['Hepsi'];

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

  // 🚀 HELPER METOT: URL'den dosya uzantısını çeker (Orijinal Kodun)
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

  // -----------------------------------------------------
  // Veri Çekme Metodu (GÜNCELLENDİ: ID Kontrolü Eklendi)
  // -----------------------------------------------------
  Future<void> _fetchProfileData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      User? user;
      List<Post> posts;

      // 🎯 Eğer userId null ise "Benim Profilim", değilse "Başkasının Profili"
      if (widget.userId == null) {
        user = await _apiService.fetchUserProfile();
        posts = await _apiService.fetchUserPosts();
      } else {
        user = await _apiService.fetchUserById(widget.userId!);
        posts = await _apiService.fetchUserPostsById(widget.userId!);
      }

      final postCategories = posts.map((p) => p.category).toSet().toList();
      _tabs.clear();
      _tabs.add('Hepsi');
      _tabs.addAll(postCategories);

      if (!_tabs.contains(_selectedTab)) {
        _selectedTab = _tabs.first;
      }

      if (mounted) {
        setState(() {
          _userProfile = user;
          _allPosts = posts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Profil verileri yüklenemedi. Hata: ${e.toString().split(':').last.trim()}';
          _isLoading = false;
        });
      }
    }
  }

  List<Post> get _filteredPosts {
    if (_selectedTab == 'Hepsi') return _allPosts;
    return _allPosts.where((post) => post.category == _selectedTab).toList();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final bool isMyProfile = widget.userId == null;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // Başkasının profilindeyken geri dönmek için AppBar ekliyoruz
      appBar: !isMyProfile 
          ? AppBar(title: Text(_userProfile?.fullname ?? 'Profil'), elevation: 0.5) 
          : null,

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
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        _buildProfileHeader(theme, colorScheme, _userProfile),
                        _buildActionButtons(colorScheme, isMyProfile),
                        const SizedBox(height: 24),
                        _buildFilterTabs(theme, colorScheme),
                        _buildPostsGrid(theme, colorScheme),
                        const SizedBox(height: 80), 
                      ],
                    ),
                  ),
                ),
      floatingActionButton: isMyProfile ? FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NewPostScreen()),
          );
          _fetchProfileData();
        },
        backgroundColor: colorScheme.secondary,
        child: Icon(Icons.add, color: colorScheme.onSecondary),
      ) : null,
    );
  }

  Widget _buildProfileHeader(ThemeData theme, ColorScheme colorScheme, User? user) {
    final String fullName = user?.fullname ?? 'Kullanıcı Adı';
    final String username = user?.username ?? '@kullanici';
    final String bio = user?.biography ?? 'Henüz biyografi eklenmedi.';
    final String avatarUrl = (user?.profileimageurl != null && user!.profileimageurl!.isNotEmpty)
      ? user.profileimageurl!
      : 'https://via.placeholder.com/150';

    final String followers = NumberFormat.compact().format(user?.followersCount ?? 0);
    final String following = NumberFormat.compact().format(user?.followingCount ?? 0);
    final String postsCount = NumberFormat.compact().format(_allPosts.length);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
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

  // 🎯 GÜNCELLENDİ: Butonlar profile göre değişir ve paylaş butonu isMyProfile ise kaldırıldı
  Widget _buildActionButtons(ColorScheme colorScheme, bool isMyProfile) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: isMyProfile ? 16.0 : 4.0, // Kendi profiliyse tam genişlik için sağ boşluk arttı
              left: 16.0,
            ),
            child: OutlinedButton(
              onPressed: () async {
                if (isMyProfile) {
                  await Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen()));
                  _fetchProfileData();
                } else {
                  // Takip etme fonksiyonu
                  await _apiService.toggleFollow(widget.userId!);
                  _fetchProfileData();
                }
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: isMyProfile ? Colors.transparent : colorScheme.primary,
                foregroundColor: isMyProfile ? colorScheme.onSurface : colorScheme.onPrimary,
                side: BorderSide(color: isMyProfile ? colorScheme.outlineVariant : colorScheme.primary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(isMyProfile ? 'Profili Düzenle' : 'Takip Et'),
            ),
          ),
        ),
        // 🚀 PAYLAŞ / MESAJ GÖNDER KONTROLÜ
        if (!isMyProfile) // Eğer kendi profilim DEĞİLSE bu butonu göster
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 4.0, right: 16.0),
              child: OutlinedButton(
                onPressed: () {
                  if (_userProfile != null) {
                    // 🚀 Sohbet detay ekranına yönlendirme
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatDetailScreen(
                          userId: _userProfile!.userid ?? widget.userId!,
                          userName: _userProfile!.fullname,
                          avatarUrl: (_userProfile!.profileimageurl != null && _userProfile!.profileimageurl!.isNotEmpty)
                              ? _userProfile!.profileimageurl!
                              : Icons.person.toString(),
                        ),
                      ),
                    );
                  }
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(color: colorScheme.outlineVariant),
                  foregroundColor: colorScheme.onSurface,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Mesaj Gönder'),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFilterTabs(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colorScheme.outlineVariant, width: 1.0)),
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
                color: isSelected ? colorScheme.primaryContainer.withOpacity(0.4) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border(bottom: BorderSide(color: isSelected ? colorScheme.primary : Colors.transparent, width: 2.0)),
              ),
              child: Center(
                child: Text(
                  tab,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPostsGrid(ThemeData theme, ColorScheme colorScheme) {
    if (_filteredPosts.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(64.0),
        child: Center(child: Text('Seçili kategoride henüz bir gönderi yok.')),
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: _filteredPosts.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.75,
      ),
      itemBuilder: (context, index) => _buildPostCard(_filteredPosts[index], theme, colorScheme),
    );
  }

  Widget _buildPostCard(Post post, ThemeData theme, ColorScheme colorScheme) {
    final String? imageUrl = post.imageurl;
    final formattedDate = DateFormat('dd MMMM yyyy').format(post.createdat);
    final bool hasMedia = imageUrl != null && imageUrl.isNotEmpty;
    final String extension = hasMedia ? _getFileExtensionFromUrl(imageUrl!) : '';
    final bool isImage = ['jpg', 'jpeg', 'png', 'gif', 'bmp'].contains(extension);

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasMedia)
            isImage
              ? ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(imageUrl!, height: 120, width: double.infinity, fit: BoxFit.cover),
                )
              : _buildPostFileCard(imageUrl!, extension, colorScheme, theme),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.textcontent.length > 50 ? '${post.textcontent.substring(0, 50)}...' : post.textcontent,
                  style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                  maxLines: hasMedia ? 2 : 4,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(formattedDate, style: theme.textTheme.bodySmall?.copyWith(fontSize: 12)),
                const SizedBox(height: 8),
                _buildStatusIndicator(post.status, colorScheme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostFileCard(String url, String extension, ColorScheme colorScheme, ThemeData theme) {
    IconData icon = (extension == 'pdf') ? Icons.picture_as_pdf : (['doc', 'docx'].contains(extension) ? Icons.description : Icons.insert_drive_file);
    return InkWell(
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
      },
      child: Container(
        height: 120,
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceVariant.withOpacity(0.5),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: colorScheme.primary, size: 30),
              const SizedBox(height: 8),
              Text('Dosya.${extension.toUpperCase()}', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
              Text('Açmak için dokunun', style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.primary, fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(String status, ColorScheme colorScheme) {
    IconData icon;
    Color color;
    switch (status) {
      case 'Yayınlandı': icon = Icons.check_circle; color = Colors.green.shade600; break;
      case 'Taslak': icon = Icons.edit_note; color = Colors.orange.shade600; break;
      case 'Planlandı': icon = Icons.timer_outlined; color = colorScheme.primary; break;
      default: icon = Icons.circle; color = colorScheme.onSurfaceVariant;
    }
    return Row(
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 4),
        Text(status, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label, value;
  final ThemeData theme;
  final ColorScheme colorScheme;
  const _StatItem({required this.label, required this.value, required this.theme, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 18)),
        Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
      ],
    );
  }
}