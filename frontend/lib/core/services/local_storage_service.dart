import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/food_check/domain/food_check_models.dart';
import '../../features/atur/domain/atur_models.dart';

/// Service untuk persistensi data lokal menggunakan SharedPreferences.
/// Menyimpan riwayat Food Check dan resep favorit secara offline-first.
class LocalStorageService {
  LocalStorageService([this._prefs]);

  final SharedPreferences? _prefs;
  final Map<String, List<String>> _inMemory = {};

  static const String _keyFoodCheckHistory = 'kura_food_check_history_v1';
  static const String _keySavedRecipes = 'kura_saved_recipes_v1';
  static const String _keyChatHistory = 'kura_chat_history_v1';
  static const String _keyOnboardingDone = 'kura_onboarding_done_v1';
  static const String _keyGuestMode = 'kura_guest_mode_v1';
  static const String _keyUserName = 'kura_user_name_v1';

  static LocalStorageService? _instance;

  /// Inisialisasi singleton instance
  static Future<LocalStorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    _instance = LocalStorageService(prefs);
    return _instance!;
  }

  static LocalStorageService get instance {
    _instance ??= LocalStorageService();
    return _instance!;
  }

  List<String>? _getStringList(String key) {
    if (_prefs != null) {
      return _prefs.getStringList(key);
    }
    return _inMemory[key];
  }

  Future<bool> _setStringList(String key, List<String> value) async {
    if (_prefs != null) {
      return await _prefs.setStringList(key, value);
    }
    _inMemory[key] = List.from(value);
    return true;
  }

  Future<bool> _remove(String key) async {
    if (_prefs != null) {
      return await _prefs.remove(key);
    }
    _inMemory.remove(key);
    return true;
  }

  // ── Food Check History ─────────────────────────────────────────

  /// Mengambil seluruh riwayat hasil scan Food Check
  List<FoodCheckResult> getFoodCheckHistory() {
    try {
      final jsonList = _getStringList(_keyFoodCheckHistory);
      if (jsonList == null || jsonList.isEmpty) return const [];
      return jsonList
          .map((item) =>
              FoodCheckResult.fromJson(jsonDecode(item) as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  /// Menyimpan satu hasil scan Food Check ke riwayat lokal
  Future<bool> saveFoodCheck(FoodCheckResult result) async {
    try {
      final currentList = getFoodCheckHistory();
      final updated = [
        result,
        ...currentList.where((item) => item.id != result.id),
      ];
      final limited =
          updated.take(20).map((r) => jsonEncode(r.toJson())).toList();
      return await _setStringList(_keyFoodCheckHistory, limited);
    } catch (_) {
      return false;
    }
  }

  /// Menghapus seluruh riwayat Food Check
  Future<bool> clearFoodCheckHistory() async {
    return await _remove(_keyFoodCheckHistory);
  }

  // ── Saved Recipes (Offline-First) ──────────────────────────────

  /// Mengambil semua resep yang disimpan pengguna
  List<Recipe> getSavedRecipes() {
    try {
      final jsonList = _getStringList(_keySavedRecipes);
      if (jsonList == null || jsonList.isEmpty) return const [];
      return jsonList
          .map((item) => Recipe.fromJson(jsonDecode(item) as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  /// Mengambil kumpulan ID resep yang tersimpan
  Set<String> getSavedRecipeIds() {
    return getSavedRecipes().map((r) => r.id).toSet();
  }

  /// Menyimpan satu resep ke penyimpanan lokal
  Future<bool> saveRecipe(Recipe recipe) async {
    try {
      final currentList = getSavedRecipes();
      final markedRecipe = recipe.copyWith(isSaved: true);
      final updated = [
        markedRecipe,
        ...currentList.where((r) => r.id != recipe.id),
      ];
      final encoded = updated.map((r) => jsonEncode(r.toJson())).toList();
      return await _setStringList(_keySavedRecipes, encoded);
    } catch (_) {
      return false;
    }
  }

  /// Menghapus resep dari penyimpanan lokal
  Future<bool> removeSavedRecipe(String recipeId) async {
    try {
      final currentList = getSavedRecipes();
      final updated = currentList.where((r) => r.id != recipeId).toList();
      final encoded = updated.map((r) => jsonEncode(r.toJson())).toList();
      return await _setStringList(_keySavedRecipes, encoded);
    } catch (_) {
      return false;
    }
  }

  // ── Kura AI Chat History (100% Local Storage - Zero Cloud Cost) ─

  /// Mengambil seluruh riwayat pesan chat lokal
  List<Map<String, dynamic>> getChatHistory() {
    try {
      final jsonList = _getStringList(_keyChatHistory);
      if (jsonList == null || jsonList.isEmpty) return const [];
      return jsonList
          .map((item) => jsonDecode(item) as Map<String, dynamic>)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  /// Menyimpan riwayat pesan chat ke lokal (dibatasi 50 pesan terakhir)
  Future<bool> saveChatHistory(List<Map<String, dynamic>> messages) async {
    try {
      final limited = messages.take(50).map((m) => jsonEncode(m)).toList();
      return await _setStringList(_keyChatHistory, limited);
    } catch (_) {
      return false;
    }
  }

  /// Menghapus seluruh riwayat chat
  Future<bool> clearChatHistory() async {
    return await _remove(_keyChatHistory);
  }

  // ── Onboarding State ──────────────────────────────────────────

  /// Memeriksa apakah pengguna sudah menyelesaikan onboarding
  bool isOnboardingDone() {
    if (_prefs != null) {
      return _prefs.getBool(_keyOnboardingDone) ?? false;
    }
    return _inMemory[_keyOnboardingDone]?.firstOrNull == 'true';
  }

  /// Menandai status onboarding telah selesai
  Future<bool> setOnboardingDone([bool done = true]) async {
    if (_prefs != null) {
      return await _prefs.setBool(_keyOnboardingDone, done);
    }
    _inMemory[_keyOnboardingDone] = [done.toString()];
    return true;
  }

  // ── Auth & Guest Mode State ───────────────────────────────────

  /// Memeriksa apakah pengguna berada dalam mode tamu
  bool isGuestMode() {
    if (_prefs != null) {
      return _prefs.getBool(_keyGuestMode) ?? true;
    }
    return _inMemory[_keyGuestMode]?.firstOrNull != 'false';
  }

  /// Mengatur status mode tamu
  Future<bool> setGuestMode([bool isGuest = true]) async {
    if (_prefs != null) {
      return await _prefs.setBool(_keyGuestMode, isGuest);
    }
    _inMemory[_keyGuestMode] = [isGuest.toString()];
    return true;
  }

  /// Menyimpan nama pengguna lokal
  Future<bool> setUserName(String name) async {
    if (_prefs != null) {
      return await _prefs.setString(_keyUserName, name);
    }
    _inMemory[_keyUserName] = [name];
    return true;
  }

  /// Mengambil nama pengguna lokal
  String getUserName() {
    if (_prefs != null) {
      return _prefs.getString(_keyUserName) ?? 'Pengguna';
    }
    return _inMemory[_keyUserName]?.firstOrNull ?? 'Pengguna';
  }
}
