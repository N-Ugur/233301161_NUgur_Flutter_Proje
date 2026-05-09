import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../servisler/auth_servisi.dart';
import '../modeller/halisaha_model.dart';
import '../providers/kullanici_provider.dart';
import 'saha_ekle_ekrani.dart';

class Anasayfa extends ConsumerWidget {
  const Anasayfa({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kullaniciAsync = ref.watch(kullaniciProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Keşfet"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthServisi().cikisYap();
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('halisahalar')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Bir hata oluştu: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "Henüz listelenecek saha bulunmuyor.",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final sahalar = snapshot.data!.docs
              .map((doc) => HalisahaModel.fromFirestore(doc))
              .toList();

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: sahalar.length,
            itemBuilder: (context, index) {
              final saha = sahalar[index];
              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Saha Resmi (Eğer URL boşsa veya geçersizse placeholder gösterir)
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: Image.network(
                        saha.fotoUrl.isNotEmpty
                            ? saha.fotoUrl
                            : 'https://via.placeholder.com/400x200?text=Saha+Gorseli',
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 180,
                            width: double.infinity,
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.image_not_supported,
                              size: 50,
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
                            saha.ad,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  saha.ilce,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "₺${saha.fiyat} / saat",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      //Saha Sahibi için Ekleme butonu göster
      floatingActionButton: kullaniciAsync.when(
        data: (kullanici) {
          if (kullanici != null && kullanici.rol == 'Saha Sahibi') {
            return FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SahaEkleEkrani(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text("Saha Ekle"),
            );
          }
          return null;
        },
        loading: () => null,
        error: (_, __) => null,
      ),
    );
  }
}
