import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../modeller/kullanici.dart';

final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});
final kullaniciProvider = StreamProvider<KullaniciModel?>((ref) {
  final userAsyncValue = ref.watch(authStateProvider);

  if (userAsyncValue.value == null) {
    return Stream.value(null);
  }

  return FirebaseFirestore.instance
      .collection('kullanicilar')
      .doc(userAsyncValue.value!.uid)
      .snapshots()
      .map((doc) {
        if (doc.exists && doc.data() != null) {
          return KullaniciModel.fromMap(doc.data()!, doc.id);
        }
        return null;
      });
});
