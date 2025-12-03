import 'package:flutter/material.dart';

class KvkkPolicyDialog extends StatelessWidget {
  final VoidCallback onAccepted;

  const KvkkPolicyDialog({super.key, required this.onAccepted});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("KVKK Aydınlatma Metni"),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "1. GİZLİLİK POLİTİKASI \n\n"
                "1.1. Amaç ve Kapsam\n"
                "Binu Sosyal Medya Uygulaması (“Binu”, “Uygulama”), Bingöl Üniversitesi öğrencileri ve personeli için kapalı devre bir sosyal platformdur. "
                "Bu Gizlilik Politikası’nın amacı, 6698 sayılı KVKK kapsamında kişisel verilerin toplanması, işlenmesi, saklanması ve güvenliği hakkında kullanıcıları bilgilendirmektir.\n\n"
                "1.2. Veri Sorumlusunun Kimliği\n"
                "Veri Sorumlusu: Bingöl Üniversitesi Bilişim Teknolojileri Meslek Yüksekokulu\n"
                "E-posta: btmyo@bingol.edu.tr\n\n"
                "1.3. Toplanan Kişisel Veriler\n"
                "- Kimlik Verileri: Ad, soyad, öğrenci numarası.\n"
                "- İletişim Verileri: E-posta adresi, IP adresi.\n"
                "- Profil Verileri: Fotoğraf, biyografi.\n"
                "- Uygulama Kullanım Verileri: Paylaşımlar, mesajlar.\n\n"
                "1.4. İşlenme Amaçları\n"
                "- Kimlik doğrulama ve kayıt işlemleri\n"
                "- İletişim ve etkileşim özelliklerinin sağlanması\n"
                "- Güvenlik tehditlerinin engellenmesi\n\n"
                "4. AÇIK RIZA METNİ (FINAL)\n\n"
                "Açık Rıza Beyanı:\n"
                "“Bingöl Üniversitesi tarafından yönetilen Binu Sosyal Medya Uygulaması kapsamında, KVKK Aydınlatma Metni’ni okudum ve anladım. "
                "Profil bilgilerim, kullanım verilerim ve uygulama etkileşimlerimin; uygulama fonksiyonlarının sağlanması amacıyla işlenmesine açık rıza veriyorum.”",
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