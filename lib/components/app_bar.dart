import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showNotificationIcon;
  final bool showProfileIcon;
  final VoidCallback? onNotificationPressed;
  final VoidCallback? onProfilePressed;
  final String? profileImageUrl;

  const CustomAppBar({
    super.key,
    this.showNotificationIcon = false,
    this.showProfileIcon = false,
    this.onNotificationPressed,
    this.onProfilePressed,
    this.profileImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    // 1. leading için bir widget değişkeni oluştur
    Widget? leadingIcon;
    if (showNotificationIcon) {
      leadingIcon = IconButton(
        icon: const Icon(Icons.notifications_none_outlined, color: Colors.black87),
        onPressed: onNotificationPressed,
      );
    }

    // 2. actions için bir liste oluştur
    List<Widget> actionIcons = [];
    if (showProfileIcon) {
      actionIcons.add(
        Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: GestureDetector(
            onTap: onProfilePressed,
            child: CircleAvatar(
              radius: 18,
              backgroundImage: profileImageUrl != null 
                  ? NetworkImage(profileImageUrl!) 
                  : null,
              child: profileImageUrl == null 
                  ? const Icon(Icons.person, size: 20) 
                  : null,
              backgroundColor: Colors.grey.shade200,
            ),
          ),
        ),
      );
    }

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      centerTitle: true,
      title: Image.asset(
        'assets/images/logo.png',
        width: 150,
        height: 100,
        fit: BoxFit.contain,
      ),
      // 3. Oluşturulan widget'ları ilgili yerlere ata
      leading: leadingIcon,
      actions: actionIcons.isNotEmpty ? actionIcons : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}