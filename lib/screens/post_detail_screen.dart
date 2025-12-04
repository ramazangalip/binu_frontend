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
    likeCount = (widget.postData['likes_count'] is int) 
        ? widget.postData['likes_count'] 
        : 0;
    isLiked = widget.postData['is_liked_by_user'] ?? false;
  }
  
  void _toggleLike() {
    setState(() {
      isLiked = !isLiked;
      if (isLiked) {
        likeCount++;
        // BİLDİRİM EKLEME (Simülasyon)
        // Not: Normalde bildirim post sahibine gider.
        // Burada testi görmek için "Sen" adına bildirim ekliyoruz.
        _notificationService.addNotification(
          type: 'like',
          user: 'Sen', 
          avatar: 'https://i.pravatar.cc/150?img=12', // Senin avatarın (Varsayılan)
          content: 'bu gönderiyi beğendin.', 
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gönderiyi beğendin ❤️'), 
            duration: Duration(milliseconds: 500)
          ),
        );
      } else {
        likeCount--;
      }
    });
  }

  void _addComment() {
    if (_commentController.text.trim().isEmpty) return;

    setState(() {
      _comments.add({
        'user': 'Sen',
        'username': '@sen',
        'avatar': 'https://i.pravatar.cc/150?img=12',
        'comment': _commentController.text,
        'time': 'Şimdi',
      });
    });
    
    // BİLDİRİM EKLEME
    _notificationService.addNotification(
       type: 'comment',
       user: 'Sen',
       avatar: 'https://i.pravatar.cc/150?img=12',
       content: 'bu gönderiye yorum yaptın: "${_commentController.text}"',
    );

    _commentController.clear();
    FocusScope.of(context).unfocus(); // Klavyeyi kapat
    
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Yorumun gönderildi 💬'), 
          duration: Duration(milliseconds: 800)
        ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Gönderi'),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                _buildPostContent(),
                _buildPostStats(),
                _buildActionButtons(),
                _buildCommentsSection(),
              ],
            ),
          ),
          _buildCommentComposer(),
        ],
      ),
    );
  }

  // Ana gönderi içeriği
  Widget _buildPostContent() {
    // Null safety kontrolleri
    final user = widget.postData['user'];
    final username = (user is Map) ? (user['username'] ?? 'Anonim') : (widget.postData['username'] ?? 'Anonim');
    final profilePic = (user is Map) ? (user['profileimageurl'] ?? '') : (widget.postData['profilePic'] ?? '');
    final content = (widget.postData['textcontent'] ?? widget.postData['text'] ?? '') + ' #YapayZeka #ÜniversiteHayatı #binu';
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
                onBackgroundImageError: (_,__) {},
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    username,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
          if (imageUrl != null) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPostStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: DefaultTextStyle(
        style: TextStyle(color: Colors.grey.shade600),
        child: Row(
          children: [
            const Text('10 dakika önce'),
            const Text('  •  '),
            const Text('1.250 Görüntüleme'),
            const Text('  •  '),
            Text('$likeCount Beğeni', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        border: Border.symmetric(horizontal: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _ActionButton(icon: Icons.chat_bubble_outline, label: '${_comments.length}'),
          _ActionButton(icon: Icons.repeat, label: '4'),
          
          // Tıklanabilir Beğeni Butonu
          InkWell(
            onTap: _toggleLike,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border, 
                    color: isLiked ? Colors.red : Colors.grey.shade600,
                    size: 24,
                  ),
                  const SizedBox(width: 6),
                  Text('$likeCount', style: TextStyle(color: isLiked ? Colors.red : Colors.grey.shade600)),
                ],
              ),
            ),
          ),
          
          _ActionButton(icon: Icons.bookmark_border, label: '4'),
          _ActionButton(icon: Icons.share_outlined, label: ''),
        ],
      ),
    );
  }

  Widget _buildCommentsSection() {
    return ListView.builder(
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
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(comment['user'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        Text(comment['username'], style: TextStyle(color: Colors.grey.shade600)),
                        const SizedBox(width: 8),
                        Text('• ${comment['time']}', style: TextStyle(color: Colors.grey.shade600)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(comment['comment'], style: const TextStyle(fontSize: 15)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCommentComposer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=12'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: 'Yorumunuzu yazın...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                onSubmitted: (_) => _addComment(),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send, color: Colors.blueAccent),
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
  const _ActionButton({Key? key, required this.icon, required this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          if (label.isNotEmpty) ...[
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: Colors.grey.shade600)),
          ]
        ],
      ),
    );
  }
}