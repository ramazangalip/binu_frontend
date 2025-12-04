import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showNotificationIcon;
  final bool showProfileIcon;
  final VoidCallback? onNotificationPressed;
  final String? profileImageUrl;
  final Function(String)? onProfileMenuItemSelected;

  const CustomAppBar({
    super.key,
    this.showNotificationIcon = false,
    this.showProfileIcon = false,
    this.onNotificationPressed,
    this.profileImageUrl,
    this.onProfileMenuItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Tema renklerini al
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget? leadingIcon;
    if (showNotificationIcon) {
      leadingIcon = IconButton(
        icon: const Icon(Icons.notifications_none_outlined),
        onPressed: onNotificationPressed,
      );
    }

    List<Widget> actionIcons = [];
    if (showProfileIcon) {
      actionIcons.add(
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: PopupMenuButton<String>(
            onSelected: onProfileMenuItemSelected,
            offset: const Offset(0, 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            // Popup menu renkleri temaya göre ayarlanır
            color: colorScheme.surface,
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              _buildPopupMenuItem(
                context,
                value: 'profile',
                icon: Icons.person_outline,
                text: 'Profilim',
              ),
              _buildPopupMenuItem(
                context,
                value: 'logout',
                icon: Icons.logout,
                text: 'Çıkış Yap',
                isDestructive: true,
              ),
            ],
            child: CircleAvatar(
              radius: 18,
              backgroundImage: profileImageUrl != null 
                ? NetworkImage(profileImageUrl!) 
                : null,
              backgroundColor: colorScheme.surfaceContainerHighest,
              foregroundColor: colorScheme.onSurfaceVariant,
              child: profileImageUrl == null 
                ? const Icon(Icons.person, size: 20) 
                : null,
            ),
          ),
        ),
      );
    }

    return AppBar(
      // Tema ayarlarından background color alınır
      backgroundColor: colorScheme.surface,
      // Koyu modda elevation daha belirgin olur
      elevation: isDark ? 2 : 1,
      // Icon renkleri otomatik temaya uyum sağlar
      foregroundColor: colorScheme.onSurface,
      centerTitle: true,
      title: Image.asset(
        'assets/images/logo.png',
        width: 120,
        height: 100,
        fit: BoxFit.contain,
        // Koyu modda logo rengi ayarlanabilir (opsiyonel)
        color: isDark ? Colors.white : null,
        colorBlendMode: isDark ? BlendMode.modulate : null,
      ),
      leading: leadingIcon,
      actions: actionIcons.isNotEmpty ? actionIcons : null,
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem(
    BuildContext context, {
    required String value,
    required IconData icon,
    required String text,
    bool isDestructive = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            color: isDestructive 
              ? colorScheme.error 
              : colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              color: isDestructive 
                ? colorScheme.error 
                : colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}