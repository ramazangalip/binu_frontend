// lib/screens/notification_screen.dart

import 'package:binu_frontend/models/notification_model.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';


class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    // Sayfa açıldığında bildirimleri çek
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationProvider>(context, listen: false).fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bildirimler'),
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Text('Hata: ${provider.error}'),
            );
          }

          if (provider.notifications.isEmpty) {
            return const Center(child: Text('Henüz bir bildiriminiz yok.'));
          }

          return ListView.builder(
            itemCount: provider.notifications.length,
            itemBuilder: (context, index) {
              final notification = provider.notifications[index];
              return _buildNotificationTile(context, notification);
            },
          );
        },
      ),
    );
  }

  Widget _buildNotificationTile(BuildContext context, AppNotification notification) {
    // Bildirim tipine göre ikon ve renk seçimi
    IconData icon;
    Color color;

    switch (notification.notificationType) {
      case 'LIKE':
        icon = Icons.favorite;
        color = Colors.red.shade400;
        break;
      case 'COMMENT':
        icon = Icons.comment;
        color = Colors.blue.shade400;
        break;
      case 'FOLLOW':
        icon = Icons.person_add;
        color = Colors.green.shade400;
        break;
      default:
        icon = Icons.notifications;
        color = Colors.grey;
    }

    // Gönderi Detayına gitme aksiyonu
    void handleTap() {
      // 1. Bildirimi okundu işaretle (Provider metodu)
      Provider.of<NotificationProvider>(context, listen: false).markAsRead(notification.notificationId);
      
      // 2. İlgili Post/Profile git
      if (notification.post != null) {
        // Örn: Post Detay sayfasına yönlendir
        // Navigator.push(context, MaterialPageRoute(builder: (_) => PostDetailScreen(postId: notification.post!.postid)));
        ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text('Post detayına yönlendiriliyor: ${notification.post!.postid}')),
        );
      } else if (notification.notificationType == 'FOLLOW') {
         // Örn: Profil sayfasına yönlendir
      }
    }

    return Card(
      elevation: 0,
      color: notification.isRead ? Colors.grey.shade50 : Colors.blue.shade50.withOpacity(0.5),
      margin: const EdgeInsets.symmetric(vertical: 1),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(
          notification.message ?? 'Yeni bildirim',
          style: TextStyle(
            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Text(
          notification.createdAt.toLocal().toString().split('.')[0], // Zamanı temizle
          style: TextStyle(fontSize: 12),
        ),
        trailing: notification.isRead 
            ? null 
            : Icon(Icons.circle, size: 8, color: Colors.blue), // Okunmamış işareti
        onTap: handleTap,
      ),
    );
  }
}