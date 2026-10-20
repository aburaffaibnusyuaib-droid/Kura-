/// DEMO DATA — data dummy untuk Home Screen.
/// Berlabel jelas sebagai [DEMO]; tidak boleh dikira sebagai respons AI atau
/// data pengguna nyata. Dipisahkan dari UI agar mudah diganti dengan
/// Live Repository di task selanjutnya.
library;

/// Model untuk Tips Hari Ini.
final class DailyTip {
  const DailyTip({required this.text});

  final String text;
}

/// Model untuk satu item aktivitas terakhir.
final class ActivityItem {
  const ActivityItem({
    required this.featureName,
    required this.description,
    required this.timeAgo,
  });

  final String featureName;
  final String description;
  final String timeAgo;
}

/// [DEMO] Repository data statis untuk Home Screen.
/// Semua data di sini adalah contoh, bukan data pengguna nyata.
abstract final class HomeDemoRepository {
  static const DailyTip dailyTip = DailyTip(
    text:
        'Simpan sayuran di kulkas dengan suhu 4–7°C agar tetap segar lebih lama!',
  );

  /// [DEMO] Aktivitas fiktif — bukan riwayat pengguna sesungguhnya.
  static const List<ActivityItem> recentActivities = [
    ActivityItem(
      featureName: 'Food Check',
      description: 'Kangkung (aman dikonsumsi)',
      timeAgo: '2 jam yang lalu',
    ),
  ];
}
