import 'package:flutter/material.dart';

class DataProcessingPolicyDialog extends StatelessWidget {
  final VoidCallback onAccepted;

  const DataProcessingPolicyDialog({super.key, required this.onAccepted});

  @override
  Widget build(BuildContext context) {
    // Tema verilerini alalım
    final ThemeData theme = Theme.of(context);

    return AlertDialog(
      // 1. AlertDialog'un şekli ve arka planı tema tarafından otomatik yönetilir.
      title: Text(
        "Veri İşleme Politikası",
        // Başlık metnini temadan alalım.
        style: theme.textTheme.headlineMedium, 
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "3. VERİ İŞLEME POLİTİKASI (FINAL)\n\n"
                "3.1. Amaç\n"
                "Bu politika, kişisel verilerin KVKK’ya uygun şekilde işlenme süreçlerini tanımlar.\n\n"
                "3.2. Temel İlkeler\n"
                "- Hukuka uygunluk\n"
                "- Doğruluk ve güncellik\n"
                "- Belirli, açık ve meşru amaçlar\n\n"
                "3.3. İşlenen Veri Kategorileri\n"
                "Kimlik, iletişim, profil, paylaşımlar, loglar.\n\n"
                "3.6. Saklama ve İmha\n"
                "Veriler, mezuniyet/ayrılıktan sonra 2 yıl saklanır ve sonrasında imha edilir.\n\n"
                "3.7. Teknik Tedbirler\n"
                "Şifreleme, güvenlik duvarı, loglama.",
                style: theme.textTheme.bodyMedium?.copyWith(
                  // Yalnızca boyutunu sabit tuttuk, rengini temaya bıraktık.
                  fontSize: 14, 
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        // 2. TextButton: Rengi tema tarafından (genellikle primaryColor) belirlenir.
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Kapat"),
        ),
        
        // 3. Kabul Et Butonu: Stilini AppTheme'da tanımladığımız ElevatedButtonTheme'dan alalım.
        // Artık sabit Colors.deepPurple.shade900 ve Colors.white kullanmaya gerek yok!
        ElevatedButton(
          // ElevatedButton'a herhangi bir style vermemek, global temayı kullanmasını sağlar.
          onPressed: () {
            onAccepted();
            Navigator.of(context).pop();
          },
          child: const Text("Okudum, Kabul Ediyorum"),
        ),
      ],
    );
  }
}