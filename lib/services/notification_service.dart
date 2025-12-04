import 'package:flutter/material.dart';

class NotificationService {
  // Singleton yapısı (Tüm uygulama aynı listeyi kullansın diye)
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // Bildirim Listesi
  final List<Map<String, dynamic>> _notifications = [
    // Başlangıç için örnek veriler
    {
      'id': 1,
      'type': 'like',
      'user': 'Ayşe Yılmaz',
      'avatar': 'https://i.pravatar.cc/150?img=2',
      'content': 'bir gönderini beğendi.',
      'time': '2 dakika önce',
      'isRead': false,
    },
    {
      'id': 2,
      'type': 'comment',
      'user': 'Mehmet Demir',
      'avatar': 'https://i.pravatar.cc/150?img=3',
      'content': 'hakkındaki "Proje Takvimi" gönderine yorum yaptı.',
      'time': '15 dakika önce',
      'isRead': true,
    },
  ];

  // Bildirimleri Getir
  List<Map<String, dynamic>> get notifications => _notifications;

  // Okunmamış Bildirim Sayısı
  int get unreadCount => _notifications.where((n) => n['isRead'] == false).length;

  // Yeni Bildirim Ekle
  void addNotification({
    required String type, // 'like', 'comment', 'follow'
    required String user,
    required String avatar,
    required String content,
  }) {
    final newNotification = {
      'id': DateTime.now().millisecondsSinceEpoch, // Benzersiz ID
      'type': type,
      'user': user,
      'avatar': avatar,
      'content': content,
      'time': 'Şimdi',
      'isRead': false,
    };
    
    // En başa ekle (En yeni en üstte)
    _notifications.insert(0, newNotification);
  }

  // Bildirimleri Okundu İşaretle
  void markAllAsRead() {
    for (var notification in _notifications) {
      notification['isRead'] = true;
    }
  }
}