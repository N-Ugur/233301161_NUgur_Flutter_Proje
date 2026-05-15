import 'package:cloud_firestore/cloud_firestore.dart';

class MesajModel {
  final String id;
  final String gonderenId;
  final String aliciId;
  final String metin;
  final DateTime timestamp;

  MesajModel({
    required this.id,
    required this.gonderenId,
    required this.aliciId,
    required this.metin,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'gonderenId': gonderenId,
      'aliciId': aliciId,
      'metin': metin,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }

  factory MesajModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return MesajModel(
      id: doc.id,
      gonderenId: data['gonderenId'] ?? '',
      aliciId: data['aliciId'] ?? '',
      metin: data['metin'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
