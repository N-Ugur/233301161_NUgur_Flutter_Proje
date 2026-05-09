import 'package:cloud_firestore/cloud_firestore.dart';
import '../modeller/halisaha_model.dart';
import '../modeller/mac_model.dart';

class FirestoreServisi {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Uygulama kuralı: Yapılan her kritik işlem Firestore 'logs' koleksiyonuna kaydedilecek.
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
      print('Log kaydedilirken hata oluştu: $e');
    }
  }
  Future<void> halisahaEkle(HalisahaModel halisaha, String islemYapanKullaniciId) async {
    try {
      DocumentReference docRef = await _firestore.collection('halisahalar').add(halisaha.toMap());

      await _islemLogla(
        kullaniciId: islemYapanKullaniciId,
        islemAdi: 'Halı Saha Eklendi',
        detay: 'Eklenen Saha ID: ${docRef.id}, Saha Adı: ${halisaha.ad}',
      );
    } catch (e) {
      print('Halı saha eklenirken hata: $e');
      rethrow;
    }
  }

  Future<void> macEkle(MacModel mac) async {
    try {
      DocumentReference docRef = await _firestore.collection('maclar').add(mac.toMap());
      
      await _islemLogla(
        kullaniciId: mac.olusturanKullaniciId,
        islemAdi: 'Yeni Maç Oluşturuldu',
        detay: 'Eklenen Maç ID: ${docRef.id}, Saha: ${mac.sahaAdi}, Tarih: ${mac.macTarihi.toString()}',
      );
    } catch (e) {
      print('Maç eklenirken hata: $e');
      rethrow;
    }
  }
}
