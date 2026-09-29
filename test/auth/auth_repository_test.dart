import 'package:flutter_test/flutter_test.dart';
import 'package:worthbang/core/network/api_exception.dart';
import 'package:worthbang/core/network/fake_api_client.dart';
import 'package:worthbang/core/secure/token_storage.dart';
import 'package:worthbang/features/auth/data/auth_repository.dart';

void main() {
  late FakeApiClient client;
  late TokenStorage storage;
  late AuthRepository repo;

  setUp(() {
    client = FakeApiClient();
    storage = TokenStorage(MemorySecureKv());
    repo = AuthRepository(client: client, storage: storage);
  });

  group('AuthRepository', () {
    test('login sukses menyimpan token + user', () async {
      final session = await repo.login(
        email: 'dan@example.com',
        password: 'password123',
      );
      expect(session.user.email, 'dan@example.com');
      expect(await storage.readAccessToken(), 'fake-access-token');
      expect(await storage.readRefreshToken(), 'fake-refresh-token');
      expect((await repo.currentUser())?.name, 'Dan');
    });

    test('login gagal 401 melempar ApiException', () async {
      expect(
        () => repo.login(email: 'gagal@example.com', password: 'salah'),
        throwsA(isA<ApiException>()),
      );
    });

    test('register sukses langsung login (kontrak B1)', () async {
      final session = await repo.register(
        name: 'Budi',
        email: 'budi@example.com',
        password: 'password123',
      );
      expect(session.accessToken, isNotEmpty);
      expect(await storage.readAccessToken(), isNotEmpty);
    });

    test('register email duplikat 409 melempar ApiException', () async {
      expect(
        () => repo.register(
          name: 'Dan',
          email: 'dan@example.com',
          password: 'password123',
        ),
        throwsA(isA<ApiException>()),
      );
    });

    test('restoreSession tanpa token tersimpan → null', () async {
      expect(await repo.restoreSession(), isNull);
    });

    test('restoreSession dengan refresh token → user', () async {
      await repo.login(email: 'dan@example.com', password: 'password123');
      final user = await repo.restoreSession();
      expect(user?.email, 'dan@example.com');
    });

    test('restoreSession refresh gagal → null + token dibersihkan', () async {
      await repo.login(email: 'dan@example.com', password: 'password123');
      client.failRefresh = true;
      expect(await repo.restoreSession(), isNull);
      expect(await storage.readRefreshToken(), isNull);
    });

    test('logout menghapus token', () async {
      await repo.login(email: 'dan@example.com', password: 'password123');
      await repo.logout();
      expect(await storage.readAccessToken(), isNull);
      expect(await repo.currentUser(), isNull);
    });
  });
}
