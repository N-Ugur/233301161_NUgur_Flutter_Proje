import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';

class StorageServisi {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  // Log kaydı
  Future<void> _islemLogla({
    required String kullaniciId,
    required String islemAdi,
    String? detay,
  }) async {
    try {
      await _firestore.collection('logs').add({
        'kullaniciId': kullaniciId,
        'islemAdi': islemAdi,
        'detay': detay ?? '',
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Log hataları uygulamayı durdurmamalı
    }
  }

  /// Galeriden fotoğraf seçer ve Storage'a yükler.
  /// [klasor]: Storage içindeki hedef klasör adı ('saha_fotograflari' veya 'profil_fotograflari')
  /// Dönen değer: Download URL veya null (iptal/hata)
  Future<String?> fotografSec({required String klasor}) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 75, // Yükleme boyutunu küçültmek için kalite düşürme
      );

      if (picked == null) return null; // Kullanıcı iptal etti

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Kullanıcı oturumu bulunamadı!');

      final String dosyaAdi =
          '${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference ref = _storage.ref().child('$klasor/$dosyaAdi');

      UploadTask task;

      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        task = ref.putData(bytes);
      } else {
        task = ref.putFile(File(picked.path));
      }

      final TaskSnapshot snapshot = await task;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      // Log at
      final String islem = klasor == 'profil_fotograflari'
          ? 'Profil fotoğrafı güncellendi'
          : 'Saha fotoğrafı yüklendi';

      await _islemLogla(
        kullaniciId: user.uid,
        islemAdi: islem,
        detay: 'Storage yolu: $klasor/$dosyaAdi',
      );

      return downloadUrl;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> profilFotografiniGuncelle({
    required String kullaniciId,
    required String fotoUrl,
  }) async {
    await _firestore.collection('kullanicilar').doc(kullaniciId).update({
      'fotoUrl': fotoUrl,
    });
  }
}
