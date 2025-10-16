import 'package:binu_frontend/components/app_bar.dart';
import 'package:flutter/material.dart';
import '../components/bottom_navigation_bar.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'profile_screen.dart';
import 'leaderboard_screen.dart';
import 'messages_screen.dart';
import 'reports_screen.dart';

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
    const ReportsScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(showNotificationIcon: true, showProfileIcon: true,onNotificationPressed:() {
        
      },onProfilePressed: () {
        
      },),
      body: _screens[_currentIndex],
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}