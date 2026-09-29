import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/network/api_client.dart';

final wishlistApiProvider = Provider<WishlistApi>(
  (ref) => WishlistApi(ref.watch(apiClientProvider)),
);

/// Item wishlist (kontrak: B2 GET/POST/DELETE /api/v1/wishlist).
class WishlistItem {
  const WishlistItem({
    required this.id,
    required this.query,
    required this.mode,
    this.targetPrice,
    this.createdAt,
  });

  final int id;
  final String query;
  final String mode;
  final int? targetPrice;
  final DateTime? createdAt;

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    DateTime? created;
    final c = json['created_at'] as String?;
    if (c != null) created = DateTime.tryParse(c);
    return WishlistItem(
      id: (json['id'] as num).toInt(),
      query: json['query'] as String? ?? '',
      mode: json['mode'] as String? ?? 'pc',
      targetPrice: (json['target_price'] as num?)?.toInt(),
      createdAt: created,
    );
  }
}

class WishlistApi {
  WishlistApi(this._client);

  final ApiClient _client;

  Future<List<WishlistItem>> getWishlist() async {
    final json = await _client.getJson('/api/v1/wishlist');
    return ((json['items'] as List?) ?? [])
        .map((e) => WishlistItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<WishlistItem> addWishlist({
    required String query,
    required String mode,
    int? targetPrice,
  }) async {
    final Map<String, dynamic> body = {'query': query, 'mode': mode};
    if (targetPrice != null) body['target_price'] = targetPrice;
    final json = await _client.postJson('/api/v1/wishlist', body: body);
    return WishlistItem.fromJson(json);
  }

  Future<void> deleteWishlist(int id) =>
      _client.delete('/api/v1/wishlist/$id');
}
