import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/router.dart';
import 'core/config/app_config.dart';
import 'core/services/local_storage_service.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Muat konfigurasi lingkungan (.env) sebelum runApp
  try {
    await dotenv.load(fileName: ".env");
  } catch (_) {
    // Fallback jika file .env belum terpasang di release build
  }

  // 2. Inisialisasi penyimpanan lokal offline-first (SharedPreferences)
  try {
    await LocalStorageService.init();
  } catch (_) {
    // Tangani jika terjadi kendala platform storage
  }

  // 3. Inisialisasi Supabase dengan Guest/Anonymous Auth Fallback
  if (AppConfig.hasSupabaseConfig) {
    try {
      await Supabase.initialize(
        url: AppConfig.supabaseUrl,
        publishableKey: AppConfig.supabaseAnonKey,
      );
      final client = Supabase.instance.client;
      if (client.auth.currentUser == null) {
        try {
          await client.auth.signInAnonymously();
        } catch (_) {
          // Tetap lanjutkan sebagai tamu jika anonymous auth dinonaktifkan
        }
      }
    } catch (_) {
      // Abaikan jika offline atau URL belum aktif agar aplikasi tetap dapat dipakai
    }
  }

  // 4. Kunci orientasi portrait untuk layar ponsel Android HD+
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 5. Status bar transparan untuk tampilan edge-to-edge estetik
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    // ProviderScope wajib di root untuk flutter_riverpod
    const ProviderScope(
      child: KuraAiApp(),
    ),
  );
}

/// Root widget aplikasi Kura AI.
class KuraAiApp extends StatelessWidget {
  const KuraAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Kura AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}
