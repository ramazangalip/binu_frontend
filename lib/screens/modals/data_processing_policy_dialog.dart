import 'package:flutter/material.dart';

class DataProcessingPolicyDialog extends StatelessWidget {
  final VoidCallback onAccepted;

  const DataProcessingPolicyDialog({super.key, required this.onAccepted});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Veri İşleme Politikası"),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
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
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Kapat"),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple.shade900,
            foregroundColor: Colors.white,
          ),
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