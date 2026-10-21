import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// === SERVICES ===
import 'core/services/security_service.dart';
// === KONFIGURASI FIREBASE ===
import 'firebase_options.dart';
// === PROVIDERS ===
import 'providers/admin_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/logistik_provider.dart';
import 'providers/produksi_provider.dart';
// === SCREENS ===
import 'ui/auth/login_screen.dart';
import 'ui/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Kunci Orientasi Layar (Portrait)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 2. Atur Warna Status Bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // 3. Inisialisasi Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..checkSession()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (_) => ProduksiProvider()),
        ChangeNotifierProvider(create: (_) => LogistikProvider()),
      ],
      child: const AbsensiApp(),
    ),
  );
}

class AbsensiApp extends StatelessWidget {
  const AbsensiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistem Operasional Shinpo',
      debugShowCheckedModeBanner: false,

      // === TEMA APLIKASI ===
      theme: ThemeData(
        useMaterial3: true,
        // Hapus fontFamily jika belum download font, pakai default saja biar aman
        // fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue.shade900,
          primary: Colors.blue.shade900,
          secondary: Colors.orangeAccent,
          background: Colors.grey.shade50,
        ),

        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue.shade900,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade900,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 2,
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.blue.shade900, width: 2),
          ),
        ),
      ),

      // === LOGIKA ROUTING UTAMA ===
      home: Consumer<AuthProvider>(
        builder: (context, auth, child) {
          // A. Jika User Belum Login
          if (auth.userData == null) {
            return const LoginScreen();
          }

          // B. Jika User Sudah Login -> Cek Keamanan (Anti-FakeGPS)
          return FutureBuilder<bool>(
            future: SecurityService().checkDeviceSecurity(
              context,
              auth.userData?['uid'] ?? "",
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              final bool isSecure = snapshot.data ?? false;

              if (isSecure) {
                return const DashboardScreen();
              } else {
                return Scaffold(
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.security, size: 60, color: Colors.red),
                        const SizedBox(height: 20),
                        const Text("Akses Dibatasi (Keamanan)"),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () => auth.logout(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: const Text("Keluar"),
                        ),
                      ],
                    ),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}
