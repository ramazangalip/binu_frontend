import 'package:binu_frontend/components/app_bar.dart';
import 'package:binu_frontend/providers/auth_provider.dart';
import 'package:binu_frontend/screens/login_screen.dart';
import 'package:binu_frontend/screens/notifications_screen.dart';
import 'package:flutter/material.dart';
import '../components/bottom_navigation_bar.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'profile_screen.dart';
import 'leaderboard_screen.dart';
import 'messages_screen.dart';
import 'reports_screen.dart';
import 'package:provider/provider.dart';


class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const SearchScreen(),
    const ProfileScreen(), 
    const LeaderboardScreen(),
    const MessagesScreen(),
    
    

  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  
  void _handleProfileMenuSelection(String value) {
    switch (value) {
      case 'profile':
        if (_currentIndex != 2) {
          setState(() {
            _currentIndex = 2; 
          });
        }
        break;
      case 'logout':
        
        Provider.of<AuthProvider>(context, listen: false).signOut();
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    
    // CRITICAL FIX: profileImageUrl yerine profileimageurl kullanıldı.
    final profileImageUrl = Provider.of<AuthProvider>(context).currentUser?.profileimageurl ?? 'https://i.pravatar.cc/150?img=12';

    return Scaffold(
      appBar: CustomAppBar(
        showNotificationIcon: true,
        showProfileIcon: true,
        onNotificationPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const NotificationScreen()));
        },
        onProfileMenuItemSelected: _handleProfileMenuSelection,
        profileImageUrl: profileImageUrl,
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}