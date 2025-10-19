import 'package:flutter/material.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> users = [
      {'name': 'Ahmet', 'score': 980, 'avatar': 'https://i.pravatar.cc/150?img=1'},
      {'name': 'Elif', 'score': 920, 'avatar': 'https://i.pravatar.cc/150?img=2'},
      {'name': 'Mehmet', 'score': 850, 'avatar': 'https://i.pravatar.cc/150?img=3'},
      {'name': 'Zeynep', 'score': 790, 'avatar': 'https://i.pravatar.cc/150?img=4'},
      {'name': 'Ali', 'score': 720, 'avatar': 'https://i.pravatar.cc/150?img=5'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Binu - Skor Tablosu',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        color: Colors.grey[100],
        child: ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(user['avatar']),
                  radius: 28,
                ),
                title: Text(
                  '${index + 1}. ${user['name']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                subtitle: Text(
                  'Puan: ${user['score']}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                trailing: Icon(
                  index == 0
                      ? Icons.emoji_events_rounded
                      : Icons.star_border_rounded,
                  color: index == 0
                      ? Colors.amber
                      : Colors.blueAccent,
                  size: 30,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
