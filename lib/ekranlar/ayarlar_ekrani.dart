import 'package:flutter/material.dart';

class AyarlarEkrani extends StatelessWidget {
  const AyarlarEkrani({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            "Tercihler",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 10),
          SwitchListTile(
            title: const Text("Bildirimler"),
            subtitle: const Text("Uygulama bildirimlerini aç / kapat"),
            value: true,
            onChanged: (bool value) {},
            activeColor: Colors.green,
            secondary: const Icon(Icons.notifications),
          ),
          SwitchListTile(
            title: const Text("Karanlık Mod"),
            subtitle: const Text("Koyu temayı aktifleştir"),
            value: false,
            onChanged: (bool value) {},
            activeColor: Colors.green,
            secondary: const Icon(Icons.dark_mode),
          ),
          const Divider(height: 40),
          const Text(
            "Hakkında",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 10),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text("Uygulama Hakkında"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text("Gizlilik Politikası"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.verified),
            title: const Text("Sürüm"),
            trailing: const Text(
              "1.0.0",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
