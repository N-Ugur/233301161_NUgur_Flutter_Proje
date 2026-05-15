import 'package:cloud_firestore/cloud_firestore.dart';
import '../modeller/mesaj_model.dart';

class SohbetServisi {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // İki kullanıcı arasındaki benzersiz sohbet odası ID'sini oluşturur
  String _sohbetOdasiIdAl(String id1, String id2) {
    List<String> ids = [id1, id2];
    ids.sort(); // Alfabetik sıralama ile her zaman aynı ID oluşur
    return ids.join('_');
  }

  // Mesaj Gönder
  Future<void> mesajGonder({
    required String gonderenId,
    required String aliciId,
    required String metin,
  }) async {
    final String sohbetOdasiId = _sohbetOdasiIdAl(gonderenId, aliciId);
    
    final yeniMesaj = {
      'gonderenId': gonderenId,
      'aliciId': aliciId,
      'metin': metin,
      'timestamp': FieldValue.serverTimestamp(),
    };

    // Mesajı alt koleksiyona ekle
    await _firestore
        .collection('sohbet_odalari')
        .doc(sohbetOdasiId)
        .collection('mesajlar')
        .add(yeniMesaj);

    // Sohbet odası bilgisini güncelle (Son mesaj ve katılımcılar)
    await _firestore.collection('sohbet_odalari').doc(sohbetOdasiId).set({
      'katilimcilar': [gonderenId, aliciId],
      'sonMesaj': metin,
      'sonMesajZamani': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Mesajları Dinle (Real-time)
  Stream<List<MesajModel>> mesajlariGetir(String kullanici1, String kullanici2) {
    final String sohbetOdasiId = _sohbetOdasiIdAl(kullanici1, kullanici2);
    
    return _firestore
        .collection('sohbet_odalari')
        .doc(sohbetOdasiId)
        .collection('mesajlar')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => MesajModel.fromFirestore(doc)).toList();
    });
  }

  // Kullanıcının dahil olduğu tüm sohbetleri getir
  Stream<QuerySnapshot> sohbetListesiniGetir(String kullaniciId) {
    return _firestore
        .collection('sohbet_odalari')
        .where('katilimcilar', arrayContains: kullaniciId)
        .snapshots();
  }
}
