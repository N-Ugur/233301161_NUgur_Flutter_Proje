import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/kullanici_provider.dart';
import '../servisler/auth_servisi.dart';
import '../servisler/storage_servisi.dart';
import '../servisler/firestore_servisi.dart';

// Futbol mevkileri
const _mevkiler = [
  'Kaleci',
  'Defans',
  'Stoper',
  'Sol Bek',
  'Sağ Bek',
  'Orta Saha',
  'Defansif Orta Saha',
  'Ofansif Orta Saha',
  'Sol Kanat',
  'Sağ Kanat',
  'Forvet',
  'Santrafor',
];

class ProfilEkrani extends ConsumerStatefulWidget {
  const ProfilEkrani({super.key});

  @override
  ConsumerState<ProfilEkrani> createState() => _ProfilEkraniState();
}

class _ProfilEkraniState extends ConsumerState<ProfilEkrani> {
  final _adController = TextEditingController();
  final _soyisimController = TextEditingController();
  final _yasController = TextEditingController();
  String? _secilenMevki;

  bool _fotografYukleniyor = false;
  bool _profilKaydediliyor = false;
  bool _duzenlemeModu = false;

  @override
  void dispose() {
    _adController.dispose();
    _soyisimController.dispose();
    _yasController.dispose();
    super.dispose();
  }

  void _duzenlemeModunuAc(kullanici) {
    _adController.text = kullanici.ad;
    _soyisimController.text = kullanici.soyisim ?? '';
    _yasController.text = kullanici.yas?.toString() ?? '';
    _secilenMevki = kullanici.mevki;
    setState(() => _duzenlemeModu = true);
  }

  Future<void> _profilGuncelle(String kullaniciId) async {
    setState(() => _profilKaydediliyor = true);
    try {
      final yas = int.tryParse(_yasController.text.trim());
      await FirestoreServisi().profilGuncelle(
        kullaniciId: kullaniciId,
        ad: _adController.text.trim(),
        soyisim: _soyisimController.text.trim(),
        yas: yas,
        mevki: _secilenMevki,
      );
      if (mounted) {
        setState(() => _duzenlemeModu = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil başarıyla güncellendi!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _profilKaydediliyor = false);
    }
  }

  Future<void> _profilFotografiniDegistirDialog(String kullaniciId) async {
    final urlController = TextEditingController();
    final url = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Profil Fotoğrafı Değiştir'),
        content: TextField(
          controller: urlController,
          decoration: const InputDecoration(
            labelText: 'Fotoğraf Linki (https://...)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, null),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, urlController.text.trim()),
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );

    if (url != null && url.isNotEmpty) {
      setState(() => _fotografYukleniyor = true);
      try {
        await StorageServisi().profilFotografiniGuncelle(
          kullaniciId: kullaniciId,
          fotoUrl: url,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profil fotoğrafı güncellendi!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Hata oluştu: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _fotografYukleniyor = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final kullaniciAsync = ref.watch(kullaniciProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        centerTitle: true,
        actions: [
          kullaniciAsync.maybeWhen(
            data: (k) => k != null && !_duzenlemeModu
                ? IconButton(
                    icon: const Icon(Icons.edit),
                    tooltip: 'Profili Düzenle',
                    onPressed: () => _duzenlemeModunuAc(k),
                  )
                : const SizedBox.shrink(),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: kullaniciAsync.when(
        data: (kullanici) {
          if (kullanici == null) {
            return const Center(child: Text('Kullanıcı bilgisi bulunamadı.'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ---- Profil Fotoğrafı ----
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    _fotografYukleniyor
                        ? const SizedBox(
                            width: 100,
                            height: 100,
                            child: CircularProgressIndicator(strokeWidth: 3),
                          )
                        : CircleAvatar(
                            radius: 52,
                            backgroundColor: Colors.green.shade100,
                            backgroundImage: (kullanici.fotoUrl != null &&
                                    kullanici.fotoUrl!.isNotEmpty)
                                ? NetworkImage(kullanici.fotoUrl!)
                                : null,
                            child: (kullanici.fotoUrl == null ||
                                    kullanici.fotoUrl!.isEmpty)
                                ? const Icon(Icons.person,
                                    size: 52, color: Colors.green)
                                : null,
                          ),
                    GestureDetector(
                      onTap: _fotografYukleniyor
                          ? null
                          : () =>
                              _profilFotografiniDegistirDialog(kullanici.id),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: const Icon(Icons.camera_alt,
                            size: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: _fotografYukleniyor
                      ? null
                      : () => _profilFotografiniDegistirDialog(kullanici.id),
                  icon: const Icon(Icons.photo_library, size: 16),
                  label: const Text('Fotoğrafı Değiştir'),
                ),
                const SizedBox(height: 16),

                // ---- Rol Etiketi ----
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Rol: ${kullanici.rol}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ---- Bilgi Alanları ----
                if (!_duzenlemeModu) ...[
                  _BilgiSatiri(
                    ikon: Icons.person,
                    baslik: 'Ad Soyad',
                    deger:
                        '${kullanici.ad}${kullanici.soyisim != null ? ' ${kullanici.soyisim}' : ''}',
                  ),
                  _BilgiSatiri(
                    ikon: Icons.email,
                    baslik: 'E-posta',
                    deger: kullanici.email,
                  ),
                  _BilgiSatiri(
                    ikon: Icons.cake,
                    baslik: 'Yaş',
                    deger: kullanici.yas?.toString() ?? 'Belirtilmemiş',
                  ),
                  _BilgiSatiri(
                    ikon: Icons.sports_soccer,
                    baslik: 'Mevki',
                    deger: kullanici.mevki ?? 'Belirtilmemiş',
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _duzenlemeModunuAc(kullanici),
                      icon: const Icon(Icons.edit, color: Colors.green),
                      label: const Text('Profili Düzenle',
                          style: TextStyle(color: Colors.green)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.green),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ] else ...[
                  // Düzenleme Formu
                  _FormAlani(
                    controller: _adController,
                    label: 'Ad',
                    ikon: Icons.person,
                  ),
                  const SizedBox(height: 12),
                  _FormAlani(
                    controller: _soyisimController,
                    label: 'Soyisim',
                    ikon: Icons.person_outline,
                  ),
                  const SizedBox(height: 12),
                  _FormAlani(
                    controller: _yasController,
                    label: 'Yaş',
                    ikon: Icons.cake,
                    klavyeTipi: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _secilenMevki,
                    decoration: const InputDecoration(
                      labelText: 'Mevki',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.sports_soccer),
                    ),
                    hint: const Text('Mevki seçiniz'),
                    items: _mevkiler.map((m) {
                      return DropdownMenuItem(value: m, child: Text(m));
                    }).toList(),
                    onChanged: (v) => setState(() => _secilenMevki = v),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () =>
                              setState(() => _duzenlemeModu = false),
                          style: OutlinedButton.styleFrom(
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Vazgeç'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _profilKaydediliyor
                              ? null
                              : () => _profilGuncelle(kullanici.id),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _profilKaydediliyor
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2),
                                )
                              : const Text('Kaydet'),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 32),
                // ---- Çıkış Yap ----
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.logout),
                    label: const Text('Çıkış Yap',
                        style: TextStyle(fontSize: 16)),
                    onPressed: () async {
                      await AuthServisi().cikisYap();
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, stack) => Center(child: Text('Hata: $e')),
      ),
    );
  }
}

// Bilgi satırı yardımcı widget'ı
class _BilgiSatiri extends StatelessWidget {
  final IconData ikon;
  final String baslik;
  final String deger;

  const _BilgiSatiri({
    required this.ikon,
    required this.baslik,
    required this.deger,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(ikon, color: Colors.green, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(baslik,
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Text(deger,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}

// Form alanı yardımcı widget'ı
class _FormAlani extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData ikon;
  final TextInputType klavyeTipi;

  const _FormAlani({
    required this.controller,
    required this.label,
    required this.ikon,
    this.klavyeTipi = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: klavyeTipi,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(ikon),
      ),
    );
  }
}
