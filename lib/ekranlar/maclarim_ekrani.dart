import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/kullanici_provider.dart';
import '../modeller/mac_model.dart';
import '../modeller/kullanici.dart';
import '../servisler/firestore_servisi.dart';
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

        return Scaffold(
          appBar: AppBar(
            title: Text(isSahaSahibi ? "Gelen Rezervasyonlar" : "Randevularım"),
            centerTitle: true,
          ),
          body: isSahaSahibi
              ? _SahaSahibiRezervasyonlari(kullanici: kullanici)
              : _OyuncuRandevulari(kullaniciId: kullanici.id),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, stack) =>
          Scaffold(body: Center(child: Text("Bir hata oluştu: $e"))),
    );
  }
}

class _OyuncuRandevulari extends StatelessWidget {
  final String kullaniciId;
  const _OyuncuRandevulari({required this.kullaniciId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('maclar')
          .where('olusturanKullaniciId', isEqualTo: kullaniciId)
          .snapshots(),
      builder: (context, snapshot) => _MacListesi(
        snapshot: snapshot,
        bosMetin: "Henüz alınmış bir randevunuz bulunmuyor.",
        siliciKullaniciId: kullaniciId,
      ),
    );
  }
}

// Saha Sahibi görünümü
class _SahaSahibiRezervasyonlari extends StatelessWidget {
  final KullaniciModel kullanici;
  const _SahaSahibiRezervasyonlari({required this.kullanici});

  @override
  Widget build(BuildContext context) {
    // Adım 1: Bu kullanıcıya ait tüm saha ID'lerini çek
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('halisahalar')
          .where('ekleyenKullaniciId', isEqualTo: kullanici.id)
          .snapshots(),
      builder: (context, sahaSnapshot) {
        if (sahaSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final sahaDocs = sahaSnapshot.data?.docs ?? [];
        final sahaIds = sahaDocs.map((d) => d.id).toList();

        if (sahaIds.isEmpty) {
          return const Center(
            child: Text(
              "Henüz sisteme eklediğiniz bir saha bulunmuyor.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        // Adım 2: Bu sahalara gelen randevuları çek
        // Firestore whereIn en fazla 30 eleman destekler
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('maclar')
              .where('halisahaId', whereIn: sahaIds.take(30).toList())
              .snapshots(),
          builder: (context, macSnapshot) => _MacListesi(
            snapshot: macSnapshot,
            bosMetin: "Henüz gelen bir rezervasyon bulunmuyor.",
            siliciKullaniciId: kullanici.id,
          ),
        );
      },
    );
  }
}

// Ortak liste widget'ı (hem Oyuncu hem Saha Sahibi kullanır)
class _MacListesi extends StatelessWidget {
  final AsyncSnapshot<QuerySnapshot> snapshot;
  final String bosMetin;
  final String siliciKullaniciId;

  const _MacListesi({
    required this.snapshot,
    required this.bosMetin,
    required this.siliciKullaniciId,
  });

  @override
  Widget build(BuildContext context) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (snapshot.hasError) {
      return Center(child: Text("Hata oluştu: ${snapshot.error}"));
    }

    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
      return Center(
        child: Text(bosMetin, style: const TextStyle(fontSize: 16)),
      );
    }

    final maclar = snapshot.data!.docs
        .map((doc) => MacModel.fromFirestore(doc))
        .toList();

    // Tarihe göre artan sıralama (Firebase index gerektirmez)
    maclar.sort((a, b) => a.macTarihi.compareTo(b.macTarihi));

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: maclar.length,
      itemBuilder: (context, index) {
        final mac = maclar[index];
        final tarihFormati = DateFormat(
          'dd/MM/yyyy HH:mm',
        ).format(mac.macTarihi);

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
              child: mac.sahaFotoUrl.isNotEmpty
                  ? Image.network(
                      mac.sahaFotoUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _FotoPlaceholder(),
                    )
                  : _FotoPlaceholder(),
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
                    const Icon(
                      Icons.calendar_month,
                      size: 16,
                      color: Colors.green,
                    ),
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
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              tooltip: 'Randevuyu İptal Et',
              onPressed: () => _randevuSilOnay(context, mac),
            ),
          ),
        );
      },
    );
  }

  Future<void> _randevuSilOnay(BuildContext context, MacModel mac) async {
    final onaylandi = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Randevuyu İptal Et'),
        content: Text(
          '"${mac.sahaAdi}" sahasındaki randevunuzu iptal etmek istediğinize emin misiniz?\n\n'
          'Tarih: ${DateFormat('dd/MM/yyyy HH:mm').format(mac.macTarihi)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Vazgeç'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Evet, İptal Et'),
          ),
        ],
      ),
    );

    if (onaylandi == true) {
      try {
        await FirestoreServisi().macSil(
          macId: mac.id,
          siliciKullaniciId: siliciKullaniciId,
          sahaAdi: mac.sahaAdi,
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Randevu başarıyla iptal edildi.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Silme işlemi başarısız: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

class _FotoPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      color: Colors.grey[300],
      child: const Icon(Icons.image_not_supported),
    );
  }
}
