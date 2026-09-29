/// Kumpulan string Bahasa Indonesia untuk seluruh aplikasi.
///
/// Aturan: tidak ada teks user-facing yang di-hardcode di widget;
/// semua lewat class ini agar konsisten dan mudah diaudit.
abstract final class AppStrings {
  static const appName = 'WorthBang';
  static const appTagline = 'Cek harga, sebelum bayar.';

  // Tab navigasi bawah.
  static const tabHome = 'Beranda';
  static const tabSearch = 'Cari';
  static const tabHistory = 'Riwayat';
  static const tabProfile = 'Profil';

  // Placeholder tiap tab (diganti screen asli di tiket berikutnya).
  static const homeTitle = 'Beranda';
  static const homePlaceholder =
      'Form cek harga akan hadir di sini (T2: Price Check).';
  static const searchTitle = 'Cari';
  static const searchPlaceholder =
      'Filter & sortir hasil akan hadir di sini (T4: Search).';
  static const historyTitle = 'Riwayat';
  static const historyPlaceholder =
      'Daftar riwayat analisis akan hadir di sini (T5: History).';
  static const profileTitle = 'Profil';
  static const profilePlaceholder =
      'Pengaturan profil akan hadir di sini (T6: Profile).';

  // Label verdict — SELALU tampil bersama warna (jangan hanya warna).
  static const verdictWorthIt = 'Worth It';
  static const verdictFair = 'Wajar';
  static const verdictOverpriced = 'Kemahalan';
}
