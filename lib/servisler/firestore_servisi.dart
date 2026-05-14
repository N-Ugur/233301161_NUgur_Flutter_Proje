import 'package:cloud_firestore/cloud_firestore.dart';
import '../modeller/halisaha_model.dart';
import '../modeller/mac_model.dart';

class FirestoreServisi {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Uygulama kuralı: Yapılan logs kaydedilecek.
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

  Future<void> halisahaEkle(
    HalisahaModel halisaha,
    String islemYapanKullaniciId,
  ) async {
    try {
      DocumentReference docRef = await _firestore
          .collection('halisahalar')
          .add(halisaha.toMap());

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
      DocumentReference docRef = await _firestore
          .collection('maclar')
          .add(mac.toMap());

      await _islemLogla(
        kullaniciId: mac.olusturanKullaniciId,
        islemAdi: 'Yeni Maç Oluşturuldu',
        detay:
            'Eklenen Maç ID: ${docRef.id}, Saha: ${mac.sahaAdi}, Tarih: ${mac.macTarihi.toString()}',
      );
    } catch (e) {
      print('Maç eklenirken hata: $e');
      rethrow;
    }
  }

  Future<void> macSil({
    required String macId,
    required String siliciKullaniciId,
    required String sahaAdi,
  }) async {
    try {
      await _firestore.collection('maclar').doc(macId).delete();

      await _islemLogla(
        kullaniciId: siliciKullaniciId,
        islemAdi: 'Randevu İptal Edildi',
        detay: 'Silinen Maç ID: $macId, Saha: $sahaAdi',
      );
    } catch (e) {
      print('Maç silinirken hata: $e');
      rethrow;
    }
  }

  /// Sahayı siler. Aynı zamanda o sahaya ait tüm aktif randevuları da toplu siler.
  Future<void> sahaSil({
    required String sahaId,
    required String sahaAdi,
    required String siliciKullaniciId,
  }) async {
    try {
      final maclarSnapshot = await _firestore
          .collection('maclar')
          .where('halisahaId', isEqualTo: sahaId)
          .get();

      final batch = _firestore.batch();

      batch.delete(_firestore.collection('halisahalar').doc(sahaId));

      for (final mac in maclarSnapshot.docs) {
        batch.delete(mac.reference);
      }

      await batch.commit();

      await _islemLogla(
        kullaniciId: siliciKullaniciId,
        islemAdi: 'Halı Saha Silindi',
        detay:
            'Silinen Saha ID: $sahaId, Saha Adı: $sahaAdi, Silinen Randevu Sayısı: ${maclarSnapshot.docs.length}',
      );
    } catch (e) {
      print('Saha silinirken hata: $e');
      rethrow;
    }
  }

  /// Kullanıcı profil bilgilerini günceller ve log atar.
  Future<void> profilGuncelle({
    required String kullaniciId,
    required String ad,
    String? soyisim,
    int? yas,
    String? mevki,
  }) async {
    try {
      final Map<String, dynamic> guncellenecek = {
        'ad': ad,
        if (soyisim != null && soyisim.isNotEmpty) 'soyisim': soyisim,
        if (yas != null) 'yas': yas,
        if (mevki != null) 'mevki': mevki,
      };

      await _firestore
          .collection('kullanicilar')
          .doc(kullaniciId)
          .update(guncellenecek);

      await _islemLogla(
        kullaniciId: kullaniciId,
        islemAdi: 'Kullanıcı profili güncellendi',
        detay: 'Ad: $ad, Mevki: ${mevki ?? '-'}',
      );
    } catch (e) {
      print('Profil güncellenirken hata: $e');
      rethrow;
    }
  }
}
