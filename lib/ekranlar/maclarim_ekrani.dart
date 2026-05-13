import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/kullanici_provider.dart';
import '../modeller/mac_model.dart';
import 'package:intl/intl.dart';

class MaclarimEkrani extends ConsumerWidget {
  const MaclarimEkrani({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kullaniciAsync = ref.watch(kullaniciProvider);

    return kullaniciAsync.when(
      data: (kullanici) {
        if (kullanici == null) {
          return const Scaffold(
            body: Center(child: Text("Lütfen giriş yapın.")),
          );
        }

        final bool isSahaSahibi = kullanici.rol == 'Saha Sahibi';
        final String baslik = isSahaSahibi ? "Gelen Rezervasyonlar" : "Randevularım";

        final query = isSahaSahibi
            ? FirebaseFirestore.instance.collection('maclar').where('sahaSahibiId', isEqualTo: kullanici.id)
            : FirebaseFirestore.instance.collection('maclar').where('olusturanKullaniciId', isEqualTo: kullanici.id);

        return Scaffold(
          appBar: AppBar(
            title: Text(baslik),
            centerTitle: true,
          ),
          body: StreamBuilder<QuerySnapshot>(
            stream: query.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Hata oluştu: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                isSahaSahibi
                    ? "Henüz gelen bir rezervasyon bulunmuyor."
                    : "Henüz alınmış bir randevunuz bulunmuyor.",
                style: const TextStyle(fontSize: 16),
              ),
            );
          }

          final maclar = snapshot.data!.docs
              .map((doc) => MacModel.fromFirestore(doc))
              .toList();

          // Firebase index zorunluluğundan kaçınmak için sıralamayı uygulamada yapıyoruz
          maclar.sort((a, b) => a.macTarihi.compareTo(b.macTarihi));

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: maclar.length,
            itemBuilder: (context, index) {
              final mac = maclar[index];
              final tarihFormati = DateFormat('dd/MM/yyyy HH:mm').format(mac.macTarihi);

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      mac.sahaFotoUrl.isNotEmpty
                          ? mac.sahaFotoUrl
                          : 'https://via.placeholder.com/150?text=Saha',
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported),
                      ),
                    ),
                  ),
                  title: Text(
                    mac.sahaAdi,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(mac.sahaIlce),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.calendar_month, size: 16, color: Colors.green),
                          const SizedBox(width: 4),
                          Text(
                            tarihFormati,
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
    },
    loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
    error: (e, stack) => Scaffold(body: Center(child: Text("Bir hata oluştu: $e"))),
    );
  }
}
