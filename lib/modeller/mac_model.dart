import 'package:cloud_firestore/cloud_firestore.dart';

class MacModel {
  final String id;
  final String halisahaId;
  final String sahaSahibiId;

  final String sahaAdi;
  final String sahaIlce;
  final String sahaFotoUrl;

  final String olusturanKullaniciId;
  final DateTime macTarihi;
  final int oyuncuSayisi;
  final DateTime? olusturulmaTarihi;

  MacModel({
    required this.id,
    required this.halisahaId,
    required this.sahaSahibiId,
    required this.sahaAdi,
    required this.sahaIlce,
    required this.sahaFotoUrl,
    required this.olusturanKullaniciId,
    required this.macTarihi,
    required this.oyuncuSayisi,
    this.olusturulmaTarihi,
  });

  factory MacModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return MacModel(
      id: doc.id,
      halisahaId: data['halisahaId'] ?? '',
      sahaSahibiId: data['sahaSahibiId'] ?? '',
      sahaAdi: data['sahaAdi'] ?? '',
      sahaIlce: data['sahaIlce'] ?? '',
      sahaFotoUrl: data['sahaFotoUrl'] ?? '',
      olusturanKullaniciId: data['olusturanKullaniciId'] ?? '',
      macTarihi: (data['macTarihi'] as Timestamp?)?.toDate() ?? DateTime.now(),
      oyuncuSayisi: data['oyuncuSayisi'] ?? 0,
      olusturulmaTarihi: (data['olusturulmaTarihi'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'halisahaId': halisahaId,
      'sahaSahibiId': sahaSahibiId,
      'sahaAdi': sahaAdi,
      'sahaIlce': sahaIlce,
      'sahaFotoUrl': sahaFotoUrl,
      'olusturanKullaniciId': olusturanKullaniciId,
      'macTarihi': Timestamp.fromDate(macTarihi),
      'oyuncuSayisi': oyuncuSayisi,
      'olusturulmaTarihi': FieldValue.serverTimestamp(),
    };
  }
}
