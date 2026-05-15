import 'package:cloud_firestore/cloud_firestore.dart';

class HalisahaModel {
  final String id;
  final String ad;
  final String ilce;
  final String fotoUrl;
  final List<String>? ekFotograflar;
  final double fiyat;
  final DateTime? olusturulmaTarihi;
  final String? ekleyenKullaniciId;

  HalisahaModel({
    required this.id,
    required this.ad,
    required this.ilce,
    required this.fotoUrl,
    this.ekFotograflar,
    required this.fiyat,
    this.olusturulmaTarihi,
    this.ekleyenKullaniciId,
  });

  factory HalisahaModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return HalisahaModel(
      id: doc.id,
      ad: data['ad'] ?? '',
      ilce: data['ilce'] ?? '',
      fotoUrl: data['fotoUrl'] ?? '',
      ekFotograflar: data['ekFotograflar'] != null
          ? List<String>.from(data['ekFotograflar'])
          : null,
      fiyat: (data['fiyat'] ?? 0).toDouble(),
      olusturulmaTarihi: (data['olusturulmaTarihi'] as Timestamp?)?.toDate(),
      ekleyenKullaniciId: data['ekleyenKullaniciId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ad': ad,
      'ilce': ilce,
      'fotoUrl': fotoUrl,
      'ekFotograflar': ekFotograflar ?? [],
      'fiyat': fiyat,
      'olusturulmaTarihi': FieldValue.serverTimestamp(),
      'ekleyenKullaniciId': ekleyenKullaniciId,
    };
  }
}
