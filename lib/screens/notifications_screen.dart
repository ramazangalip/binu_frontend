import 'package:binu_frontend/services/notification_service.dart';
import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // Singleton yapısından NotificationService örneğini al
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    // Ekran her açıldığında listeyi güncellemek için setState tetiklenecek
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final notifications = _notificationService.notifications;

    return Scaffold(
      // Arka planı temadan al
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Bildirimler'),
        centerTitle: true,
        // AppBar stili AppTheme'dan otomatik gelir
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Tümünü Okundu İşaretle',
            // İkon rengi temadan gelir
            onPressed: () {
              setState(() {
                // Service içindeki metodu çağır
                _notificationService.markAllAsRead();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  // Snackbar arka plan rengi temadan (surface) alınır
                  backgroundColor: colorScheme.surface,
                  content: Text(
                    'Tüm bildirimler okundu olarak işaretlendi.',
                    // Snackbar metin rengi temadan (onSurface) alınır
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                ),
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
                Icon(
                  Icons.notifications_off_outlined, 
                  size: 64, 
                  // İkon rengini temadan al
                  color: colorScheme.onSurface.withOpacity(0.3)
                ),
                const SizedBox(height: 16),
                Text(
                  'Henüz bildirim yok', 
                  style: theme.textTheme.bodyLarge?.copyWith(
                    // Metin rengini temadan al
                    color: colorScheme.onSurfaceVariant, 
                    fontSize: 16,
                  )
                ),
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
                  // NOT: id yerine index'i gönderiyoruz. Gerçek kullanımda id gönderilmelidir.
                  notification['id'], 
                  theme,
                  colorScheme,
                );
              },
              separatorBuilder: (context, index) => Divider(
                height: 1,
                thickness: 1,
                // Ayırıcı çizgi rengini temadan al
                color: colorScheme.outlineVariant, 
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
    int notificationId, // Bildirim ID'sini alıyoruz
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final IconData iconData;
    final Color iconColor; 

    switch (type) {
      case 'like':
        iconData = Icons.favorite;
        iconColor = Colors.pink.shade400; 
        break;
      case 'comment':
        iconData = Icons.chat_bubble;
        iconColor = colorScheme.secondary; 
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
        iconColor = colorScheme.onSurfaceVariant; 
    }

    // Okunmamış arka plan rengi
    final Color tileColor = isRead 
        ? theme.scaffoldBackgroundColor 
        : colorScheme.primaryContainer.withOpacity(0.15); 

    return Container(
      // Arka plan rengini dinamik olarak ayarla
      color: tileColor, 
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        leading: Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 25,
              backgroundImage: NetworkImage(avatarUrl),
              // Avatar placeholder rengini temadan al
              backgroundColor: colorScheme.surfaceVariant, 
            ),
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: iconColor,
                shape: BoxShape.circle,
                // Çerçeve rengini temadan al
                border: Border.all(color: colorScheme.background, width: 2), 
              ),
              // İkon rengi: Beyaz tutuldu çünkü arka plan renkleri zaten kontrastlı
              child: Icon(iconData, size: 14, color: Colors.white), 
            ),
          ],
        ),
        title: RichText(
          text: TextSpan(
            // Varsayılan metin stili temadan gelecek
            style: DefaultTextStyle.of(context).style.copyWith(color: colorScheme.onSurface), 
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
            // Zaman metni rengini temadan al
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13), 
          ),
        ),
        trailing: !isRead 
            ? CircleAvatar(
              radius: 4, 
              // Okunmamış işareti rengini temadan (error/danger) al
              backgroundColor: colorScheme.error, 
            ) 
            : null,
        onTap: () {
          // Bu metodunuzda `markAsRead(int id)` metodu olmadığı için,
          // tıklamadan sonra sadece ekranı yeniden çizerek görsel geribildirim sağlıyoruz.
          // Gerçekte burada _notificationService.markAsRead(notificationId) çağrılmalıdır.
          setState(() {
            // Not: Bu, sadece bir simülasyon olduğu için tam olarak
            // okunma durumunu güncellemez. Ancak setState ile görsel geribildirim verir.
            // Gerçek projede servisinizi güncellemeniz gerekir.
          });
        },
      ),
    );
  }
}