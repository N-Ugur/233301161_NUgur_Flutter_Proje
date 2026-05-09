import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../servisler/firestore_servisi.dart';
import '../modeller/halisaha_model.dart';

class SahaEkleEkrani extends StatefulWidget {
  const SahaEkleEkrani({super.key});

  @override
  State<SahaEkleEkrani> createState() => _SahaEkleEkraniState();
}

class _SahaEkleEkraniState extends State<SahaEkleEkrani> {
  final _formKey = GlobalKey<FormState>();
  final _adController = TextEditingController();
  final _ilceController = TextEditingController();
  final _fotoUrlController = TextEditingController();
  final _fiyatController = TextEditingController();
  bool _yukleniyor = false;

  @override
  void dispose() {
    _adController.dispose();
    _ilceController.dispose();
    _fotoUrlController.dispose();
    _fiyatController.dispose();
    super.dispose();
  }

  Future<void> _sahaEkle() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _yukleniyor = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("Oturum açık değil!");

      final yeniSaha = HalisahaModel(
        id: '', //FireStore otomatik ID ata
        ad: _adController.text.trim(),
        ilce: _ilceController.text.trim(),
        fotoUrl: _fotoUrlController.text.trim(),
        fiyat: double.tryParse(_fiyatController.text.trim()) ?? 0,
      );

      //halisahaEkle metodu aynı zamanda logs koleksiyonuna da kayıt atıyor
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
      if (mounted) {
        setState(() {
          _yukleniyor = false;
        });
      }
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
              TextFormField(
                controller: _ilceController,
                decoration: const InputDecoration(
                  labelText: "İlçe",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_city),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? "Zorunlu alan" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _fotoUrlController,
                decoration: const InputDecoration(
                  labelText: "Fotoğraf URL'si",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.image),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? "Zorunlu alan" : null,
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
