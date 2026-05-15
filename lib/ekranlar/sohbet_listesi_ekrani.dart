import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../servisler/sohbet_servisi.dart';
import 'sohbet_ekrani.dart';

class SohbetListesiEkrani extends StatelessWidget {
  const SohbetListesiEkrani({super.key});

  @override
  Widget build(BuildContext context) {
    final String mevcutKullaniciId = FirebaseAuth.instance.currentUser!.uid;
    final SohbetServisi sohbetServisi = SohbetServisi();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mesajlarım"),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: sohbetServisi.sohbetListesiniGetir(mevcutKullaniciId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text("Henüz bir sohbetiniz yok."),
                ],
              ),
            );
          }

          final docs = snapshot.data!.docs.toList();
          
          // Dart tarafında son mesaj zamanına göre manuel sıralama yapıyoruz
          // (Firestore Index hatasını önlemek için)
          docs.sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;
            final aTime = (aData['sonMesajZamani'] as Timestamp?)?.toDate() ?? DateTime(0);
            final bTime = (bData['sonMesajZamani'] as Timestamp?)?.toDate() ?? DateTime(0);
            return bTime.compareTo(aTime);
          });

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final katilimcilar = List<String>.from(data['katilimcilar']);
              
              // Karşı tarafın ID'sini bul
              final aliciId = katilimcilar.firstWhere((id) => id != mevcutKullaniciId);

              // Karşı tarafın ismini Firestore'dan çek
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('kullanicilar').doc(aliciId).get(),
                builder: (context, userSnapshot) {
                  String aliciAd = "Yükleniyor...";
                  String? fotoUrl;

                  if (userSnapshot.hasData && userSnapshot.data!.exists) {
                    final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                    aliciAd = userData['ad'] ?? "Bilinmeyen Kullanıcı";
                    fotoUrl = userData['fotoUrl'];
                  }

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: (fotoUrl != null && fotoUrl.isNotEmpty)
                          ? NetworkImage(fotoUrl)
                          : null,
                      child: (fotoUrl == null || fotoUrl.isEmpty)
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    title: Text(aliciAd),
                    subtitle: Text(
                      data['sonMesaj'] ?? "",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SohbetEkrani(
                            aliciId: aliciId,
                            aliciAd: aliciAd,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
