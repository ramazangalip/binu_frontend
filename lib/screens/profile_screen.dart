import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text(
          'Binu - Profil',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Kapak ve profil kısmı
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage('https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  bottom: -40,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: const CircleAvatar(
                      radius: 46,
                      backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11'),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 50),
            // Kullanıcı adı ve bio
            const Text(
              'Ahmet Efe',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              '@ahmetefe',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Hayat, paylaşınca güzel 🌍 | Flutter geliştirici | Binu topluluğu üyesi 💙',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('Profili Düzenle'),
            ),
            const SizedBox(height: 16),
            // İstatistikler
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  _StatItem(label: 'Gönderi', value: '152'),
                  _StatItem(label: 'Takipçi', value: '1.2K'),
                  _StatItem(label: 'Takip', value: '324'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            // Gönderiler bölümü
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(8),
              itemCount: 9,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
              ),
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage('https://picsum.photos/200?random=$index'),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}
