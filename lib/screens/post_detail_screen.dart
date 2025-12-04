import 'package:binu_frontend/services/notification_service.dart'; // Servis Eklendi
import 'package:flutter/material.dart';

class PostDetailScreen extends StatefulWidget {
  final Map<String, dynamic> postData;

  const PostDetailScreen({
    Key? key,
    required this.postData,
  }) : super(key: key);

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final NotificationService _notificationService = NotificationService(); // Servis Örneği
  final TextEditingController _commentController = TextEditingController();
  
  // Beğeni durumu (Simülasyon için)
  bool isLiked = false;
  int likeCount = 0;

  List<Map<String, dynamic>> _comments = [
    {
      'user': 'Elif Kaya',
      'username': '@elifkaya',
      'avatar': 'https://i.pravatar.cc/150?img=4',
      'comment': 'Kesinlikle! Ben de çok etkilendim.',
      'time': '5 dakika önce',
    },
    // ... diğer yorumlar
  ];

  @override
  void initState() {
    super.initState();
    // Backend'den gelen veriyi güvenli şekilde al
    // Not: Home Screen'den gelen postData'da 'likes' ve 'comments' var, bu yüzden onları kullanmalıyız.
    likeCount = widget.postData['likes'] ?? 0;
    
    // Varsayılan olarak isLiked durumu yok, simülasyon için false
    isLiked = false; 
  }
  
  void _toggleLike() {
    setState(() {
      isLiked = !isLiked;
      if (isLiked) {
        likeCount++;
        // BİLDİRİM EKLEME (Simülasyon)
        _notificationService.addNotification(
          type: 'like',
          user: 'Sen', 
          avatar: 'https://i.pravatar.cc/150?img=12', // Senin avatarın (Varsayılan)
          content: 'bu gönderiyi beğendin.', 
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            // Snackbar renkleri temadan alınacak
            backgroundColor: Theme.of(context).colorScheme.primary,
            content: Text(
              'Gönderiyi beğendin ❤️', 
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)
            ), 
            duration: const Duration(milliseconds: 500)
          ),
        );
      } else {
        likeCount--;
      }
    });
  }

  void _addComment() {
    if (_commentController.text.trim().isEmpty) return;
    
    final newCommentText = _commentController.text;

    setState(() {
      _comments.add({
        'user': 'Sen',
        'username': '@sen',
        'avatar': 'https://i.pravatar.cc/150?img=12',
        'comment': newCommentText,
        'time': 'Şimdi',
      });
    });
    
    // BİLDİRİM EKLEME
    _notificationService.addNotification(
        type: 'comment',
        user: 'Sen',
        avatar: 'https://i.pravatar.cc/150?img=12',
        content: 'bu gönderiye yorum yaptın: "$newCommentText"',
    );

    _commentController.clear();
    FocusScope.of(context).unfocus(); // Klavyeyi kapat
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        // Snackbar renkleri temadan alınacak
        backgroundColor: Theme.of(context).colorScheme.secondary,
        content: Text(
          'Yorumun gönderildi 💬', 
          style: TextStyle(color: Theme.of(context).colorScheme.onSecondary)
        ), 
        duration: const Duration(milliseconds: 800)
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    
    return Scaffold(
      // Arka plan rengini temadan al
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Gönderi'),
        // AppBar stili AppTheme'dan otomatik gelir
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
    // Null safety kontrolleri
    final user = widget.postData['user'];
    final username = (user is Map) ? (user['username'] ?? 'Anonim') : (widget.postData['username'] ?? 'Anonim');
    final profilePic = (user is Map) ? (user['profileimageurl'] ?? '') : (widget.postData['profilePic'] ?? '');
    final content = (widget.postData['textcontent'] ?? widget.postData['text'] ?? '');
    final imageUrl = widget.postData['imageurl'] ?? widget.postData['image'];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage(profilePic),
                // Avatar placeholder rengini temadan al
                backgroundColor: colorScheme.surfaceVariant, 
                onBackgroundImageError: (_,__) {},
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    username,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold, 
                      fontSize: 16,
                      // Metin rengini temadan al
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
            content,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontSize: 16, 
              height: 1.5,
              // Metin rengini temadan al
              color: colorScheme.onSurface, 
            ),
          ),
          if (imageUrl != null) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                // Resim yüklenirken veya hata oluşursa temaya uygun placeholder
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
          // İstatistik metin rengini temadan al
          color: colorScheme.onSurfaceVariant,
        ),
        child: Row(
          children: [
            Text(widget.postData['time'] ?? '10 dakika önce'),
            const Text('  •  '),
            const Text('1.250 Görüntüleme'),
            const Text('  •  '),
            Text(
              '$likeCount Beğeni', 
              style: theme.textTheme.bodySmall!.copyWith(
                fontWeight: FontWeight.bold, 
                // Beğeni sayısının rengini temadan al
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
        // Çizgi rengini temadan al
        border: Border.symmetric(horizontal: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Yorum Sayısı Butonu
          _ActionButton(
            icon: Icons.chat_bubble_outline, 
            label: '${_comments.length}',
            colorScheme: colorScheme,
          ),
          // Yeniden Paylaş Butonu
          _ActionButton(
            icon: Icons.repeat, 
            label: widget.postData['shares']?.toString() ?? '4',
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
                    isLiked ? Icons.favorite : Icons.favorite_border, 
                    // Beğenme rengini temadan al
                    color: isLiked ? colorScheme.error : colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$likeCount', 
                    style: TextStyle(
                      // Metin rengini temadan al
                      color: isLiked ? colorScheme.error : colorScheme.onSurfaceVariant
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
            'Yorumlar (${_comments.length})',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _comments.length,
          itemBuilder: (context, index) {
            final comment = _comments[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(comment['avatar']),
                    // Avatar placeholder rengini temadan al
                    backgroundColor: colorScheme.surfaceVariant, 
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              comment['user'], 
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                // Metin rengini temadan al
                                color: colorScheme.onSurface, 
                              )
                            ),
                            const SizedBox(width: 8),
                            Text(
                              comment['username'], 
                              style: theme.textTheme.bodySmall?.copyWith(
                                // İkincil metin rengini temadan al
                                color: colorScheme.onSurfaceVariant, 
                              )
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '• ${comment['time']}', 
                              style: theme.textTheme.bodySmall?.copyWith(
                                // İkincil metin rengini temadan al
                                color: colorScheme.onSurfaceVariant,
                              )
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          comment['comment'], 
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 15,
                            // Metin rengini temadan al
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      // Arka planı ve çerçeveyi temadan al
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: const NetworkImage('https://i.pravatar.cc/150?img=12'),
              // Avatar placeholder rengini temadan al
              backgroundColor: colorScheme.surfaceVariant, 
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _commentController,
                // InputDecoration stili AppTheme'dan geliyor.
                decoration: InputDecoration(
                  hintText: 'Yorumunuzu yazın...',
                  hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                  // fillColor: Colors.white, kaldırıldı. AppTheme'dan geliyor.
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    // Çerçeve rengi AppTheme'dan geliyor, burada sadece focus rengini dinamikleştirelim
                    borderSide: BorderSide.none, 
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                onSubmitted: (_) => _addComment(),
              ),
            ),
            IconButton(
              // İkon rengini temadan al
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
            // İkon rengini temadan al
            color: colorScheme.onSurfaceVariant
          ),
          if (label.isNotEmpty) ...[
            const SizedBox(width: 6),
            Text(
              label, 
              style: TextStyle(
                // Metin rengini temadan al
                color: colorScheme.onSurfaceVariant
              )
            ),
          ]
        ],
      ),
    );
  }
}