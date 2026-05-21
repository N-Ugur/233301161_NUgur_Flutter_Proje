import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AyarlarState {
  final bool bildirimlerAcik;

  AyarlarState({required this.bildirimlerAcik});

  AyarlarState copyWith({bool? bildirimlerAcik}) {
    return AyarlarState(
      bildirimlerAcik: bildirimlerAcik ?? this.bildirimlerAcik,
    );
  }
}

// Riverpod 3.0+ için Notifier yapısı
class AyarlarNotifier extends Notifier<AyarlarState> {
  @override
  AyarlarState build() {
    _yukle();
    return AyarlarState(bildirimlerAcik: true);
  }

  Future<void> _yukle() async {
    final prefs = await SharedPreferences.getInstance();
    final acik = prefs.getBool('bildirimler_acik') ?? true;
    state = state.copyWith(bildirimlerAcik: acik);
  }

  Future<void> bildirimleriDegistir(bool deger) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('bildirimler_acik', deger);
    
    if (deger) {
      await FirebaseMessaging.instance.subscribeToTopic('maclar');
    } else {
      await FirebaseMessaging.instance.unsubscribeFromTopic('maclar');
    }
    
    state = state.copyWith(bildirimlerAcik: deger);
  }
}

final ayarlarProvider = NotifierProvider<AyarlarNotifier, AyarlarState>(() {
  return AyarlarNotifier();
});
