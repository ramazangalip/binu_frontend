import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:binu_frontend/services/api_service.dart';
import 'package:binu_frontend/models/post_model.dart';
import 'package:binu_frontend/providers/auth_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class PostDetailScreen extends StatefulWidget {
  final Post post;

  const PostDetailScreen({
    Key? key,
    required this.post,
  }) : super(key: key);

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _commentController = TextEditingController();

  late Post _currentPost;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentPost = widget.post;
    _fetchPostData();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------
  // HELPER METOTLAR
  // -------------------------------------------------------------

  // URL'den dosya uzantısını çeker
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

  // Post detaylarini (yorumlar ve begeni durumu dahil) API'den ceker
  Future<void> _fetchPostData() async {
    try {
      final updatedPost = await _apiService.getPost(_currentPost.postid);

      if (mounted) {
        setState(() {
          _currentPost = updatedPost;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Post detaylari cekerken hata: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Gonderi detaylari yuklenemedi: ${e.toString()}')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Begenme/Begeniyi Kaldirma API'si
  void _toggleLike() async {
    // Optimistik guncelleme icin onceki durumu kaydet
    final bool previousLikedState = _currentPost.isLikedByUser;
    final int previousLikeCount = _currentPost.likesCount;

    setState(() {
      _currentPost = _currentPost.copyWith(
        isLikedByUser: !previousLikedState,
        likesCount:
            previousLikedState ? previousLikeCount - 1 : previousLikeCount + 1,
      );
    });

    if (_currentPost.isLikedByUser) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            content: Text('Gonderiyi begendin',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary)),
            duration: const Duration(milliseconds: 500),
          ),
        );
      }
    }

    try {
      final result = await _apiService.likePost(_currentPost.postid);

      // Eger API cevabi optimistik guncellemeyle celisirse, UI'i yeniden cek
      if (result['liked'] != _currentPost.isLikedByUser) {
        await _fetchPostData();
      }
    } catch (e) {
      // Hata durumunda UI'i geri al (rollback)
      if (mounted) {
        setState(() {
          _currentPost = _currentPost.copyWith(
            isLikedByUser: previousLikedState,
            likesCount: previousLikeCount,
          );
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Begeni islemi basarisiz: ${e.toString()}')),
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

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          content: Text('Yorum gonderiliyor...',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondary)),
          duration: const Duration(seconds: 1),
        ),
      );
    }

    try {
      await _apiService.addComment(
        postId: _currentPost.postid,
        commentText: newCommentText,
      );

      // Yorumlari yeniden cekerek listeyi guncelle
      await _fetchPostData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).colorScheme.secondary,
            content: Text('Yorumun basariyla gonderildi',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSecondary)),
            duration: const Duration(milliseconds: 800),
          ),
        );
      }
    } catch (e) {
      print('Yorum eklenirken hata: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Yorum gonderilemedi: ${e.toString()}')),
        );
      }
    }
  }

  // Zaman formatlama metodu (Modelden gelen DateTime nesnesini kullanir)
  String _formatTimeAgo(DateTime dateTime) {
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
  }

  // -------------------------------------------------------------
  // WIDGET BUILD METODU VE ALT METOTLAR
  // -------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Gonderi Yukleniyor...')),
        body: Center(child: CircularProgressIndicator(color: colorScheme.primary)),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Gonderi'),
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
          // DINAMIK PROFIL FOTOGRAFI ICIN AUTH PROVIDER'I KULLAN
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return _buildCommentComposer(
                  theme, colorScheme, authProvider.currentUser?.profileimageurl);
            },
          ),
        ],
      ),
    );
  }

  // Ana gonderi icerigi
  Widget _buildPostContent(ThemeData theme, ColorScheme colorScheme) {
    final user = _currentPost.user;
    final profilePic = user.profileimageurl;
    final imageUrl = _currentPost.imageurl;

    final bool hasMedia = imageUrl != null && imageUrl.isNotEmpty;
    final String extension =
        hasMedia ? _getFileExtensionFromUrl(imageUrl!) : '';
    final bool isImage = ['jpg', 'jpeg', 'png', 'gif', 'bmp'].contains(extension);

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
                child: hasProfilePic
                    ? null
                    : Icon(Icons.person,
                        size: 30, color: colorScheme.onPrimary),
                backgroundColor:
                    hasProfilePic ? colorScheme.surfaceVariant : colorScheme.primary,
                onBackgroundImageError: hasProfilePic ? (e, s) => {} : null,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.fullname,
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
            _currentPost.textcontent,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontSize: 16,
              height: 1.5,
              color: colorScheme.onSurface,
            ),
          ),

          // Medya/Dosya Kontrolu
          if (hasMedia) ...[
            const SizedBox(height: 16),
            isImage
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      imageUrl!,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 200,
                          color: colorScheme.surfaceVariant,
                          child: Center(
                              child:
                                  CircularProgressIndicator(color: colorScheme.primary)),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 200,
                        color: colorScheme.surfaceVariant,
                        child: Icon(Icons.broken_image,
                            color: colorScheme.onSurface.withOpacity(0.5)),
                      ),
                    ),
                  )
                : _buildFileDownloadCard(
                    imageUrl!, extension, colorScheme, theme),
          ],
        ],
      ),
    );
  }

  // YENI WIDGET: Dosya Indirme Kartı (URL LAUNCHER AKTIF)
  Widget _buildFileDownloadCard(
      String url, String extension, ColorScheme colorScheme, ThemeData theme) {
    IconData icon;
    if (extension == 'pdf') {
      icon = Icons.picture_as_pdf;
    } else if (['doc', 'docx'].contains(extension)) {
      icon = Icons.description;
    } else {
      icon = Icons.insert_drive_file;
    }

    final fileName = 'Paylasilan Dosya (.${extension.toUpperCase()})';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8.0),
      child: InkWell(
        onTap: () async {
          // GERCEK URL ACMA/INDIRME ISLEMI
          final uri = Uri.parse(url);

          try {
            if (await canLaunchUrl(uri)) {
              // Harici uygulamada (tarayıcı) acmaya zorluyoruz, bu cogu zaman indirmeyi tetikler.
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            } else {
              throw Exception('Baglanti acilamiyor.');
            }
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Dosya acilamadi veya indirilemedi. URL: $url'),
              ),
            );
          }
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.surfaceVariant.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.primary.withOpacity(0.5)),
          ),
          child: Row(
            children: [
              Icon(icon, color: colorScheme.primary, size: 24),
              const SizedBox(width: 12),
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
              Icon(Icons.open_in_new, color: colorScheme.primary),
            ],
          ),
        ),
      ),
    );
  }

  // Gonderi Istatistikleri
  Widget _buildPostStats(ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: DefaultTextStyle(
        style: theme.textTheme.bodySmall!.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        child: Row(
          children: [
            Text(_formatTimeAgo(_currentPost.createdat)),
            const Text(' - '),
            const Text('1.250 Goruntuleme'),
            const Text(' - '),
            Text(
              '${_currentPost.likesCount} Begeni',
              style: theme.textTheme.bodySmall!.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Etkilesim Butonlari (Yorum, Begeni)
  Widget _buildActionButtons(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        border: Border.symmetric(
            horizontal: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Yorum Sayisi Butonu
          _ActionButton(
            icon: Icons.chat_bubble_outline,
            label: '${_currentPost.comments.length}',
            colorScheme: colorScheme,
          ),

          // Tiklanabilir Begeni Butonu
          InkWell(
            onTap: _toggleLike,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Icon(
                    _currentPost.isLikedByUser
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: _currentPost.isLikedByUser
                        ? colorScheme.error
                        : colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${_currentPost.likesCount}',
                    style: TextStyle(
                        color: _currentPost.isLikedByUser
                            ? colorScheme.error
                            : colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Yorumlar Bolumu
  Widget _buildCommentsSection(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
          child: Text(
            'Yorumlar (${_currentPost.comments.length})',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _currentPost.comments.length,
          itemBuilder: (context, index) {
            final comment = _currentPost.comments[index];

            final commenterProfilePic = comment.user.profileimageurl;
            final bool hasCommenterProfilePic =
                commenterProfilePic != null && commenterProfilePic.isNotEmpty;

            return Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: hasCommenterProfilePic
                        ? NetworkImage(commenterProfilePic!)
                        : null,
                    child: hasCommenterProfilePic
                        ? null
                        : Icon(Icons.person,
                            size: 25, color: colorScheme.onPrimary),
                    backgroundColor: hasCommenterProfilePic
                        ? colorScheme.surfaceVariant
                        : colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Yorum Yapan Kullanici Bilgileri Satiri (Wrap ile tasma engellendi)
                        Wrap(
                          spacing: 8, // Ogeler arasindaki yatay bosluk
                          children: [
                            Text(
                              comment.user.fullname,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              '@${comment.user.username}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              '• ${_formatTimeAgo(comment.createdat)}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Yorum Metni (Tasma duzeltildi)
                        Text(
                          comment.commenttext,
                          softWrap: true,
                          overflow: TextOverflow.fade,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 15,
                            color: colorScheme.onSurface,
                          ),
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

  // Yorum Yazma Alani
  Widget _buildCommentComposer(
      ThemeData theme, ColorScheme colorScheme, String? currentUserProfileUrl) {
    // AuthProvider'dan gelen URL'yi kullan, yoksa null olsun.
    final String? profilePic = currentUserProfileUrl;
    final bool hasCurrentUserProfilePic =
        profilePic != null && profilePic.isNotEmpty;

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
              // DINAMIK PROFIL FOTOGRAFI KULLANIMI
              backgroundImage:
                  hasCurrentUserProfilePic ? NetworkImage(profilePic!) : null,
              child: hasCurrentUserProfilePic
                  ? null
                  : Icon(Icons.person, size: 23, color: colorScheme.onPrimary),
              backgroundColor: hasCurrentUserProfilePic
                  ? colorScheme.surfaceVariant
                  : colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: 'Yorumunuzu yazin...',
                  hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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

  const _ActionButton(
      {Key? key,
      required this.icon,
      required this.label,
      required this.colorScheme})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: colorScheme.onSurfaceVariant),
          if (label.isNotEmpty) ...[
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ]
        ],
      ),
    );
  }
}