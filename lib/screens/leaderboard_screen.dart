import 'package:binu_frontend/screens/profile_screen.dart';
import 'package:binu_frontend/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:binu_frontend/services/api_service.dart';
import 'package:binu_frontend/models/post_model.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({Key? key}) : super(key: key);

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final ApiService _apiService = ApiService();
  
  List<User> _leaderboardUsers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLeaderboard();
  }
  
  // -------------------------------------------------------------
  // API ISLEMLERI
  // -------------------------------------------------------------

  Future<void> _fetchLeaderboard() async {
    try {
      // API'den ilk 50 kullaniciyi puana gore cek
      final users = await _apiService.fetchLeaderboard();
      
      // Yalnizca ilk 5 kisiyi gostermek icin siniri ayarlayabiliriz
      // Ancak LeaderboardView zaten ilk 50'yi cektigi icin, burada da ilk 5'i alalim
      final limitedUsers = users.take(5).toList();

      // mounted kontrolu
      if (!mounted) return;

      setState(() {
        _leaderboardUsers = limitedUsers;
        _isLoading = false;
      });
    } catch (e) {
      print("Liderlik tablosu yukleme hatasi: $e");

      // mounted kontrolu
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Liderlik tablosu yuklenemedi: ${e.toString()}')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liderlik Tablosu'),
        elevation: 0.5,
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
          : _leaderboardUsers.isEmpty
              ? Center(
                  child: Text(
                    "Liderlik verisi bulunamadi.",
                    style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                )
              : ListView(
                  children: [
                    // Kendi siralamaniz kaldirildi, sadece Top Scorers listesi kaliyor
                    _buildTopScorersSection(context, _leaderboardUsers, theme, colorScheme),
                  ],
                ),
    );
  }

  // "En Yuksek Puan Alanlar" listesini olusturan widget
  Widget _buildTopScorersSection(BuildContext context, List<User> users, ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'En Yuksek Puan Alanlar (${users.length})',
            style: theme.textTheme.titleLarge?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              // Rank: index + 1
              return _buildUserRankTile(context, user, index + 1, theme, colorScheme);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUserRankTile(BuildContext context, User user, int rank, ThemeData theme, ColorScheme colorScheme) {
    final bool isTopThree = rank <= 3;
    final bool hasAvatar = user.profileimageurl != null && user.profileimageurl!.isNotEmpty;

    // Ilk 3 icin ozel stil
    final Color rankBgColor = isTopThree
      ? colorScheme.primaryContainer
      : theme.cardColor;
      
    final Color rankTextColor = isTopThree
      ? colorScheme.onPrimaryContainer
      : colorScheme.onSurface;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: rankBgColor,
      elevation: 1,
      child: InkWell(
        onTap: () {
          // Profil sayfasina yonlendirme (userid'yi parametre olarak gondermelisiniz)
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
          child: Row(
            children: [
              Text(
                '#$rank',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: rankTextColor,
                ),
              ),
              const SizedBox(width: 12),
              CircleAvatar(
                radius: 20,
                // Avatari modelden cek
                backgroundImage: hasAvatar ? NetworkImage(user.profileimageurl!) : null,
                child: hasAvatar ? null : Icon(Icons.person, size: 25, color: colorScheme.onPrimary),
                backgroundColor: hasAvatar ? colorScheme.surfaceVariant : colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  user.fullname, // Modelden isim
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              Text(
                '${user.score} Puan', // Modelden puan
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: rankTextColor,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}