// Geliştirici: Necati Uğur
class KullaniciModel {
  final String id;
  final String ad;
  final String email;
  final String rol; // 'Oyuncu' veya 'Saha Sahibi'

  KullaniciModel({
    required this.id,
    required this.ad,
    required this.email,
    required this.rol,
  });

  // Firebase'den gelen veriyi (Map) Dart nesnesine çevirme
  factory KullaniciModel.fromMap(Map<String, dynamic> data, String documentId) {
    return KullaniciModel(
      id: documentId,
      ad: data['ad'] ?? '',
      email: data['email'] ?? '',
      rol: data['rol'] ?? 'Oyuncu',
    );
  }

  // Dart nesnesini Firebase'e göndermek için Map formatına çevirme
  Map<String, dynamic> toMap() {
    return {
      'ad': ad,
      'email': email,
      'rol': rol,
    };
  }
}