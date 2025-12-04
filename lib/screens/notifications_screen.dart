import 'package:binu_frontend/services/notification_service.dart';
import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    // Ekran her açıldığında listeyi güncellemek için setState tetiklenecek
  }

  @override
  Widget build(BuildContext context) {
    final notifications = _notificationService.notifications;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Bildirimler'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: [
           IconButton(
             icon: const Icon(Icons.done_all),
             tooltip: 'Tümünü Okundu İşaretle',
             onPressed: () {
               setState(() {
                 _notificationService.markAllAsRead();
               });
               ScaffoldMessenger.of(context).showSnackBar(
                 const SnackBar(content: Text('Tüm bildirimler okundu olarak işaretlendi.')),
               );
             },
           ),
        ],
      ),
      body: notifications.isEmpty 
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text('Henüz bildirim yok', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
              ],
            ),
          )
        : ListView.separated(
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
                notification['isRead'],
              );
            },
            separatorBuilder: (context, index) => Divider(
              height: 1,
              thickness: 1,
              color: Colors.grey[100],
              indent: 70,
            ),
          ),
    );
  }

  Widget _buildNotificationTile(
    BuildContext context,
    String user,
    String content,
    String avatarUrl,
    String time,
    String type,
    bool isRead,
  ) {
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

    return Container(
      color: isRead ? Colors.white : Colors.blue.shade50.withOpacity(0.4), // Okunmamışlar hafif mavi
      child: ListTile(
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
        trailing: !isRead 
            ? const CircleAvatar(radius: 4, backgroundColor: Colors.red) 
            : null,
        onTap: () {
        
        },
      ),
    );
  }
}