import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/network/api_result.dart';
import '../../../core/utils/rupiah.dart';
import '../../../l10n/strings.dart';
import '../data/trend_models.dart';
import '../data/trends_api.dart';

/// Tab Tren: grafik harga 30 hari + min/max/avg/perubahan + ringkasan deskriptif.
class TrendsScreenContent extends ConsumerStatefulWidget {
  const TrendsScreenContent({super.key, this.initialQuery = 'RTX 4060'});

  final String initialQuery;

  @override
  ConsumerState<TrendsScreenContent> createState() =>
      _TrendsScreenContentState();
}

class _TrendsScreenContentState
    extends ConsumerState<TrendsScreenContent> {
  final _query = TextEditingController();
  int _days = 30;
  ApiResult<TrendData>? _state;

  @override
  void initState() {
    super.initState();
    _query.text = widget.initialQuery;
    _load();
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (_query.text.trim().isEmpty) return;
    setState(() => _state = const ApiLoading());
    try {
      final data = await ref
          .read(trendsApiProvider)
          .getTrend(_query.text.trim(), days: _days);
      setState(() => _state = ApiSuccess(data));
    } catch (e) {
      setState(() => _state = ApiError(e.toString()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = _state;
    final data =
        state is ApiSuccess<TrendData> ? state.data : null;

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.trendTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _query,
                    decoration: const InputDecoration(
                      labelText: AppStrings.queryLabel,
                      prefixIcon: Icon(Icons.show_chart),
                    ),
                    onSubmitted: (_) => _load(),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<int>(
                  value: _days,
                  items: const [7, 30, 90]
                      .map((d) => DropdownMenuItem(
                          value: d, child: Text('$d hari')))
                      .toList(),
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => _days = v);
                    _load();
                  },
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: state is ApiLoading ? null : _load,
                  child: const Text(AppStrings.searchButton),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (state is ApiLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(child: CircularProgressIndicator()),
              ),
            if (state is ApiError)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  (state as ApiError<TrendData>).message,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.error),
                ),
              ),
            if (data != null && data.points.isNotEmpty) ...[
              _StatsRow(data: data),
              const SizedBox(height: 12),
              SizedBox(height: 240, child: _TrendChart(data: data)),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    data.summary.isNotEmpty
                        ? data.summary
                        : data.localSummary(),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.data});
  final TrendData data;

  @override
  Widget build(BuildContext context) {
    final change = data.changePercent;
    final changeColor =
        change < 0 ? Colors.green : change > 0 ? Colors.red : Colors.grey;
    return Row(
      children: [
        _stat(context, 'Terendah', formatRupiah(data.min)),
        _stat(context, 'Tertinggi', formatRupiah(data.max)),
        _stat(context, 'Rata-rata', formatRupiah(data.avg.round())),
        _stat(
          context,
          'Perubahan',
          '${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)}%',
          valueColor: changeColor,
        ),
      ],
    );
  }

  Widget _stat(BuildContext context, String label, String value,
      {Color? valueColor}) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          child: Column(
            children: [
              Text(label,
                  style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(height: 4),
              Text(value,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: valueColor),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrendChart extends StatelessWidget {
  const _TrendChart({required this.data});
  final TrendData data;

  @override
  Widget build(BuildContext context) {
    final spots = data.points
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.price / 1e6))
        .toList();
    final minY = (data.min / 1e6 * 0.98).floorToDouble();
    final maxY = (data.max / 1e6 * 1.02).ceilToDouble();
    final dateFmt = DateFormat('d/M');

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
        child: LineChart(
          LineChartData(
            minY: minY,
            maxY: maxY,
            gridData: const FlGridData(show: true, drawVerticalLine: false),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 36,
                  getTitlesWidget: (v, _) => Text(
                    '${v.toStringAsFixed(1)}jt',
                    style: const TextStyle(fontSize: 10),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: (spots.length / 4).ceilToDouble(),
                  getTitlesWidget: (v, _) {
                    final i = v.toInt();
                    if (i < 0 || i >= data.points.length) {
                      return const SizedBox.shrink();
                    }
                    return Text(
                      dateFmt.format(data.points[i].date),
                      style: const TextStyle(fontSize: 10),
                    );
                  },
                ),
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                barWidth: 2.5,
                color: Theme.of(context).colorScheme.primary,
                belowBarData: BarAreaData(
                  show: true,
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.15),
                ),
                dotData: const FlDotData(show: false),
              ),
            ],
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipItems: (touched) => touched
                    .map((s) => LineTooltipItem(
                          '${dateFmt.format(data.points[s.x.toInt()].date)}\n'
                          '${formatRupiah((s.y * 1e6).round())}',
                          const TextStyle(fontWeight: FontWeight.bold),
                        ))
                    .toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
