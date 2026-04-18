import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Geliştirici: Necati Uğur
void main() async {
  // Flutter'ın çizim motoruyla Firebase'in haberleşmesi için gerekli komut
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase'i projede ayağa kaldırıyoruz
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const HalisahaUygulamasi());
}

class HalisahaUygulamasi extends StatelessWidget {
  const HalisahaUygulamasi({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Maç Organizasyon',
      theme: ThemeData(
        // Halı saha ruhuna uygun yeşil tema rengi
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text(
            "Firebase Başarıyla Bağlandı!",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}