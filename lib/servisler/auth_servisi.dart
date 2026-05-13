import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../modeller/kullanici.dart';

class AuthServisi {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<KullaniciModel?> kayitOl(String ad, String email, String sifre) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: sifre);
      User? user = userCredential.user;

      if (user != null) {
        // Rol belirleme: .env'deki e-posta ile eşleşiyorsa Saha Sahibi, aksi halde Oyuncu
        final sahaSahibiEmail = dotenv.env['SAHA_SAHIBI_EMAIL'] ?? '';
        final rol =
            (email.trim().toLowerCase() == sahaSahibiEmail.trim().toLowerCase())
            ? 'Saha Sahibi'
            : 'Oyuncu';

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

        // Log kaydı oluştur
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

  Future<void> cikisYap() async {
    await _auth.signOut();
  }
}
