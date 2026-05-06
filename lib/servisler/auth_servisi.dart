import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../modeller/kullanici.dart';

// Geliştirici: Necati Uğur
class AuthServisi {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Yeni Kullanıcı Kayıt Fonksiyonu
  Future<KullaniciModel?> kayitOl(String ad, String email, String sifre, String rol) async {
    try {
      // 1. Firebase Auth servisi ile yeni kullanıcı oluştur
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: sifre,
      );

      User? user = userCredential.user;

      if (user != null) {
        // 2. Kullanıcı nesnesini oluştur ve Firestore 'kullanicilar' koleksiyonuna kaydet
        KullaniciModel yeniKullanici = KullaniciModel(
          id: user.uid,
          ad: ad,
          email: email,
          rol: rol,
        );

        await _firestore
            .collection('kullanicilar')
            .doc(user.uid)
            .set(yeniKullanici.toMap());

        // 3. Proje Kuralı: Kritik işlem için Log kaydı oluştur
        await _firestore.collection('logs').add({
          'kullanici_id': user.uid,
          'islem': 'Yeni kullanıcı sisteme kayıt oldu ($rol)',
          'tarih': FieldValue.serverTimestamp(),
        });

        return yeniKullanici;
      }
    } catch (e) {
      print("Kayıt Hatası: $e");
      return null;
    }
    return null;
  }

  // Kullanıcı Giriş Fonksiyonu
  Future<User?> girisYap(String email, String sifre) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: sifre,
      );
      return userCredential.user;
    } catch (e) {
      print("Giriş Hatası: $e");
      return null;
    }
  }

  // Kullanıcı Çıkış Fonksiyonu
  Future<void> cikisYap() async {
    await _auth.signOut();
  }
}