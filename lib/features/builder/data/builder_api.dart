import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/network/api_client.dart';
import 'builder_models.dart';

final builderApiProvider = Provider<BuilderApi>(
  (ref) => BuilderApi(ref.watch(apiClientProvider)),
);

/// API random builder (B6 POST /api/v1/builder/random).
class BuilderApi {
  BuilderApi(this._client);

  final ApiClient _client;

  Future<RandomBuild> randomBuild({
    required int budget,
    required String useCase,
  }) async {
    final json = await _client.postJson(
      '/api/v1/builder/random',
      body: {'budget': budget, 'use_case': useCase},
    );
    return RandomBuild.fromJson(json);
  }
}
