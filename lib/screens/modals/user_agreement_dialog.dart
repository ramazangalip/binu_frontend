import 'package:flutter/material.dart';

class UserAgreementDialog extends StatelessWidget {
  final VoidCallback onAccepted;

  const UserAgreementDialog({super.key, required this.onAccepted});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Kullanıcı Sözleşmesi"),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "2. KULLANICI SÖZLEŞMESİ (BİNU – FINAL)\n\n"
                "2.1. Tanımlar\n"
                "Uygulama: Binu sosyal medya platformu.\n"
                "Kullanıcı: Bingöl Üniversitesi öğrencisi veya personeli.\n\n"
                "2.2. Kayıt ve Hesap Doğrulama\n"
                "- Sadece btmyo@bingol.edu.tr e-posta adresi ile kayıt yapılabilir.\n"
                "- Hesap paylaşımı yasaktır.\n\n"
                "2.3. Kullanıcı Sorumlulukları\n"
                "- Yaptığı tüm paylaşımlardan sorumludur.\n"
                "- KVKK’ya aykırı veri paylaşamaz.\n"
                "- Hakaret, tehdit, küfür ve müstehcen içerik paylaşamaz.\n"
                "- Spam, reklam, bot kullanımı yasaktır.\n\n"
                "2.4. Yasak Fiiller\n"
                "- Sahte hesap açmak\n"
                "- Nefret söylemi kullanmak\n"
                "- Güvenlik ihlali yapmak\n\n"
                "2.8. Yürürlük\n"
                "Uygulama indirildiği anda sözleşme yürürlüğe girer.",
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