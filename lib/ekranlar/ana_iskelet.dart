import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'anasayfa.dart';
import 'maclarim_ekrani.dart';
import 'profil_ekrani.dart';
import 'ayarlar_ekrani.dart';
import 'sohbet_listesi_ekrani.dart';
import '../servisler/bildirim_servisi.dart';
import '../main.dart' show scaffoldMessengerKey;

class AnaIskelet extends StatefulWidget {
  const AnaIskelet({super.key});

  @override
  State<AnaIskelet> createState() => _AnaIskeletState();
}

class _AnaIskeletState extends State<AnaIskelet> {
  int _seciliSayfaIndex = 0;

  final List<Widget> _sayfalar = [
    const Anasayfa(),
    const MaclarimEkrani(),
    const SohbetListesiEkrani(),
    const ProfilEkrani(),
    const AyarlarEkrani(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bildirimIzniKontrolEtVeSor();
    });
  }

  void _bildirimIzniKontrolEtVeSor() async {
    final settings = await FirebaseMessaging.instance.getNotificationSettings();
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // Zaten izin verilmiş, sessizce servisi başlat
      BildirimServisi(scaffoldMessengerKey).baslat();
    } else if (settings.authorizationStatus == AuthorizationStatus.notDetermined) {
      // Daha önce hiç sorulmamış, şık Ön İzin Dialog'unu göster
      if (mounted) {
        _bildirimIzniSorDialog();
      }
    }
  }

  void _bildirimIzniSorDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.notifications_active, color: Colors.green, size: 60),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Bildirimleri Açın',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Yaklaşan maçlarını, rezervasyon onaylarını ve önemli hatırlatmaları kaçırmamak için bildirimlere izin verin.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      BildirimServisi(scaffoldMessengerKey).baslat();
                    },
                    child: const Text('İzin Ver', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Daha Sonra', style: TextStyle(color: Colors.grey, fontSize: 16)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _sayfaDegistir(int index) {
    setState(() {
      _seciliSayfaIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _seciliSayfaIndex,
        children: _sayfalar,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _seciliSayfaIndex,
        onTap: _sayfaDegistir,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Keşfet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_soccer),
            label: 'Maçlarım',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Mesajlar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Ayarlar',
          ),
        ],
      ),
    );
  }
}
