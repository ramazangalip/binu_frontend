import 'package:flutter/material.dart';
import 'package:binu_frontend/services/notification_service.dart';
import 'package:binu_frontend/services/api_service.dart';
import 'package:binu_frontend/models/post_model.dart'; // Post, User, Comment modelleriniz buradan geliyor

class PostDetailScreen extends StatefulWidget {
  // Parametre Map yerine doğrudan Post modeli olarak güncellendi.
  final Post post;

  const PostDetailScreen({
    Key? key,
    required this.post,
  }) : super(key: key);

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final NotificationService _notificationService = NotificationService();
  final ApiService _apiService = ApiService();
  final TextEditingController _commentController = TextEditingController();

  // State'i yönetmek için widget.post'tan bir kopya oluşturuyoruz (mutasyon için)
  late Post _currentPost;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Başlangıçta gelen post verilerini kullan
    _currentPost = widget.post;

    // Post detay ekranı açıldığında güncel verileri çek
    _fetchPostData();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------
  // API İŞLEMLERİ (Model Kullanımı)
  // -------------------------------------------------------------

  // Post detaylarını (yorumlar ve beğeni durumu dahil) API'den çeker
  Future<void> _fetchPostData() async {
    try {
      // getPost metodu, yorumları ve beğeni durumunu içinde barındıran tam Post objesini döner
      final updatedPost = await _apiService.getPost(_currentPost.postid);

      setState(() {
        _currentPost = updatedPost;
        _isLoading = false;
      });
    } catch (e) {
      print('Post detayları çekerken hata: $e');
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gönderi detayları yüklenemedi: ${e.toString()}')),
        );
      }
      setState(() {
        _isLoading = false;
      });
    }
  }


  // Beğenme/Beğeniyi Kaldırma API'si
  void _toggleLike() async {
    // Optimistik güncelleme
    final bool previousLikedState = _currentPost.isLikedByUser;
    final int previousLikeCount = _currentPost.likesCount;

    setState(() {
      _currentPost = _currentPost.copyWith(
        isLikedByUser: !previousLikedState,
        likesCount: previousLikedState ? previousLikeCount - 1 : previousLikeCount + 1,
      );
    });

    if (_currentPost.isLikedByUser) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          content: Text('Gönderiyi beğendin ❤️', style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
          duration: const Duration(milliseconds: 500)
        ),
      );
    }

    try {
      final result = await _apiService.likePost(_currentPost.postid);

      // Eğer API cevabı optimistik güncellemeyle çelişirse (örn: sunucu hatası), UI'ı API'den gelen son duruma göre güncelle.
      // Django'dan dönen liked: true/false değerini kullanıyoruz.
      if(result['liked'] != _currentPost.isLikedByUser) {
        await _fetchPostData(); // Hata oluşursa post'u yeniden çek
      }

      if (result['liked'] == true) {
        _notificationService.addNotification(
          type: 'like', user: 'Sen', avatar: '', content: 'bu gönderiyi beğendin.',
        );
      }

    } catch (e) {
      // Hata durumunda UI'ı geri al (rollback)
      setState(() {
        _currentPost = _currentPost.copyWith(
          isLikedByUser: previousLikedState,
          likesCount: previousLikeCount,
        );
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Beğeni işlemi başarısız: ${e.toString()}')),
        );
      }
    }
  }

  // Yorum Ekleme API'si
  void _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    final newCommentText = _commentController.text;
    _commentController.clear();
    FocusScope.of(context).unfocus();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        content: Text('Yorum gönderiliyor...', style: TextStyle(color: Theme.of(context).colorScheme.onSecondary)),
        duration: const Duration(seconds: 1)
      ),
    );

    try {
      await _apiService.addComment(
        postId: _currentPost.postid,
        commentText: newCommentText,
      );

      // Yorumları yeniden çekerek listeyi güncelle (bu, _currentPost'u güncelleyecektir)
      await _fetchPostData();

      // BİLDİRİM EKLEME
      _notificationService.addNotification(
        type: 'comment',
        user: 'Sen',
        avatar: '',
        content: 'bu gönderiye yorum yaptın: "$newCommentText"',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).colorScheme.secondary,
            content: Text('Yorumun başarıyla gönderildi 💬', style: TextStyle(color: Theme.of(context).colorScheme.onSecondary)),
            duration: const Duration(milliseconds: 800)
          ),
        );
      }

    } catch (e) {
      print('Yorum eklenirken hata: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Yorum gönderilemedi: ${e.toString()}')),
        );
      }
    }
  }

  // Zaman formatlama metodu (Modelden gelen DateTime nesnesini kullanır)
  String _formatTimeAgo(DateTime dateTime) {
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
  }

  // -------------------------------------------------------------
  // WIDGET BUILD METODU VE ALT METOTLAR (Model Kullanımı)
  // -------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Gönderi Yükleniyor...')),
        body: Center(child: CircularProgressIndicator(color: colorScheme.primary)),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Gönderi'),
        elevation: 0.5,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                _buildPostContent(theme, colorScheme),
                _buildPostStats(theme, colorScheme),
                _buildActionButtons(theme, colorScheme),
                _buildCommentsSection(theme, colorScheme),
              ],
            ),
          ),
          _buildCommentComposer(theme, colorScheme),
        ],
      ),
    );
  }

  // Ana gönderi içeriği
  Widget _buildPostContent(ThemeData theme, ColorScheme colorScheme) {
    // Doğrudan modelden erişim
    final user = _currentPost.user;
    final profilePic = user.profileimageurl;
    final imageUrl = _currentPost.imageurl;

    // Profil fotoğrafı kontrolü
    final bool hasProfilePic = profilePic != null && profilePic.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: hasProfilePic ? NetworkImage(profilePic!) : null,
                child: hasProfilePic ? null : Icon(Icons.person, size: 30, color: colorScheme.onPrimary),
                backgroundColor: hasProfilePic ? colorScheme.surfaceVariant : colorScheme.primary,
                onBackgroundImageError: hasProfilePic ? (e, s) => {} : null,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.fullname, // Modelden
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _currentPost.textcontent, // Modelden
            style: theme.textTheme.bodyLarge?.copyWith(
              fontSize: 16,
              height: 1.5,
              color: colorScheme.onSurface,
            ),
          ),
          if (imageUrl != null && imageUrl.isNotEmpty) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 200,
                    color: colorScheme.surfaceVariant,
                    child: Center(child: CircularProgressIndicator(color: colorScheme.primary)),
                  );
                },
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  color: colorScheme.surfaceVariant,
                  child: Icon(Icons.broken_image, color: colorScheme.onSurface.withOpacity(0.5)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Gönderi İstatistikleri
  Widget _buildPostStats(ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: DefaultTextStyle(
        style: theme.textTheme.bodySmall!.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        child: Row(
          children: [
            Text(_formatTimeAgo(_currentPost.createdat)), // Modelden gelen DateTime
            const Text('  •  '),
            const Text('1.250 Görüntüleme'),
            const Text('  •  '),
            Text(
              '${_currentPost.likesCount} Beğeni', // Modelden
              style: theme.textTheme.bodySmall!.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              )
            ),
          ],
        ),
      ),
    );
  }

  // Etkileşim Butonları (Yorum, Paylaş vb.)
  Widget _buildActionButtons(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        border: Border.symmetric(horizontal: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Yorum Sayısı Butonu
          _ActionButton(
            icon: Icons.chat_bubble_outline,
            label: '${_currentPost.comments.length}', // Modelden
            colorScheme: colorScheme,
          ),
          // Yeniden Paylaş Butonu
          _ActionButton(
            icon: Icons.repeat,
            label: _currentPost.sharecount.toString(), // Modelden
            colorScheme: colorScheme,
          ),

          // Tıklanabilir Beğeni Butonu
          InkWell(
            onTap: _toggleLike,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Icon(
                    _currentPost.isLikedByUser ? Icons.favorite : Icons.favorite_border, // Modelden
                    color: _currentPost.isLikedByUser ? colorScheme.error : colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${_currentPost.likesCount}', // Modelden
                    style: TextStyle(
                      color: _currentPost.isLikedByUser ? colorScheme.error : colorScheme.onSurfaceVariant
                    )
                  ),
                ],
              ),
            ),
          ),

          // Kaydet Butonu
          _ActionButton(icon: Icons.bookmark_border, label: '4', colorScheme: colorScheme),
          // Paylaş Butonu
          _ActionButton(icon: Icons.share_outlined, label: '', colorScheme: colorScheme),
        ],
      ),
    );
  }

  // Yorumlar Bölümü
  Widget _buildCommentsSection(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
          child: Text(
            'Yorumlar (${_currentPost.comments.length})', // Modelden
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _currentPost.comments.length, // Modelden
          itemBuilder: (context, index) {
            final comment = _currentPost.comments[index]; // Modelden

            // Profil fotoğrafı kontrolü
            final commenterProfilePic = comment.user.profileimageurl;
            final bool hasCommenterProfilePic = commenterProfilePic != null && commenterProfilePic.isNotEmpty;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 20,
                    // Yorum yapanın profil resmi
                    backgroundImage: hasCommenterProfilePic ? NetworkImage(commenterProfilePic!) : null,
                    child: hasCommenterProfilePic ? null : Icon(Icons.person, size: 25, color: colorScheme.onPrimary),
                    backgroundColor: hasCommenterProfilePic ? colorScheme.surfaceVariant : colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              comment.user.fullname,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              )
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '@${comment.user.username}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              )
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '• ${_formatTimeAgo(comment.createdat)}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              )
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          comment.commenttext,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 15,
                            color: colorScheme.onSurface,
                          )
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // Yorum Yazma Alanı
  Widget _buildCommentComposer(ThemeData theme, ColorScheme colorScheme) {
    // Yorum yazan kullanıcının profil fotoğrafı kontrolü (Simülasyon için sabit varsayım)
    const String currentUserAvatarUrl = 'https://i.pravatar.cc/150?img=12';
    final bool hasCurrentUserProfilePic = currentUserAvatarUrl.isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: hasCurrentUserProfilePic ? NetworkImage(currentUserAvatarUrl) : null,
              child: hasCurrentUserProfilePic ? null : Icon(Icons.person, size: 23, color: colorScheme.onPrimary),
              backgroundColor: hasCurrentUserProfilePic ? colorScheme.surfaceVariant : colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: 'Yorumunuzu yazın...',
                  hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                onSubmitted: (_) => _addComment(),
              ),
            ),
            IconButton(
              icon: Icon(Icons.send, color: colorScheme.primary),
              onPressed: _addComment,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final ColorScheme colorScheme;

  const _ActionButton({Key? key, required this.icon, required this.label, required this.colorScheme}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: colorScheme.onSurfaceVariant
          ),
          if (label.isNotEmpty) ...[
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant
              )
            ),
          ]
        ],
      ),
    );
  }
}