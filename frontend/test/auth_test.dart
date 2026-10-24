import 'package:flutter_test/flutter_test.dart';
import 'package:kura_ai/core/services/local_storage_service.dart';
import 'package:kura_ai/features/auth/data/repositories/auth_repository.dart';
import 'package:kura_ai/features/auth/presentation/controllers/auth_controller.dart';

void main() {
  group('AuthRepository & Local Storage Guest Mode', () {
    test('guest mode is true by default for zero forced login friction', () {
      final storage = LocalStorageService();
      final repo = AuthRepository(storage: storage);

      expect(repo.isGuest, isTrue);
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
}
