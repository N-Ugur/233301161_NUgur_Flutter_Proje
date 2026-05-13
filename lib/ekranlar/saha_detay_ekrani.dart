import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/kullanici_provider.dart';
import '../modeller/halisaha_model.dart';
import '../modeller/mac_model.dart';
import '../servisler/firestore_servisi.dart';

class SahaDetayEkrani extends ConsumerStatefulWidget {
  final HalisahaModel saha;

  const SahaDetayEkrani({super.key, required this.saha});

  @override
  ConsumerState<SahaDetayEkrani> createState() => _SahaDetayEkraniState();
}

class _SahaDetayEkraniState extends ConsumerState<SahaDetayEkrani> {
  DateTime? _secilenTarihSaat;
  bool _islemSuruyor = false;

  Future<void> _randevuAl() async {
    final secilenTarih = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (secilenTarih == null) return;

    if (!mounted) return;
    final secilenSaat = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (secilenSaat == null) return;

    final randevuTarihi = DateTime(
      secilenTarih.year,
      secilenTarih.month,
      secilenTarih.day,
      secilenSaat.hour,
      secilenSaat.minute,
    );

    setState(() {
      _secilenTarihSaat = randevuTarihi;
      _islemSuruyor = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("Kullanıcı girişi bulunamadı!");

      // MacModel oluştur (Denormalizasyon kurallarına uygun olarak saha bilgilerini içerir)
      final yeniMac = MacModel(
        id: '', // Firestore kendi oluşturacak
        halisahaId: widget.saha.id,
        sahaSahibiId: widget.saha.ekleyenKullaniciId ?? '',
        sahaAdi: widget.saha.ad,
        sahaIlce: widget.saha.ilce,
        sahaFotoUrl: widget.saha.fotoUrl,
        olusturanKullaniciId: user.uid,
        macTarihi: randevuTarihi,
        oyuncuSayisi: 14,
      );

      await FirestoreServisi().macEkle(yeniMac);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Randevu başarıyla alındı!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Randevu alınırken hata oluştu: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _islemSuruyor = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final kullaniciAsync = ref.watch(kullaniciProvider);

    return Scaffold(
      appBar: AppBar(title: Text(widget.saha.ad), centerTitle: true),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Saha Fotoğrafı
            Hero(
              tag: widget.saha.id,
              child: Image.network(
                widget.saha.fotoUrl.isNotEmpty
                    ? widget.saha.fotoUrl
                    : 'https://via.placeholder.com/600x400?text=Saha+Gorseli',
                height: 250,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 250,
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.image_not_supported,
                      size: 80,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.saha.ad,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.saha.ilce,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Saatlik Ücret:",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "₺${widget.saha.fiyat}",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Saha Hakkında",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Bu halı saha, yüksek kaliteli suni çim zemin ve modern aydınlatma sistemlerine sahiptir. Maç sonrasında duş ve soyunma odalarından ücretsiz faydalanabilirsiniz.",
                    style: TextStyle(fontSize: 14, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: kullaniciAsync.when(
            data: (kullanici) {
              if (kullanici != null && kullanici.rol == 'Saha Sahibi') {
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green, width: 2),
                  ),
                  child: const Text(
                    "Bu saha yönetiminize aittir",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                );
              }

              // Normal Oyuncu Görünümü
              return ElevatedButton(
                onPressed: _islemSuruyor ? null : _randevuAl,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _islemSuruyor
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        "Tarih / Saat Seç ve Randevu Al",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}
