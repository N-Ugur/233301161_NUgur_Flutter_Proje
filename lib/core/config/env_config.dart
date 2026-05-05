import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  EnvConfig._(); // Özel kurucu metot (Private constructor) ile nesne üretilmesini engelliyoruz

  static String get firebaseApiKey => _get('FIREBASE_API_KEY');
  static String get paymentGatewayApiKey => _get('PAYMENT_GATEWAY_API_KEY');
  static String get appName => _get('APP_NAME', fallback: 'Halı Saha App');
  static String get appEnv => _get('APP_ENV', fallback: 'production');

  /// .env dosyasından güvenli bir şekilde veri okumak için yardımcı metod.
  /// Eğer key bulunamazsa fallback değerini döndürür, aksi takdirde Exception fırlatabilir.
  static String _get(String key, {String fallback = ''}) {
    return dotenv.env[key] ?? fallback;
  }
}
