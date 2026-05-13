import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../servisler/firestore_servisi.dart';
import '../servisler/storage_servisi.dart';
import '../modeller/halisaha_model.dart';

class SahaEkleEkrani extends StatefulWidget {
  const SahaEkleEkrani({super.key});

  @override
  State<SahaEkleEkrani> createState() => _SahaEkleEkraniState();
}

class _SahaEkleEkraniState extends State<SahaEkleEkrani> {
  final _formKey = GlobalKey<FormState>();
  final _adController = TextEditingController();
  final _fiyatController = TextEditingController();

  static const List<String> _konyaIlceleri = [
    'Ahırlı',
    'Akören',
    'Akşehir',
    'Altınekin',
    'Beyşehir',
    'Bozkır',
    'Cihanbeyli',
    'Çeltik',
    'Çumra',
    'Derbent',
    'Derebucak',
    'Doğanhisar',
    'Emirgazi',
    'Ereğli',
    'Güneysinir',
    'Hadim',
    'Halkapınar',
    'Hüyük',
    'Ilgın',
    'Kadınhanı',
    'Karapınar',
    'Karatay',
    'Kulu',
    'Meram',
    'Sarayönü',
    'Selçuklu',
    'Seydişehir',
    'Taşkent',
    'Tuzlukçu',
    'Yalıhüyük',
    'Yunak',
  ];

  String? _secilenIlce;
  bool _yukleniyor = false;
  bool _fotografYukleniyor = false;
  String? _secilenFotoUrl;

  @override
  void dispose() {
    _adController.dispose();
    _fiyatController.dispose();
    super.dispose();
  }

  Future<void> _fotografSec() async {
    setState(() => _fotografYukleniyor = true);
    try {
      final url = await StorageServisi().fotografSec(
        klasor: 'saha_fotograflari',
      );
      if (url != null) {
        setState(() => _secilenFotoUrl = url);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Fotoğraf başarıyla yüklendi!"),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Fotoğraf yüklenirken hata oluştu: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _fotografYukleniyor = false);
    }
  }

  Future<void> _sahaEkle() async {
    if (!_formKey.currentState!.validate()) return;

    if (_secilenFotoUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lütfen bir saha fotoğrafı seçin!"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _yukleniyor = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("Oturum açık değil!");

      final yeniSaha = HalisahaModel(
        id: '', // FireStore otomatik ID atar
        ad: _adController.text.trim(),
        ilce: _secilenIlce!,
        fotoUrl: _secilenFotoUrl!,
        fiyat: double.tryParse(_fiyatController.text.trim()) ?? 0,
        ekleyenKullaniciId: user.uid,
      );

      await FirestoreServisi().halisahaEkle(yeniSaha, user.uid);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Halı saha başarıyla eklendi!")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Hata oluştu: $e")));
      }
    } finally {
      if (mounted) setState(() => _yukleniyor = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Yeni Saha Ekle"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                "Sahaya Ait Bilgiler",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _adController,
                decoration: const InputDecoration(
                  labelText: "Saha Adı",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.sports_soccer),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? "Zorunlu alan" : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _secilenIlce,
                decoration: const InputDecoration(
                  labelText: "Konya - İlçe",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_city),
                ),
                hint: const Text("İlçe seçiniz"),
                items: _konyaIlceleri.map((ilce) {
                  return DropdownMenuItem(value: ilce, child: Text(ilce));
                }).toList(),
                onChanged: (deger) {
                  setState(() => _secilenIlce = deger);
                },
                validator: (val) =>
                    val == null ? "Lütfen bir ilçe seçin" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _fiyatController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Saatlik Fiyat (₺)",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? "Zorunlu alan" : null,
              ),
              const SizedBox(height: 24),
              const Text(
                "Saha Fotoğrafı",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              if (_secilenFotoUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    _secilenFotoUrl!,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              if (_secilenFotoUrl != null) const SizedBox(height: 12),
              _fotografYukleniyor
                  ? const Center(
                      child: Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 8),
                          Text("Fotoğraf yükleniyor, lütfen bekleyin..."),
                        ],
                      ),
                    )
                  : OutlinedButton.icon(
                      onPressed: _fotografSec,
                      icon: const Icon(Icons.photo_library),
                      label: Text(
                        _secilenFotoUrl == null
                            ? "Galeriden Fotoğraf Seç"
                            : "Fotoğrafı Değiştir",
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Colors.green),
                        foregroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
              const SizedBox(height: 32),
              _yukleniyor
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _sahaEkle,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onPrimary,
                      ),
                      child: const Text(
                        "Sahayı Kaydet",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
