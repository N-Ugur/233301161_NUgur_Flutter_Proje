import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../ekranlar/anasayfa.dart';
import '../ekranlar/giris_ekrani.dart';

// Geliştirici: Necati Uğur

// Firebase authStateChanges akışını dinleyen StreamProvider
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user != null) {
          // Kullanıcı giriş yapmış, Anasayfa'ya yönlendir
          return const Anasayfa();
        }
        // Kullanıcı giriş yapmamış, Giriş ekranına yönlendir
        return const GirisEkrani();
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (e, trace) => Scaffold(
        body: Center(
          child: Text("Bir hata oluştu: $e"),
        ),
      ),
    );
  }
}
