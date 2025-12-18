import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Tema verilerini alalım
    final ThemeData theme = Theme.of(context);
    // Koyu modda daha iyi kontrast için onSurface varyantını kullanabiliriz
    final Color unselectedColor = theme.colorScheme.onSurface.withOpacity(0.6);

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,

      // 1. Arka Plan Rengi: Temanın yüzey rengini kullan (koyu modda koyu, açık modda açık)
      backgroundColor: theme.colorScheme.surface,

      // 2. Seçili Öğe Rengi: Temanın birincil rengini kullan (bu zaten doğruydu)
      selectedItemColor: theme.colorScheme.primary,

      // 3. Seçili Olmayan Öğe Rengi: Sabit Colors.grey yerine,
      // temadan alınan onSurface renginin saydamlığı azaltılmış halini kullan
      unselectedItemColor: unselectedColor,

      // 4. İSTEĞE BAĞLI ETİKET STİLİ KALDIRILDI (HATA NEDENİ)
      // selectedLabelStyle: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
      
      // 5. İsteğe Bağlı: Yükselti (elevation) ayarını 0 yapalım veya tema ile uyumlu hale getirelim
      elevation: 0, 

      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Anasayfa',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Arama',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profil',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.leaderboard),
          label: 'Skor Tablosu',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.message),
          label: 'Mesajlar',
        ),
        
      ],
    );
  }
}