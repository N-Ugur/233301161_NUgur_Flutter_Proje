import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../servisler/sohbet_servisi.dart';
import '../modeller/mesaj_model.dart';
import 'package:intl/intl.dart';

class SohbetEkrani extends StatefulWidget {
  final String aliciId;
  final String aliciAd;

  const SohbetEkrani({
    super.key,
    required this.aliciId,
    required this.aliciAd,
  });

  @override
  State<SohbetEkrani> createState() => _SohbetEkraniState();
}

class _SohbetEkraniState extends State<SohbetEkrani> {
  final TextEditingController _mesajController = TextEditingController();
  final SohbetServisi _sohbetServisi = SohbetServisi();
  final String _mevcutKullaniciId = FirebaseAuth.instance.currentUser!.uid;

  void _mesajGonder() async {
    if (_mesajController.text.trim().isEmpty) return;

    await _sohbetServisi.mesajGonder(
      gonderenId: _mevcutKullaniciId,
      aliciId: widget.aliciId,
      metin: _mesajController.text.trim(),
    );
    _mesajController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.aliciAd),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Mesaj Listesi
          Expanded(
            child: StreamBuilder<List<MesajModel>>(
              stream: _sohbetServisi.mesajlariGetir(_mevcutKullaniciId, widget.aliciId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("Henüz mesaj yok. İlk mesajı sen gönder!"));
                }

                final mesajlar = snapshot.data!;

                return ListView.builder(
                  reverse: true, // Yeni mesajlar altta olsun
                  itemCount: mesajlar.length,
                  itemBuilder: (context, index) {
                    final mesaj = mesajlar[index];
                    bool benimmi = mesaj.gonderenId == _mevcutKullaniciId;

                    return Align(
                      alignment: benimmi ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: benimmi ? Colors.green : Colors.grey[300],
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: Radius.circular(benimmi ? 16 : 0),
                            bottomRight: Radius.circular(benimmi ? 0 : 16),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: benimmi ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            Text(
                              mesaj.metin,
                              style: TextStyle(
                                color: benimmi ? Colors.white : Colors.black87,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('HH:mm').format(mesaj.timestamp),
                              style: TextStyle(
                                color: benimmi ? Colors.white70 : Colors.black54,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Mesaj Yazma Alanı
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, -2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _mesajController,
                    decoration: InputDecoration(
                      hintText: "Mesajınızı yazın...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _mesajGonder(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.green,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _mesajGonder,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
