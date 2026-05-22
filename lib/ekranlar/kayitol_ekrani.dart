import 'package:flutter/material.dart';
import '../servisler/auth_servisi.dart';
import 'giris_ekrani.dart';

class KayitEkrani extends StatefulWidget {
  const KayitEkrani({super.key});

  @override
  State<KayitEkrani> createState() => _KayitEkraniState();
}

class _KayitEkraniState extends State<KayitEkrani> {
  final TextEditingController _adController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _sifreController = TextEditingController();

  final AuthServisi _authServisi = AuthServisi();
  bool _yukleniyor = false;

  void _kayitIslemi() async {
    setState(() {
      _yukleniyor = true;
    });

    var kullanici = await _authServisi.kayitOl(
      _adController.text.trim(),
      _emailController.text.trim(),
      _sifreController.text.trim(),
    );

    if (!mounted) return;

    setState(() {
      _yukleniyor = false;
    });

    if (kullanici != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Kayıt Başarılı! Log kaydı Firestore'a işlendi."),
        ),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Kayıt başarısız oldu. E-posta formatını ve şifrenin en az 6 hane olmasını kontrol edin.",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Halı Saha - Kayıt Ol"),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/halisaha_logo.jpg',
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _adController,
                decoration: const InputDecoration(
                  labelText: "Ad Soyad",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => FocusScope.of(context).nextFocus(),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: "E-posta",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => FocusScope.of(context).nextFocus(),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _sifreController,
                decoration: const InputDecoration(
                  labelText: "Şifre (En az 6 karakter)",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _kayitIslemi(),
              ),
              const SizedBox(height: 24),
              _yukleniyor
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _kayitIslemi,
                        child: const Text(
                          "Kayıt Ol",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GirisEkrani(),
                    ),
                  );
                },
                child: const Text("Hesabın var mı? Giriş Yap"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
