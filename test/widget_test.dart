import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worthbang/app/app.dart';
import 'package:worthbang/features/auth/data/auth_models.dart';
import 'package:worthbang/features/auth/presentation/auth_controller.dart';
import 'package:worthbang/l10n/strings.dart';

/// Stub auth: langsung authenticated agar guard router tidak redirect ke /login.
class _FakeAuthController extends AuthController {
  @override
  AuthState build() => const AuthState(
        status: AuthStatus.authenticated,
        user: AppUser(id: 1, name: 'Dan', email: 'dan@example.com'),
      );
}

/// Widget test bottom-nav shell (T0):
/// - 4 tab tampil dengan label Bahasa Indonesia.
/// - Tap tiap tab menampilkan placeholder screen yang sesuai.
///
/// Catatan: teks label tab juga dipakai sebagai judul AppBar placeholder,
/// jadi tap dilakukan lewat [NavigationDestination], bukan [find.text].
void main() {
  Finder navDestination(int index) =>
      find.byType(NavigationDestination).at(index);

  Finder navLabel(String label) => find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text(label),
      );

  ProviderScope app() => ProviderScope(
        overrides: [
          authControllerProvider.overrideWith(_FakeAuthController.new),
        ],
        child: const WorthBangApp(),
      );

  testWidgets('BottomNavShell menampilkan 4 tab dan berpindah tab',
      (WidgetTester tester) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    // Empat label tab dalam Bahasa Indonesia ada di NavigationBar.
    expect(navLabel(AppStrings.tabHome), findsOneWidget);
    expect(navLabel(AppStrings.tabSearch), findsOneWidget);
    expect(navLabel(AppStrings.tabHistory), findsOneWidget);
    expect(navLabel(AppStrings.tabProfile), findsOneWidget);

    // Tab awal: Beranda (form cek harga T3).
    expect(find.text(AppStrings.priceCheckTitle), findsOneWidget);

    // Pindah ke tab Cari.
    await tester.tap(navDestination(1));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.searchScreenTitle), findsOneWidget);

    // Pindah ke tab Riwayat.
    await tester.tap(navDestination(2));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.historyScreenTitle), findsOneWidget);

    // Pindah ke tab Profil.
    await tester.tap(navDestination(3));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.profilePlaceholder), findsOneWidget);

    // Kembali ke Beranda.
    await tester.tap(navDestination(0));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.priceCheckTitle), findsOneWidget);
  });

  testWidgets('NavigationBar punya tepat 4 destination',
      (WidgetTester tester) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationDestination), findsNWidgets(4));
  });
}
