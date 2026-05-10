import 'package:flutter/material.dart';
import 'anasayfa.dart';
import 'profil_ekrani.dart';
import 'ayarlar_ekrani.dart';

class AnaIskelet extends StatefulWidget {
  const AnaIskelet({super.key});

  @override
  State<AnaIskelet> createState() => _AnaIskeletState();
}

class _AnaIskeletState extends State<AnaIskelet> {
  int _seciliSayfaIndex = 0;

  final List<Widget> _sayfalar = [
    const Anasayfa(),
    const ProfilEkrani(),
    const AyarlarEkrani(),
  ];

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
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Keşfet',
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
