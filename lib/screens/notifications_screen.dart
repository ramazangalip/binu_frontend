import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Tasarıma uygun, farklı bildirim türlerini içeren veri listesi
    final List<Map<String, dynamic>> notifications = [
      {
        'type': 'like',
        'user': 'Ayşe Yılmaz',
        'avatar': 'https://i.pravatar.cc/150?img=2',
        'content': 'bir gönderini beğendi.',
        'time': '2 dakika önce',
      },
      {
        'type': 'comment',
        'user': 'Mehmet Demir',
        'avatar': 'https://i.pravatar.cc/150?img=3',
        'content': 'hakkındaki "Proje Takvimi" gönderine yorum yaptı.',
        'time': '15 dakika önce',
      },
      {
        'type': 'course_announcement',
        'user': 'Prof. Dr. Elif Kaya',
        'avatar': 'https://i.pravatar.cc/150?img=4',
        'content': 'yeni bir ders duyurusu paylaştı.',
        'time': '1 saat önce',
      },
      {
        'type': 'follow',
        'user': 'Caner Ekinci',
        'avatar': 'https://i.pravatar.cc/150?img=5',
        'content': 'seni takip etmeye başladı.',
        'time': '3 saat önce',
      },
      {
        'type': 'mention',
        'user': 'Deniz Arslan',
        'avatar': 'https://i.pravatar.cc/150?img=7',
        'content': 'hakkındaki bir gönderide senden bahsetti.',
        'time': 'Dün',
      },
      {
        'type': 'project_update',
        'user': 'Emre Gündoğdu',
        'avatar': 'https://i.pravatar.cc/150?img=8',
        'content': 'gönderini "Bitirme Projesi" panosuna ekledi.',
        'time': '2 gün önce',
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Bildirimler'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: ListView.separated(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return _buildNotificationTile(
            context,
            notification['user'],
            notification['content'],
            notification['avatar'],
            notification['time'],
            notification['type'],
          );
        },
        separatorBuilder: (context, index) => Divider(
          height: 1,
          thickness: 1,
          color: Colors.grey[100],
          indent: 70, // Avatar ve ikon genişliği kadar boşluk
        ),
      ),
    );
  }

  // Her bir bildirim satırını oluşturan widget
  Widget _buildNotificationTile(
    BuildContext context,
    String user,
    String content,
    String avatarUrl,
    String time,
    String type,
  ) {
    // Bildirim türüne göre ikonu ve rengi belirle
    final IconData iconData;
    final Color iconColor;

    switch (type) {
      case 'like':
        iconData = Icons.favorite;
        iconColor = Colors.pink;
        break;
      case 'comment':
        iconData = Icons.chat_bubble;
        iconColor = Colors.blue;
        break;
      case 'follow':
        iconData = Icons.person_add;
        iconColor = Colors.green;
        break;
      case 'course_announcement':
        iconData = Icons.school;
        iconColor = Colors.purple;
        break;
      default:
        iconData = Icons.notifications;
        iconColor = Colors.grey;
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      leading: Stack(
        alignment: Alignment.bottomRight,
        children: [
          CircleAvatar(
            radius: 25,
            backgroundImage: NetworkImage(avatarUrl),
          ),
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: iconColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Icon(iconData, size: 14, color: Colors.white),
          ),
        ],
      ),
      title: RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: <TextSpan>[
            TextSpan(
              text: '$user ',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            TextSpan(
              text: content,
              style: const TextStyle(fontSize: 15),
            ),
          ],
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Text(
          time,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
      ),
      onTap: () {
        // Bildirime tıklanınca ilgili sayfaya gitme mantığı eklenebilir
      },
    );
  }
}
