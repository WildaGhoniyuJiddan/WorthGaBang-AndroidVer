import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:worthbang/providers/providers.dart';
import 'package:worthbang/services/api_client.dart';
import 'package:worthbang/models/chat_models.dart';

final chatApiProvider = Provider<ChatApi>(
  (ref) => ChatApi(ref.watch(apiClientProvider)),
);

/// API chatbot Bang Worth (B7 POST /api/v1/chat/ask).
class ChatApi {
  ChatApi(this._client);

  final ApiClient _client;

  Future<ChatReply> ask(
    String message, {
    List<ChatMessage> history = const [],
  }) async {
    try {
      final json = await _client.postJson('/api/v1/chat/ask', body: {
        'message': message,
        'history': history.map((m) => m.toJson()).toList(),
      });
      return ChatReply.fromJson(json);
    } catch (e) {
      // Jika backend belum aktif atau GEMINI_API_KEY belum dikonfigurasi,
      // fallback ke respon lokal cerdas Bang Worth agar fitur tetap bisa dicoba.
      return _localFallback(message, error: e);
    }
  }

  ChatReply _localFallback(String message, {Object? error}) {
    final msg = message.toLowerCase();

    // Deteksi off-topic
    if (msg.contains('resep') ||
        msg.contains('rendang') ||
        msg.contains('presiden') ||
        msg.contains('cuaca') ||
        msg.contains('pr ') ||
        msg.contains('matematika')) {
      return const ChatReply(
        reply:
            'Waduh, itu di luar keahlianku! Aku Bang Worth, asisten khusus rekomendasi rakitan PC, cek kelayakan harga komponen, dan konsultasi hardware. Ada yang mau ditanyakan soal PC/laptop?',
      );
    }

    final wantsBuild = msg.contains('rakit') ||
        msg.contains('build') ||
        msg.contains('pc') ||
        msg.contains('spek') ||
        msg.contains('rekomendasi') ||
        RegExp(r'\d+\s*(?:juta|jt|k|rb|000)').hasMatch(msg);

    if (wantsBuild) {
      // Deteksi budget jika ada
      int budget = 8000000;
      final match = RegExp(r'(\d+)\s*(?:juta|jt)').firstMatch(msg);
      if (match != null) {
        final val = int.tryParse(match.group(1)!) ?? 8;
        budget = val * 1000000;
      }

      final isHighEnd = budget >= 15000000;
      final isLowBudget = budget <= 5000000;

      final items = isHighEnd
          ? const [
              BuildItem(
                  component: 'CPU',
                  name: 'Intel Core i5-13600K / Ryzen 7 7700X',
                  price: 4850000),
              BuildItem(
                  component: 'GPU',
                  name: 'Nvidia GeForce RTX 4070 12GB',
                  price: 9750000),
              BuildItem(
                  component: 'RAM',
                  name: 'Corsair Vengeance DDR5 32GB (2x16GB)',
                  price: 1850000),
              BuildItem(
                  component: 'SSD',
                  name: 'Samsung 980 Pro 1TB NVMe Gen4',
                  price: 1450000),
              BuildItem(
                  component: 'PSU',
                  name: 'MSI MAG A750GL 750W 80+ Gold',
                  price: 1400000),
            ]
          : isLowBudget
              ? const [
                  BuildItem(
                      component: 'CPU',
                      name: 'AMD Ryzen 5 4600G (Integrated Radeon)',
                      price: 1450000),
                  BuildItem(
                      component: 'GPU',
                      name: 'iGPU Radeon Vega 7 (Bawaan CPU)',
                      price: 0),
                  BuildItem(
                      component: 'RAM',
                      name: 'TeamGroup Elite Plus 2x8GB DDR4 3200MHz',
                      price: 620000),
                  BuildItem(
                      component: 'SSD',
                      name: 'ADATA SU650 256GB SATA/M.2',
                      price: 320000),
                  BuildItem(
                      component: 'PSU',
                      name: 'DeepCool PF450 450W 80+ White',
                      price: 450000),
                ]
              : const [
                  BuildItem(
                      component: 'CPU',
                      name: 'AMD Ryzen 5 5600 [Tray]',
                      price: 1825000),
                  BuildItem(
                      component: 'GPU',
                      name: 'GALAX GeForce RTX 4060 8GB GDDR6',
                      price: 4650000),
                  BuildItem(
                      component: 'RAM',
                      name: 'TeamGroup T-Force Dark Za 2x8GB DDR4',
                      price: 650000),
                  BuildItem(
                      component: 'SSD',
                      name: 'ADATA Legend 710 512GB NVMe M.2',
                      price: 550000),
                  BuildItem(
                      component: 'PSU',
                      name: 'MSI MAG A550BN 550W 80+ Bronze',
                      price: 750000),
                ];

      final total = items.fold<int>(0, (sum, it) => sum + it.price);

      return ChatReply(
        reply:
            'Siap! Ini rekomendasi rakitan PC optimal di kisaran budget kamu. Semua komponen sudah diseleksi agar seimbang dan tidak bottleneck.\n\n'
            '*(Catatan: Menjawab via asisten lokal Bang Worth. Untuk respons AI live via Gemini, pastikan server backend Python & GEMINI_API_KEY sudah aktif).*',
        build: BuildCardData(
          items: items,
          total: total,
          note:
              'Belum termasuk casing & motherboard. Cek kelayakan harga setiap komponen di fitur Cek Harga ya!',
        ),
      );
    }

    if (msg.contains('worth') ||
        msg.contains('harga') ||
        msg.contains('murah')) {
      return const ChatReply(
        reply: 'Patokan gampang dari Bang Worth:\n'
            '• Skor ≥ 80: Sangat Worth It (harga di bawah rata-rata pasar)\n'
            '• Skor 60–79: Wajar / Masuk Akal\n'
            '• Skor < 60: Kemahalan / Kurang Worth It\n\n'
            'Kamu bisa pakai fitur **Cek Harga** di aplikasi untuk menganalisis listing barang yang mau kamu beli!',
      );
    }

    return const ChatReply(
      reply: 'Halo! Aku Bang Worth, konsultan hardware PC & laptop kamu. '
          'Kamu bisa tanya rekomendasi rakitan PC (misal: "rakit PC gaming 10 juta"), kelayakan harga komponen, atau spesifikasi yang kamu butuhkan!',
    );
  }
}
