import 'package:binu_frontend/screens/profile_screen.dart'; // Profil sayfasına yönlendirme için
import 'package:flutter/material.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
      backgroundColor: Colors.grey[100],
    
      body: ListView(
        children: [
          _buildYourRankCard(context, currentUser),
          _buildTopScorersSection(context, users),
        ],
      ),
    );
  }

  // "Sıralamanız" kartını oluşturan widget
  Widget _buildYourRankCard(BuildContext context, Map<String, dynamic> user) {
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.grey.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Sıralamanız',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
                Icon(Icons.emoji_events_outlined, color: Colors.blue.shade700),
              ],
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () {
              
              },
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: NetworkImage(user['avatar']),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      user['name'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Text(
                    '#1',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${user['score']} Puan',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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

  Widget _buildTopScorersSection(BuildContext context, List<Map<String, dynamic>> users) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'En Yüksek Puan Alanlar',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return _buildUserRankTile(context, user, index + 1);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUserRankTile(BuildContext context, Map<String, dynamic> user, int rank) {
    // İlk sıradaki kullanıcı için özel stil
    final bool isFirst = rank == 1;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isFirst ? Colors.deepPurple.shade50 : Colors.white,
      elevation: 1,
      child: InkWell(
        onTap: () {
       
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
          child: Row(
            children: [
              Text(
                '#$rank',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isFirst ? Colors.deepPurple.shade900 : Colors.grey.shade600,
                ),
              ),
              const SizedBox(width: 12),
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(user['avatar']),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  user['name'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '${user['score']} Puan',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isFirst ? Colors.deepPurple.shade900 : Colors.black87,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}
