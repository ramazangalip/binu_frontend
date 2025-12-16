// lib/models/notification_model.dart

import 'post_model.dart'; // Artık tüm modeller burada (User, Role, Post)

// Yardımcı fonksiyon: JSON'dan gelen değeri güvenli bir şekilde int? olarak döndürür.
int? _safeInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is String) return int.tryParse(value);
  return null;
}

class AppNotification {
  final int notificationId;
  final User user; // Bildirimi alan (şu anki kullanıcı)
  final User actorUser; // Aksiyonu yapan (Beğenen, yorum yapan, takip eden)
  final String notificationType; // LIKE, COMMENT, FOLLOW
  final Post? post; // İlgili gönderi (Beğeni ve yorum için)
  final String? message; // Opsiyonel mesaj alanı
  final bool isRead;
  final DateTime createdAt;

  AppNotification({
    required this.notificationId,
    required this.user,
    required this.actorUser,
    required this.notificationType,
    this.post,
    this.message,
    required this.isRead,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    
    // 1. User Alanı (ID veya Map olarak gelebilir)
    User user;
    final userJson = json['user'];
    
    if (userJson is Map<String, dynamic>) {
      // Konsol çıktısına göre, tam User nesnesi gelirse bu kullanılır.
      user = User.fromJson(userJson);
    } else if (userJson is int) {
      // 🚨 KRİTİK: Sadece ID geldiği için fromId ile geçici kullanıcı oluşturulur.
      user = User.fromId(userJson);
    } else {
      throw FormatException("Bildirim JSON'unda 'user' alanı hatalı veya null: $userJson");
    }

    // 2. ActorUser Alanı (Konsol çıktısına göre Map gelmelidir)
    final actorUserJson = json['actor_user'];
    if (!(actorUserJson is Map<String, dynamic>)) {
      throw FormatException("Bildirim JSON'unda 'actor_user' alanı beklenilen Map formatında değil: $actorUserJson");
    }
    
    // 3. Post Alanı (Map, int ID veya null olabilir)
    Post? postData;
    if (json['post'] is Map<String, dynamic>) {
      postData = Post.fromJson(json['post'] as Map<String, dynamic>);
    } else if (json['post'] != null && json['post'] is int) {
      // Post sadece ID olarak gelirse, detay olmadığı için null kabul edilir.
      postData = null;
    }
    
    // 4. Diğer alanlar
    
    return AppNotification(
      notificationId: _safeInt(json['notificationid']) ?? 0,
      user: user,
      actorUser: User.fromJson(actorUserJson),
      notificationType: json['notification_type'] as String,
      post: postData,
      message: json['message'] as String?,
      isRead: json['is_read'] ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}