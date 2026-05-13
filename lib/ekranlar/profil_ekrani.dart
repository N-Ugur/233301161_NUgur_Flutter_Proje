import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/kullanici_provider.dart';
import '../servisler/auth_servisi.dart';
import '../servisler/storage_servisi.dart';

class ProfilEkrani extends ConsumerStatefulWidget {
  const ProfilEkrani({super.key});

  @override
  ConsumerState<ProfilEkrani> createState() => _ProfilEkraniState();
}

class _ProfilEkraniState extends ConsumerState<ProfilEkrani> {
  bool _fotografYukleniyor = false;

  Future<void> _profilFotografiniDegistir(String kullaniciId) async {
    setState(() => _fotografYukleniyor = true);
    try {
      final url = await StorageServisi().fotografSec(klasor: 'profil_fotograflari');
      if (url != null) {
        await StorageServisi().profilFotografiniGuncelle(
          kullaniciId: kullaniciId,
          fotoUrl: url,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Profil fotoğrafı güncellendi!"),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Hata oluştu: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _fotografYukleniyor = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final kullaniciAsync = ref.watch(kullaniciProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        centerTitle: true,
      ),
      body: kullaniciAsync.when(
        data: (kullanici) {
          if (kullanici == null) {
            return const Center(child: Text("Kullanıcı bilgisi bulunamadı."));
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                // --- Profil Fotoğrafı ---
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
                            radius: 50,
                            backgroundColor: Colors.green.shade100,
                            backgroundImage: (kullanici.fotoUrl != null &&
                                    kullanici.fotoUrl!.isNotEmpty)
                                ? NetworkImage(kullanici.fotoUrl!)
                                : null,
                            child: (kullanici.fotoUrl == null ||
                                    kullanici.fotoUrl!.isEmpty)
                                ? const Icon(Icons.person,
                                    size: 50, color: Colors.green)
                                : null,
                          ),
                    GestureDetector(
                      onTap: _fotografYukleniyor
                          ? null
                          : () => _profilFotografiniDegistir(kullanici.id),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: _fotografYukleniyor
                      ? null
                      : () => _profilFotografiniDegistir(kullanici.id),
                  icon: const Icon(Icons.photo_library, size: 16),
                  label: const Text("Fotoğrafı Değiştir"),
                ),

                const SizedBox(height: 12),
                Text(
                  kullanici.ad,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  kullanici.email,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "Rol: ${kullanici.rol}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
