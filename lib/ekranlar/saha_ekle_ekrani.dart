import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../servisler/firestore_servisi.dart';
import '../servisler/storage_servisi.dart';
import '../modeller/halisaha_model.dart';

class SahaEkleEkrani extends StatefulWidget {
  final HalisahaModel? duzenlenecekSaha;

  const SahaEkleEkrani({super.key, this.duzenlenecekSaha});

  @override
  State<SahaEkleEkrani> createState() => _SahaEkleEkraniState();
}

class _SahaEkleEkraniState extends State<SahaEkleEkrani> {
  final _formKey = GlobalKey<FormState>();
  final _adController = TextEditingController();
  final _fiyatController = TextEditingController();
  final _fotoUrlController = TextEditingController();
  final List<TextEditingController> _ekstraFotolar = [];

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

  @override
  void initState() {
    super.initState();
    if (widget.duzenlenecekSaha != null) {
      _adController.text = widget.duzenlenecekSaha!.ad;
      _fiyatController.text = widget.duzenlenecekSaha!.fiyat.toString();
      if (_konyaIlceleri.contains(widget.duzenlenecekSaha!.ilce)) {
        _secilenIlce = widget.duzenlenecekSaha!.ilce;
      }
      _fotoUrlController.text = widget.duzenlenecekSaha!.fotoUrl;
      if (widget.duzenlenecekSaha!.ekFotograflar != null) {
        for (var link in widget.duzenlenecekSaha!.ekFotograflar!) {
          if (link.trim().isNotEmpty) {
            _ekstraFotolar.add(TextEditingController(text: link.trim()));
          }
        }
      }
    }
  }

  @override
  void dispose() {
    _adController.dispose();
    _fiyatController.dispose();
    _fotoUrlController.dispose();
    for (var c in _ekstraFotolar) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _sahaEkle() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _yukleniyor = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("Oturum açık değil!");

      final yeniSaha = HalisahaModel(
        id: widget.duzenlenecekSaha?.id ?? '', 
        ad: _adController.text.trim(),
        ilce: _secilenIlce!,
        fotoUrl: _fotoUrlController.text.trim(),
        ekFotograflar: _ekstraFotolar
            .map((c) => c.text.trim())
            .where((url) => url.isNotEmpty)
            .toList(),
        fiyat: double.tryParse(_fiyatController.text.trim()) ?? 0,
        ekleyenKullaniciId: widget.duzenlenecekSaha?.ekleyenKullaniciId ?? user.uid,
      );

      if (widget.duzenlenecekSaha != null) {
        await FirestoreServisi().halisahaGuncelle(yeniSaha, user.uid);
      } else {
        await FirestoreServisi().halisahaEkle(yeniSaha, user.uid);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.duzenlenecekSaha != null
                  ? "Saha başarıyla güncellendi!"
                  : "Halı saha başarıyla eklendi!",
            ),
          ),
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
    final bool isDuzenleme = widget.duzenlenecekSaha != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isDuzenleme ? "Sahayı Düzenle" : "Yeni Saha Ekle"),
        centerTitle: true,
      ),
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
                validator: (val) {
                  if (val == null || val.isEmpty) return "Zorunlu alan";
                  final fiyat = double.tryParse(val);
                  if (fiyat == null || fiyat <= 0) {
                    return "Geçerli, pozitif bir fiyat girin";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _fotoUrlController,
                decoration: const InputDecoration(
                  labelText: "Saha Fotoğraf Linki (URL)",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.link),
                  hintText: "https://ornek.com/resim.jpg",
                ),
                onChanged: (value) => setState(() {}),
                validator: (val) =>
                    val == null || val.isEmpty ? "Lütfen bir fotoğraf linki girin" : null,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Ekstra Fotoğraflar",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _ekstraFotolar.add(TextEditingController());
                      });
                    },
                    icon: const Icon(Icons.add_photo_alternate),
                    label: const Text("Yeni Ekle"),
                  )
                ],
              ),
              const SizedBox(height: 8),
              ..._ekstraFotolar.asMap().entries.map((entry) {
                int index = entry.key;
                TextEditingController cont = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: cont,
                          decoration: InputDecoration(
                            labelText: "Ekstra Fotoğraf ${index + 1} Linki",
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.link),
                            isDense: true,
                          ),
                          onChanged: (v) => setState(() {}),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _ekstraFotolar[index].dispose();
                            _ekstraFotolar.removeAt(index);
                          });
                        },
                      )
                    ],
                  ),
                );
              }),
              const SizedBox(height: 24),
              const Text(
                "Tüm Fotoğraflar (Önizleme)",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              if (_fotoUrlController.text.trim().isNotEmpty ||
                  _ekstraFotolar.any((c) => c.text.trim().isNotEmpty))
                SizedBox(
                  height: 180,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      // Ana fotoğraf
                      if (_fotoUrlController.text.trim().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              _fotoUrlController.text.trim(),
                              width: 250,
                              height: 180,
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, err, stack) => _hataKutusu(),
                            ),
                          ),
                        ),
                      // Ekstra fotoğraflar
                      ..._ekstraFotolar
                          .where((c) => c.text.trim().isNotEmpty)
                          .map(
                            (c) => Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  c.text.trim(),
                                  width: 250,
                                  height: 180,
                                  fit: BoxFit.cover,
                                  errorBuilder: (ctx, err, stack) =>
                                      _hataKutusu(),
                                ),
                              ),
                            ),
                          )
                    ],
                  ),
                )
              else
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: const Center(
                      child: Text("Fotoğraf URL'i girdiğinizde burada görünecek")),
                ),
              const SizedBox(height: 32),
              _yukleniyor
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _sahaEkle,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                      ),
                      child: Text(
                        isDuzenleme ? "Değişiklikleri Kaydet" : "Sahayı Kaydet",
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _hataKutusu() {
    return Container(
      width: 250,
      height: 180,
      color: Colors.grey[300],
      child: const Center(
        child: Text("Geçersiz Resim Linki", style: TextStyle(color: Colors.red)),
      ),
    );
  }
}
