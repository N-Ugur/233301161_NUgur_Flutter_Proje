import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/auth_gate.dart';
import 'providers/tema_provider.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

void main() async {
  // Flutter'ın çizim motoruyla Firebase'in haberleşmesi için gerekli komut
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const ProviderScope(child: HalisahaUygulamasi()));
}

class HalisahaUygulamasi extends ConsumerWidget {
  const HalisahaUygulamasi({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final karanlikMod = ref.watch(temaProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Maç Organizasyon',
      scaffoldMessengerKey: scaffoldMessengerKey,
      themeMode: karanlikMod ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}
