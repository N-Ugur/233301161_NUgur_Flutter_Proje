import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Uygulamanın karanlık mod durumunu tutan Riverpod provider'ı.
/// [true] = Karanlık Mod, [false] = Aydınlık Mod
final temaProvider = NotifierProvider<TemaNotifier, bool>(TemaNotifier.new);

class TemaNotifier extends Notifier<bool> {
  @override
  bool build() => false; // Varsayılan: Aydınlık Mod

  void toggle() => state = !state;
}
