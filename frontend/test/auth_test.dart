import 'package:flutter_test/flutter_test.dart';
import 'package:kura_ai/core/services/local_storage_service.dart';
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

  group('Dynamic AI Ingredient Image Resolver', () {
    test('getSearchUrl cleans whitespace and formats Unsplash featured URL', () {
      final url = IngredientImageResolver.getSearchUrl('yellow onion raw fresh');
      expect(url, 'https://source.unsplash.com/featured/600x600/?yellow-onion-raw-fresh');
    });

    test('getSearchUrl encodes special characters properly', () {
      final url = IngredientImageResolver.getSearchUrl('sweet soy sauce / bottle');
      expect(url, contains('https://source.unsplash.com/featured/600x600/?'));
      expect(url, isNot(contains(' ')));
    });
  });
}
