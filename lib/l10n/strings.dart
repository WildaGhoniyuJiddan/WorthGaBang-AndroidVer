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

  // Auth (T2).
  static const loginTitle = 'Masuk';
  static const registerTitle = 'Daftar Akun';
  static const nameLabel = 'Nama';
  static const nameRequired = 'Nama wajib diisi';
  static const emailLabel = 'Email';
  static const emailInvalid = 'Format email tidak valid';
  static const passwordLabel = 'Kata sandi';
  static const passwordMin = 'Minimal 8 karakter';
  static const loginButton = 'Masuk';
  static const registerButton = 'Daftar';
  static const goToRegister = 'Belum punya akun? Daftar di sini';
  static const goToLogin = 'Sudah punya akun? Masuk di sini';
  static const biometricButton = 'Masuk dengan sidik jari';

  // Price check (T3).
  static const priceCheckTitle = 'Cek Harga';
  static const queryLabel = 'Nama produk';
  static const queryHint = 'cth: RTX 4060';
  static const queryMin = 'Minimal 2 karakter';
  static const priceLabel = 'Harga yang ditawarkan';
  static const priceInvalid = 'Masukkan harga yang valid';
  static const conditionLabel = 'Kondisi';
  static const checkButton = 'Cek Kelayakan';
  static const doneButton = 'Selesai';

  // Bundle (T4).
  static const bundleTitle = 'Cek Bundle';
  static const bundleModeButton = 'Mode Bundle (multi-komponen)';
  static const bundleAddItem = 'Tambah komponen';
  static const bundleItemLabel = 'Komponen';
  static const bundlePriceLabel = 'Harga paket yang ditawarkan';

  // Search filter & sort (T5).
  static const searchScreenTitle = 'Cari Produk';
  static const searchButton = 'Cari';
  static const maxPriceLabel = 'Harga maks';
  static const sortLabel = 'Urutkan';
  static const searchEmpty = 'Tidak ada listing yang cocok dengan filter.';

  // History & verify (T6).
  static const historyScreenTitle = 'Riwayat Analisis';
  static const historyEmpty =
      'Belum ada riwayat. Lakukan cek harga dulu di Beranda.';
  static const verifyChainButton = 'Verifikasi rantai';
  static const syncButton = 'Sinkron ke server';
  static const verifyTitle = 'Verifikasi Hash Chain';
  static const verifyEmpty = 'Belum ada blok untuk diverifikasi.';
  static String verifyOk(int n) => 'Rantai valid: $n blok terverifikasi.';
  static const verifyFailed =
      'Rantai RUSAK: ada blok yang datanya diubah!';
  static const tamperSelfTest = 'Self-test: simulasi tampering (debug)';
  static const tamperDemoNote =
      'Mode demo: satu blok diubah di memori (database asli tidak disentuh).';

  // Tren harga (T7).
  static const trendTitle = 'Tren Harga';
  static const viewTrendButton = 'Lihat tren harga';

  // Random builder (T8).
  static const builderTitle = 'Rakit PC Acak';
  static const budgetLabel = 'Budget';
  static const randomBuildButton = 'Acak Rakit';
  static const shakeHint = 'Goyangkan HP untuk mengacak ulang';
  static const shakeDetected = 'Shake terdeteksi — merakit ulang…';
  static const totalLabel = 'Total';

  // Toko terdekat (T9).
  static const storesTitle = 'Toko Terdekat';
  static const refreshLabel = 'Muat';
  static const storesEmpty = 'Tidak ada toko di sekitar.';
  static const cheapestLabel = 'TERMURAH';
  static const demoLocationNote =
      'Izin lokasi tidak diberikan — memakai lokasi demo Jakarta.';

  // Konverter (T10).
  static const toolsTitle = 'Konverter';
  static const currencySection = 'Mata Uang';
  static const timezoneSection = 'Zona Waktu';
  static const amountLabel = 'Nominal (IDR)';
  static const toLabel = 'Ke';
  static const fromLabel = 'Dari';
}
