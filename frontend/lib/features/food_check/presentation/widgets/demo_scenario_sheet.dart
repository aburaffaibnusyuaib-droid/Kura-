import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Modal bottom sheet untuk memilih skenario simulasi demo hasil Food Check.
class DemoScenarioSheet extends StatelessWidget {
  const DemoScenarioSheet({
    super.key,
    required this.currentScenario,
    required this.isOffline,
    required this.onSelectScenario,
    required this.onToggleOffline,
  });

  final String currentScenario;
  final bool isOffline;
  final ValueChanged<String> onSelectScenario;
  final ValueChanged<bool> onToggleOffline;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Skenario Pengujian (DEMO)',
                style: AppTextStyles.titleLarge,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.foodCheckCardTint,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '14 Mockup',
                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.electricTeal),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Pilih variasi respon AI untuk menguji seluruh mockup tampilan hasil:',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 16),

          _scenarioTile(
            title: 'Mockup 06: Kemasan Aman',
            subtitle: 'Sarden ABC - Tanggal jauh & kemasan baik (Hijau)',
            key: 'packaged_safe',
            icon: Icons.check_circle_rounded,
            iconColor: AppColors.statusSafe,
          ),
          _scenarioTile(
            title: 'Mockup 07: Kemasan Peringatan',
            subtitle: 'Keripik Chitato - Kemasan sedikit penyok (Kuning)',
            key: 'packaged_warning',
            icon: Icons.warning_rounded,
            iconColor: AppColors.statusWarning,
          ),
          _scenarioTile(
            title: 'Mockup 08: Kemasan Bahaya',
            subtitle: 'Susu UHT Ultra Milk - Lewat kedaluwarsa (Merah)',
            key: 'packaged_danger',
            icon: Icons.dangerous_rounded,
            iconColor: AppColors.statusDanger,
          ),
          _scenarioTile(
            title: 'Mockup 09: Segar & Aman',
            subtitle: 'Bayam - Warna hijau cerah & renyah (Hijau)',
            key: 'fresh_safe',
            icon: Icons.eco_rounded,
            iconColor: AppColors.statusSafe,
          ),
          _scenarioTile(
            title: 'Mockup 11: Segar Belum Pasti',
            subtitle: 'Buah Berry - Perlu verifikasi fisik manual (Kuning)',
            key: 'fresh_uncertain',
            icon: Icons.help_outline_rounded,
            iconColor: AppColors.statusWarning,
          ),

          const Divider(height: 24),

          // Toggle Simulasi Offline (Mockup 13)
          SwitchListTile(
            title: const Text('Simulasi Offline (Mockup 13)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            subtitle: const Text('Tampilkan layar error "Tidak Ada Koneksi"', style: TextStyle(fontSize: 12)),
            value: isOffline,
            activeThumbColor: AppColors.electricTeal,
            contentPadding: EdgeInsets.zero,
            onChanged: (val) {
              HapticFeedback.lightImpact();
              onToggleOffline(val);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _scenarioTile({
    required String title,
    required String subtitle,
    required String key,
    required IconData icon,
    required Color iconColor,
  }) {
    final isSelected = currentScenario == key;

    return ListTile(
      onTap: () {
        HapticFeedback.lightImpact();
        onSelectScenario(key);
      },
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: iconColor),
      title: Text(title, style: AppTextStyles.bodyMedium.copyWith(fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500)),
      subtitle: Text(subtitle, style: AppTextStyles.bodySmall.copyWith(fontSize: 11)),
      trailing: isSelected
          ? const Icon(Icons.radio_button_checked, color: AppColors.electricTeal)
          : const Icon(Icons.radio_button_off, color: AppColors.textHint),
    );
  }
}
