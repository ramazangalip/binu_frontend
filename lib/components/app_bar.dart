import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: Image.asset(
        'assets/images/logo.png',width: 200,height: 100,),
      
    );
  }

  // Bu satır, Scaffold'un AppBar yüksekliğini bilmesini sağlar
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
