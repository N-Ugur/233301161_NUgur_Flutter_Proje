import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BildirimServisi {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;

  BildirimServisi(this.scaffoldMessengerKey);

  Future<void> baslat() async {
    try {
      // 1. İzin İste
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          // 2. Token Al
          String? token = await _messaging.getToken();
          if (token != null) {
            // 3. Veritabanına kaydet
            await FirebaseFirestore.instance
                .collection('kullanicilar')
                .doc(user.uid)
                .update({'fcmToken': token});

            // 4. Log at
            await FirebaseFirestore.instance.collection('logs').add({
              'kullaniciId': user.uid,
              'islemAdi': 'Bildirim altyapısı kuruldu',
              'detay': 'FCM Token oluşturuldu ve kaydedildi.',
              'timestamp': FieldValue.serverTimestamp(),
            });
          }
        }

        // 5. Foreground Dinleyici Kur
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          if (message.notification != null) {
            scaffoldMessengerKey.currentState?.showSnackBar(
              SnackBar(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.notification!.title ?? 'Yeni Bildirim',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(message.notification!.body ?? ''),
                  ],
                ),
                backgroundColor: Colors.blueAccent,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 4),
                action: SnackBarAction(
                  label: 'Tamam',
                  textColor: Colors.white,
                  onPressed: () {},
                ),
              ),
            );
          }
        });
      }
    } catch (e) {
      print('Bildirim servisi başlatılırken hata: $e');
    }
  }
}
