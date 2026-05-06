import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/auth_gate.dart';

// Geliştirici: Necati Uğur
void main() async {
  // Flutter'ın çizim motoruyla Firebase'in haberleşmesi için gerekli komut
  WidgetsFlutterBinding.ensureInitialized();
  
  // Çevre değişkenlerini (.env) yüklüyoruz
  await dotenv.load(fileName: ".env");

  // Firebase'i projede ayağa kaldırıyoruz
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Uygulamayı ProviderScope ile sararak Riverpod'u etkinleştiriyoruz
  runApp(const ProviderScope(child: HalisahaUygulamasi()));
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
      home: const AuthGate(),
    );
  }
}