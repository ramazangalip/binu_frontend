import 'package:binu_frontend/screens/chat_detail_screen.dart'; // Sohbet detay sayfası için
import 'package:flutter/material.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    final List<Map<String, dynamic>> conversations = [
      {
        'name': 'Ayşe Yılmaz',
        'avatar': 'https://i.pravatar.cc/150?img=2',
        'lastMessage': 'Harika, projede görüşürüz o zaman!',
        'time': '10:45',
        'unreadCount': 2,
      },
      {
        'name': 'Mehmet Demir',
        'avatar': 'https://i.pravatar.cc/150?img=3',
        'lastMessage': 'Ders notlarını gönderdim, kontrol edebilir misin?',
        'time': '09:30',
        'unreadCount': 0,
      },
      {
        'name': 'Prof. Dr. Elif Kaya',
        'avatar': 'https://i.pravatar.cc/150?img=4',
        'lastMessage': 'Yarınki dersle ilgili bir duyuru paylaştım.',
        'time': 'Dün',
        'unreadCount': 1,
      },
      {
        'name': 'Caner Ekinci',
        'avatar': 'https://i.pravatar.cc/150?img=5',
        'lastMessage': 'Tamamdır, anlaştık.',
        'time': 'Dün',
        'unreadCount': 0,
      },
    ];

    return Scaffold(
      // Arka plan rengini temadan al
      backgroundColor: theme.scaffoldBackgroundColor, 
      appBar: AppBar(
        title: const Text('Mesajlar'),
        centerTitle: true,
        // AppBar stili (renk ve elevation) AppTheme'dan otomatik gelir
        actions: [
          IconButton(
            onPressed: () {}, 
            icon: const Icon(Icons.add_comment_outlined),
          ),
        ],
      ),
      body: ListView.separated(
        itemCount: conversations.length,
        itemBuilder: (context, index) {
          final conversation = conversations[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            leading: CircleAvatar(
              radius: 28,
              backgroundImage: NetworkImage(conversation['avatar']),
              // Avatar placeholder rengini temadan al
              backgroundColor: colorScheme.surfaceVariant, 
            ),
            title: Text(
              conversation['name'],
              // Metin rengi temadan (onSurface) gelir
              style: theme.textTheme.titleMedium, 
            ),
            subtitle: Text(
              conversation['lastMessage'],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              // Alt metin rengini temadan al
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7), 
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  conversation['time'], 
                  // Zaman metin rengini temadan al
                  style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12)
                ),
                if (conversation['unreadCount'] > 0) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      // Rozet arka plan rengini temadan al
                      color: colorScheme.primary, // was Colors.deepPurple.shade900
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      conversation['unreadCount'].toString(),
                      // Rozet metin rengini temadan al
                      style: TextStyle(color: colorScheme.onPrimary, fontSize: 12), // was Colors.white
                    ),
                  )
                ]
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatDetailScreen(
                    userName: conversation['name'],
                    avatarUrl: conversation['avatar'],
                  ),
                ),
              );
            },
          );
        },
        separatorBuilder: (context, index) => Divider(
          height: 1,
          thickness: 1,
          // Ayırıcı çizgi rengini temadan al
          color: colorScheme.outlineVariant, // was Colors.grey[100]
          indent: 80,
        ),
      ),
    );
  }
}