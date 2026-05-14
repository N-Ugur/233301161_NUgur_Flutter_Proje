import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/tema_provider.dart';

class AyarlarEkrani extends ConsumerWidget {
  const AyarlarEkrani({super.key});

  void _hakkindaDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.green),
            SizedBox(width: 8),
            Text('Uygulama Hakkında'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Maç Organizasyon',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Sürüm: 1.0.0'),
            SizedBox(height: 12),
            Text(
              'Bu uygulama, Konya ilindeki halı saha rezervasyonlarını '
              'kolaylaştırmak ve oyuncuları bir araya getirmek amacıyla '
              'geliştirilmiştir.\n\n'
              'Flutter ve Firebase teknolojileri kullanılarak '
              'gerçek zamanlı rezervasyon yönetimi sağlanmaktadır.',
              style: TextStyle(height: 1.5),
            ),
            SizedBox(height: 12),
            Text(
              'Geliştirici: N. Uğur\nKurumsal Proje — 2026',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  void _gizlilikDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.privacy_tip_outlined, color: Colors.green),
            SizedBox(width: 8),
            Text('Gizlilik Politikası'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Veri Toplama',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                'Uygulamamız yalnızca rezervasyon ve hesap yönetimi için '
                'gerekli olan verileri (ad, e-posta, rezervasyon bilgileri) '
                'toplamaktadır.',
                style: TextStyle(height: 1.5),
              ),
              SizedBox(height: 12),
              Text(
                'Veri Güvenliği',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                'Tüm verileriniz Firebase altyapısında şifreli olarak '
                'saklanmakta olup üçüncü taraflarla paylaşılmamaktadır.',
                style: TextStyle(height: 1.5),
              ),
              SizedBox(height: 12),
              Text(
                'Konum Verisi',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                'Uygulama herhangi bir konum verisi toplamamaktadır.',
                style: TextStyle(height: 1.5),
              ),
              SizedBox(height: 12),
              Text(
                'Son Güncelleme: Mayıs 2026',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Anladım'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final karanlikMod = ref.watch(temaProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // ---- Tercihler ----
          const Text(
            'Tercihler',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 10),
          SwitchListTile(
            title: const Text('Karanlık Mod'),
            subtitle: Text(karanlikMod ? 'Koyu tema aktif' : 'Açık tema aktif'),
            value: karanlikMod,
            onChanged: (_) => ref.read(temaProvider.notifier).toggle(),
            activeColor: Colors.green,
            secondary: Icon(
              karanlikMod ? Icons.dark_mode : Icons.light_mode,
              color: karanlikMod ? Colors.indigo : Colors.orange,
            ),
          ),
          SwitchListTile(
            title: const Text('Bildirimler'),
            subtitle: const Text('Yaklaşan maç hatırlatıcıları'),
            value: true,
            onChanged: (bool value) {
              // İleride gerçek bildirim entegrasyonu yapılabilir
            },
            activeColor: Colors.green,
            secondary: const Icon(Icons.notifications),
          ),
          const Divider(height: 40),

          // ---- Hakkında ----
          const Text(
            'Hakkında',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 10),
          ListTile(
            leading: const Icon(Icons.info_outline, color: Colors.green),
            title: const Text('Uygulama Hakkında'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _hakkindaDialog(context),
          ),
          ListTile(
            leading:
                const Icon(Icons.privacy_tip_outlined, color: Colors.green),
            title: const Text('Gizlilik Politikası'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _gizlilikDialog(context),
          ),
          ListTile(
            leading: const Icon(Icons.verified, color: Colors.green),
            title: const Text('Sürüm'),
            trailing: const Text(
              '1.0.0',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
