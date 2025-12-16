// lib/providers/notification_provider.dart


import 'package:binu_frontend/models/notification_model.dart';
import 'package:flutter/material.dart';

import '../services/api_service.dart';

class NotificationProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<AppNotification> _notifications = [];
  bool _isLoading = false;
  String? _error;

  List<AppNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Bildirimleri çekme metodu
  Future<void> fetchNotifications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // ApiService'den List<AppNotification> bekliyoruz
      _notifications = await _apiService.getNotifications();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Okundu işaretleme metodu (İsteğe bağlı)
  Future<void> markAsRead(int notificationId) async {
    // Burada ApiService üzerinden backend'e PATCH isteği gönderme mantığı yer almalıdır.
    // Şimdilik sadece lokal listeyi güncelleyelim.
    try {
      final index = _notifications.indexWhere((n) => n.notificationId == notificationId);
      if (index != -1 && !_notifications[index].isRead) {
        
        // 💡 NOT: Modelde copyWith metodu yoksa bu kısım hata verir.
        // Basitlik için listeyi yeniden oluşturuyoruz. (Idealde copyWith kullanılmalı)
        final updatedList = List<AppNotification>.from(_notifications);
        
        updatedList[index] = AppNotification(
          notificationId: _notifications[index].notificationId,
          user: _notifications[index].user,
          actorUser: _notifications[index].actorUser,
          notificationType: _notifications[index].notificationType,
          post: _notifications[index].post,
          message: _notifications[index].message,
          isRead: true, // DEĞİŞEN KISIM
          createdAt: _notifications[index].createdAt,
        );
        
        _notifications = updatedList;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
}