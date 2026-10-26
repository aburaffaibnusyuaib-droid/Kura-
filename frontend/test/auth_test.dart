import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;
import 'package:kura_ai/core/services/local_storage_service.dart';
import 'package:kura_ai/core/widgets/kura_global_app_bar.dart';
import 'package:kura_ai/features/atur/domain/atur_models.dart';
import 'package:kura_ai/features/atur/presentation/widgets/cropped_ingredient_image.dart';
import 'package:kura_ai/features/atur/utils/ingredient_image_resolver.dart';
import 'package:kura_ai/features/auth/data/repositories/auth_repository.dart';
import 'package:kura_ai/features/auth/presentation/controllers/auth_controller.dart';

void main() {
  group('AuthRepository & Local Storage Guest Mode', () {
    test('guest mode is false by default until activated or chosen', () {
      final storage = LocalStorageService();
      final repo = AuthRepository(storage: storage);

      expect(repo.isGuest, isFalse);
    });

    test('signInAsGuest activates guest flag and stores Tamu Kura name', () async {
      final storage = LocalStorageService();
      final repo = AuthRepository(storage: storage);

      await repo.signInAsGuest();
      expect(repo.isGuest, isTrue);
      expect(storage.getUserName(), 'Tamu Kura');
    });

    test('signOut resets guest mode and clears user name to Pengguna', () async {
      final storage = LocalStorageService();
      final repo = AuthRepository(storage: storage);

      await repo.signInAsGuest();
      await repo.signOut();

      expect(storage.getUserName(), 'Pengguna');
      expect(storage.isAuthSessionActive(), isFalse);
    });

    test('auth session tracking activates and resets correctly', () async {
      final storage = LocalStorageService();
      expect(storage.isAuthSessionActive(), isFalse);

      await storage.setAuthSessionActive(true);
      expect(storage.isAuthSessionActive(), isTrue);

      await storage.setAuthSessionActive(false);
      expect(storage.isAuthSessionActive(), isFalse);
    });
  });

  group('AuthNotifier & KuraAuthState', () {
    test('continueAsGuest sets isGuest to true in state', () async {
      final storage = LocalStorageService();
      final repo = AuthRepository(storage: storage);
      final notifier = AuthNotifier(repo);

      await notifier.continueAsGuest();
      expect(notifier.state.isGuest, isTrue);
      expect(notifier.state.isLoading, isFalse);
    });

    test('clearError and clearSuccess properly reset state messages', () {
      final storage = LocalStorageService();
      final repo = AuthRepository(storage: storage);
      final notifier = AuthNotifier(repo);

      notifier.state = notifier.state.copyWith(
        errorMessage: 'Terjadi kesalahan jaringan',
        successMessage: 'Berhasil',
      );

      expect(notifier.state.errorMessage, isNotNull);
      expect(notifier.state.successMessage, isNotNull);

      notifier.clearError();
      expect(notifier.state.errorMessage, isNull);

      notifier.clearSuccess();
      expect(notifier.state.successMessage, isNull);
    });
  });

  group('Hybrid Precise Ingredient Image Resolver', () {
    test('resolve maps known Indonesian staple to curated Unsplash CDN URL', () {
      final url = IngredientImageResolver.resolve('bawang bombay');
      expect(url, contains('images.unsplash.com/photo-1587049352846-4a222e784d38'));
      expect(url, isNot(contains('source.unsplash.com')));
    });

    test('resolve matches compound ingredient phrase with high priority', () {
      final url = IngredientImageResolver.resolve('telur ayam negeri segar');
      expect(url, contains('images.unsplash.com/photo-1582722872445-44dc5f7e3c8f'));
    });

    test('resolve falls back to curated neutral food board photo for unknown item', () {
      final url = IngredientImageResolver.resolve('bahan_misterius_xyz_123');
      expect(url, IngredientImageResolver.fallbackImageUrl);
    });

    test('getSearchUrl maintains backward compatibility with resolve', () {
      final url = IngredientImageResolver.getSearchUrl('kecap manis');
      expect(url, IngredientImageResolver.resolve('kecap manis'));
    });
  });

  group('On-Device AI Bounding Box & Data Contract', () {
    test('DetectedIngredient correctly serializes and deserializes box_2d', () {
      final json = {
        'id': 'ing_test_1',
        'nama_bahan': 'Bawang Bombay',
        'kategori': 'Sayuran',
        'jumlah_perkiraan': '1 butir',
        'box_2d': [120, 230, 450, 670],
      };

      final ingredient = DetectedIngredient.fromJson(json);
      expect(ingredient.name, 'Bawang Bombay');
      expect(ingredient.box2d, [120, 230, 450, 670]);

      final serialized = ingredient.toJson();
      expect(serialized['box_2d'], [120, 230, 450, 670]);
    });

    test('DetectedIngredient gracefully handles missing or malformed box_2d', () {
      final json = {
        'id': 'ing_test_2',
        'name': 'Wortel',
      };

      final ingredient = DetectedIngredient.fromJson(json);
      expect(ingredient.box2d, isNull);
    });
  });

  group('KuraGlobalAppBar Profile Modal Verification', () {
    testWidgets('shows User Profile Modal (Akun Saya & Terverifikasi) when authenticated user taps avatar', (tester) async {
      final storage = LocalStorageService.instance;
      await storage.setAuthSessionActive(true);
      await storage.setGuestMode(false);

      final repo = AuthRepository(storage: storage);
      final notifier = AuthNotifier(repo);
      notifier.state = notifier.state.copyWith(
        isGuest: false,
        user: const User(
          id: 'test_user_id',
          appMetadata: {},
          userMetadata: {'full_name': 'Budi Santoso'},
          aud: 'authenticated',
          email: 'budi@example.com',
          createdAt: '2026-01-01',
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith((ref) => notifier),
          ],
          child: const MaterialApp(
            home: Scaffold(
              appBar: KuraGlobalAppBar(),
            ),
          ),
        ),
      );
      await tester.pump();

      // Tap profile avatar
      await tester.tap(find.byType(CircleAvatar));
      await tester.pumpAndSettle();

      // Verify User Profile Modal content is displayed
      expect(find.text('Akun Saya'), findsOneWidget);
      expect(find.text('Akun Terverifikasi'), findsOneWidget);
      expect(find.text('budi@example.com'), findsOneWidget);
      expect(find.text('Keluar / Ganti Akun'), findsOneWidget);
      // Verify Guest Modal content is NOT displayed
      expect(find.text('Mode Tamu Aktif'), findsNothing);
      expect(find.text('Masuk Sekarang'), findsNothing);
    });

    testWidgets('shows Guest Modal (Mode Tamu Aktif & Masuk Sekarang) when guest taps avatar', (tester) async {
      final storage = LocalStorageService.instance;
      await storage.setAuthSessionActive(false);
      await storage.setGuestMode(true);

      final repo = AuthRepository(storage: storage);
      final notifier = AuthNotifier(repo);
      notifier.state = notifier.state.copyWith(
        isGuest: true,
        user: null,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith((ref) => notifier),
          ],
          child: const MaterialApp(
            home: Scaffold(
              appBar: KuraGlobalAppBar(),
            ),
          ),
        ),
      );
      await tester.pump();

      // Tap profile avatar
      await tester.tap(find.byType(CircleAvatar));
      await tester.pumpAndSettle();

      // Verify Guest Modal content is displayed
      expect(find.text('Mode Tamu Aktif'), findsOneWidget);
      expect(find.text('Masuk Sekarang'), findsOneWidget);
      // Verify User Profile Modal content is NOT displayed
      expect(find.text('Akun Terverifikasi'), findsNothing);
      expect(find.text('Keluar / Ganti Akun'), findsNothing);
    });
  });

  group('CroppedIngredientImage On-Device Crop & Fallback', () {
    testWidgets('renders local placeholder image when box2d is empty or missing', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 150,
              height: 150,
              child: CroppedIngredientImage(
                box2d: [],
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      final imageFinder = find.byType(Image);
      expect(imageFinder, findsOneWidget);
      final Image imageWidget = tester.widget(imageFinder);
      expect(imageWidget.image, isA<AssetImage>());
      final AssetImage assetImage = imageWidget.image as AssetImage;
      expect(assetImage.assetName, 'assets/images/placeholder_ingredients.png');
    });
  });
}
