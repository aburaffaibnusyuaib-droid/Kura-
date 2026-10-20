# Kura AI — Official Project Instructions

**Dokumen ini adalah satu-satunya sumber instruksi resmi untuk project.** Jika ada konflik dengan catatan lama, ikuti dokumen ini dan `docs/DECISION_LOG.md`.

## Start here
1. Pastikan folder ini sudah digabungkan ke root project `C:\PPLG\kura app\` tanpa menghapus mockup atau kode yang sudah ada.
2. Buka root project di Antigravity.
3. Berikan agent hanya `tasks/TASK-00_REPOSITORY_AUDIT.md`.
4. Review hasil audit. Jangan izinkan implementasi sebelum audit selesai.
5. Kerjakan satu task per giliran; jalankan tes; periksa diff; setujui task berikutnya secara eksplisit.

## Locked product decisions
- Android-first; Flutter Web ditunda sampai Android stabil.
- MVP hanya Food Check dan Atur (Zero Waste Food). Kura AI Chat tidak termasuk MVP.
- Flutter/Dart frontend; FastAPI/Python backend; Supabase Auth/PostgreSQL.
- Guest dan akun sejak awal, tetapi core flow harus tetap tersedia untuk guest.
- Bahasa UI Bahasa Indonesia; arsitektur disiapkan untuk lokalisasi berikutnya.
- Light Mode dahulu. Token desain dipusatkan supaya Dark Mode bisa ditambahkan kemudian.
- Gunakan mockup yang diberikan sebagai referensi utama; perbaiki aksesibilitas/UX dengan perubahan yang terdokumentasi.
- Foto tidak disimpan permanen secara default; riwayat ditunda.
- AI provider harus dipilih setelah mengecek dukungan gambar, ketersediaan, terms, rate limit, dan kuota saat ini. Jangan menjanjikan layanan gratis permanen.
- Satu task, satu pemeriksaan, tunggu persetujuan.
- Target code freeze 30 November 2026; awal Desember adalah buffer untuk bug kritis.

## Scope summary
Food Check: camera/gallery → preview → AI assessment → follow-up questions when useful → result and practical next step.
Atur: camera/gallery → candidate ingredients → user edits/confirms → exactly 3 recipe cards → recipe detail.

## Do not start
Jangan mulai coding sebelum TASK-00 selesai. Jangan menyalin dua paket dokumentasi lama berdampingan. Gunakan hanya struktur paket final ini sebagai sumber instruksi resmi.
