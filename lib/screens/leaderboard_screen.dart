import 'package:binu_frontend/screens/profile_screen.dart'; // Profil sayfasına yönlendirme için
import 'package:flutter/material.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    
    final List<Map<String, dynamic>> users = [
      {'name': 'Ayşe Yılmaz', 'score': 1250, 'avatar': 'https://i.pravatar.cc/150?img=2'},
      {'name': 'Mehmet Demir', 'score': 1200, 'avatar': 'https://i.pravatar.cc/150?img=3'},
      {'name': 'Elif Kaya', 'score': 1180, 'avatar': 'https://i.pravatar.cc/150?img=4'},
      {'name': 'Can Aktaş', 'score': 1050, 'avatar': 'https://i.pravatar.cc/150?img=5'},
      {'name': 'Zeynep Çelik', 'score': 980, 'avatar': 'https://i.pravatar.cc/150?img=1'},
      {'name': 'Deniz Yıldız', 'score': 910, 'avatar': 'https://i.pravatar.cc/150?img=7'},
      {'name': 'Murat Sönmez', 'score': 850, 'avatar': 'https://i.pravatar.cc/150?img=8'},
    ];

    // Mevcut kullanıcının verisi (simülasyon)
    final currentUser = users[0]; 

    return Scaffold(
      // Arka plan rengini temadan al
      backgroundColor: theme.scaffoldBackgroundColor,
      
      body: ListView(
        children: [
          _buildYourRankCard(context, currentUser, theme, colorScheme),
          _buildTopScorersSection(context, users, theme, colorScheme),
        ],
      ),
    );
  }

  // "Sıralamanız" kartını oluşturan widget
  Widget _buildYourRankCard(BuildContext context, Map<String, dynamic> user, ThemeData theme, ColorScheme colorScheme) {
    return Card(
      margin: const EdgeInsets.all(16),
      // Kart rengi CardTheme'dan otomatik gelir.
      // Gölge rengi CardTheme'dan otomatik gelir.
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sıralamanız',
                  style: theme.textTheme.titleMedium?.copyWith(
                    // Metin rengini temadan al
                    color: colorScheme.onSurfaceVariant, 
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                // İkon rengini temadan al
                Icon(Icons.emoji_events_outlined, color: colorScheme.primary),
              ],
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () {
                // Profil sayfasına yönlendirme (örnek)
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
              },
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: NetworkImage(user['avatar']),
                    backgroundColor: colorScheme.surfaceVariant,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      user['name'],
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        // Metin rengini temadan al
                        color: colorScheme.onSurface, 
                      ),
                    ),
                  ),
                  Text(
                    '#1',
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      // Sıra numarasının rengini temadan al
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${user['score']} Puan',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      // Puan metin rengini temadan al
                      color: colorScheme.onSurface, 
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopScorersSection(BuildContext context, List<Map<String, dynamic>> users, ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'En Yüksek Puan Alanlar',
            style: theme.textTheme.titleLarge?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              // Başlık metin rengini temadan al
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
              return _buildUserRankTile(context, user, index + 1, theme, colorScheme);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUserRankTile(BuildContext context, Map<String, dynamic> user, int rank, ThemeData theme, ColorScheme colorScheme) {
    // İlk sıradaki kullanıcı için özel stil
    final bool isFirst = rank == 1;

    // isFirst için renkleri dinamikleştir
    final Color rankBgColor = isFirst 
      ? colorScheme.primaryContainer 
      : theme.cardColor; // Diğerleri için tema kart rengi
      
    final Color rankTextColor = isFirst 
      ? colorScheme.onPrimaryContainer 
      : colorScheme.onSurface; // Diğerleri için normal metin rengi

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      // Kart rengini dinamik olarak ayarla
      color: rankBgColor, 
      elevation: 1,
      child: InkWell(
        onTap: () {
          // Profil sayfasına yönlendirme (örnek)
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
                  // Sıra numarasının rengini dinamik olarak ayarla
                  color: rankTextColor, 
                ),
              ),
              const SizedBox(width: 12),
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(user['avatar']),
                backgroundColor: colorScheme.surfaceVariant,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  user['name'],
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    // Kullanıcı adı rengini temadan al
                    color: colorScheme.onSurface, 
                  ),
                ),
              ),
              Text(
                '${user['score']} Puan',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  // Puan metin rengini dinamik olarak ayarla
                  color: rankTextColor,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios, 
                size: 14, 
                // İkon rengini temadan al
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}