class KullaniciModel {
  final String id;
  final String ad;
  final String email;
  final String rol;
  final String? fotoUrl;
  final String? soyisim;
  final int? yas;
  final String? mevki;

  KullaniciModel({
    required this.id,
    required this.ad,
    required this.email,
    required this.rol,
    this.fotoUrl,
    this.soyisim,
    this.yas,
    this.mevki,
  });

  // Firebase'den gelen veriyi Map'e çevirme
  factory KullaniciModel.fromMap(Map<String, dynamic> data, String documentId) {
    return KullaniciModel(
      id: documentId,
      ad: data['ad'] ?? '',
      email: data['email'] ?? '',
      rol: data['rol'] ?? 'Oyuncu',
      fotoUrl: data['fotoUrl'],
      soyisim: data['soyisim'],
      yas: data['yas'],
      mevki: data['mevki'],
    );
  }

  //Firebase'e göndermek için Map formatına çevirme
  Map<String, dynamic> toMap() {
    return {
      'ad': ad,
      'email': email,
      'rol': rol,
      if (fotoUrl != null) 'fotoUrl': fotoUrl,
      if (soyisim != null) 'soyisim': soyisim,
      if (yas != null) 'yas': yas,
      if (mevki != null) 'mevki': mevki,
    };
  }
}