import 'package:flutter/material.dart';

class PostDetailScreen extends StatefulWidget {
  // HomeScreen'den tıklanan gönderinin verisini almak için
  final Map<String, dynamic> postData;

  const PostDetailScreen({
    Key? key,
    required this.postData,
  }) : super(key: key);

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  // Örnek yorum listesi
  final List<Map<String, dynamic>> _comments = [
    {
      'user': 'Elif Kaya',
      'username': '@elifkaya',
      'avatar': 'https://i.pravatar.cc/150?img=4',
      'comment': 'Kesinlikle! Ben de çok etkilendim. Özellikle derin öğrenme kısmı ufuk açıcıydı.',
      'time': '5 dakika önce',
    },
    {
      'user': 'Ahmet Mert',
      'username': '@ahmetmert',
      'avatar': 'https://i.pravatar.cc/150?img=8',
      'comment': 'Hangi proje fikri bu? Merak ettim. Belki birlikte çalışabiliriz!',
      'time': '2 dakika önce',
    },
    {
      'user': 'Ayşe Demir',
      'username': '@aysedemir',
      'avatar': 'https://i.pravatar.cc/150?img=2',
      'comment': 'Prof. Caner her zaman en iyisi! 🎊 Bence bu ders tüm üniversitede zorunlu olmalı.',
      'time': '1 dakika önce',
    },
  ];

  final TextEditingController _commentController = TextEditingController();

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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage(widget.postData['profilePic']),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.postData['username'],
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    '@${widget.postData['username'].toLowerCase().replaceAll(' ', '')}',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Takip Et'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple.shade900,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.postData['text'] + ' #YapayZeka #ÜniversiteHayatı #binu',
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
          if (widget.postData['image'] != null) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(widget.postData['image']),
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
            Text('${widget.postData['likes']} Beğeni', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
          ],
        ),
      ),
    );
  }


  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _ActionButton(icon: Icons.chat_bubble_outline, label: '17'),
          _ActionButton(icon: Icons.repeat, label: '4'),
          _ActionButton(icon: Icons.favorite_border, label: '185'),
          _ActionButton(icon: Icons.bookmark_border, label: '4'),
          _ActionButton(icon: Icons.share_outlined, label: ''),
        ],
      ),
    );
  }

  // Yorumlar bölümü
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
                        Text(
                          comment['user'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          comment['username'],
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
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

  // Yorum yazma alanı
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
                   enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Etkileşim butonu için yardımcı widget
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  const _ActionButton({Key? key, required this.icon, required this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        if (label.isNotEmpty) ...[
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
        ]
      ],
    );
  }
}
