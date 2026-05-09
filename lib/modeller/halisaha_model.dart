import 'package:cloud_firestore/cloud_firestore.dart';

class HalisahaModel {
  final String id;
  final String ad;
  final String ilce;
  final String fotoUrl;
  final double fiyat;
  final DateTime? olusturulmaTarihi;

  HalisahaModel({
    required this.id,
    required this.ad,
    required this.ilce,
    required this.fotoUrl,
    required this.fiyat,
    this.olusturulmaTarihi,
  });

  factory HalisahaModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return HalisahaModel(
      id: doc.id,
      ad: data['ad'] ?? '',
      ilce: data['ilce'] ?? '',
      fotoUrl: data['fotoUrl'] ?? '',
      fiyat: (data['fiyat'] ?? 0).toDouble(),
      olusturulmaTarihi: (data['olusturulmaTarihi'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ad': ad,
      'ilce': ilce,
      'fotoUrl': fotoUrl,
      'fiyat': fiyat,
      'olusturulmaTarihi': FieldValue.serverTimestamp(),
    };
  }
}
