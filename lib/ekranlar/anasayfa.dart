import 'package:flutter/material.dart';
import '../servisler/auth_servisi.dart';

class Anasayfa extends StatelessWidget {
  const Anasayfa({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Halı Saha - Anasayfa"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthServisi().cikisYap();
            },
          ),
        ],
      ),
      body: const Center(
        child: Text(
          "Keşfet Ekranı Hazırlanıyor",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
