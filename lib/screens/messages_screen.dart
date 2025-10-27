import 'package:binu_frontend/screens/chat_detail_screen.dart'; // Sohbet detay sayfası için
import 'package:flutter/material.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Mesajlar'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.add_comment_outlined)),
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
            ),
            title: Text(
              conversation['name'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              conversation['lastMessage'],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(conversation['time'], style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                if (conversation['unreadCount'] > 0) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.shade900,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      conversation['unreadCount'].toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
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
          color: Colors.grey[100],
          indent: 80,
        ),
      ),
    );
  }
}
