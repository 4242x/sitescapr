import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();

  Color _scoreColor(double score) {
    if (score >= 40) return AppColors.scoreHigh;
    if (score >= 25) return AppColors.scoreMedium;
    return AppColors.scoreLow;
  }

  Color _rankColor(int rank) {
    return switch (rank) {
      1 => const Color(0xFFFFD700),
      2 => const Color(0xFFC0C0C0),
      3 => const Color(0xFFCD7F32),
      _ => AppColors.textMuted,
    };
  }

  void _showAreaBottomSheet(BuildContext context, ScoredArea area) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.surface,
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
                  color: AppColors.cardBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _rankColor(area.rank).withAlpha(30),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _rankColor(area.rank).withAlpha(80),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '#${area.rank}',
                    style: TextStyle(
                      color: _rankColor(area.rank),
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        area.name,
                        style: Theme.of(
                          context,
                        ).textTheme.titleLarge?.copyWith(fontSize: 18),
                      ),
                      Text(
                        'Score: ${area.score.toStringAsFixed(1)}',
                        style: TextStyle(
                          color: _scoreColor(area.score),
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            // Quick metrics row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _quickMetric('Income', area.incomeIndex, AppColors.primary),
                _quickMetric(
                  'Traffic',
                  area.footTrafficProxy,
                  AppColors.secondary,
                ),
                _quickMetric(
                  'Density',
                  area.populationDensityIndex,
                  const Color(0xFF9C7CFF),
                ),
                _quickMetric('Comp.', area.competitionIndex, AppColors.accent),
                _quickMetric(
                  'Rent',
                  area.commercialRentIndex,
                  AppColors.scoreMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _quickMetric(String label, double value, Color color) {
    return Column(
      children: [
        Text(
          '${value.toInt()}',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final results = appState.topResults;

    // Kolkata center
    const kolkataCenter = LatLng(22.5547, 88.3697);

    return Scaffold(
      body: Stack(
        children: [
          // ── Map ──
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: kolkataCenter,
              initialZoom: 12.0,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.sitescapr.app',
              ),

              // Heatmap-like circles (larger, more transparent)
              CircleLayer(
                circles: results.map((area) {
                  final color = _scoreColor(area.score);
                  return CircleMarker(
                    point: LatLng(area.latitude, area.longitude),
                    radius: 60,
                    color: color.withAlpha(30),
                    borderColor: color.withAlpha(50),
                    borderStrokeWidth: 1,
                  );
                }).toList(),
              ),

              // Inner glow circles
              CircleLayer(
                circles: results.map((area) {
                  final color = _scoreColor(area.score);
                  return CircleMarker(
                    point: LatLng(area.latitude, area.longitude),
                    radius: 30,
                    color: color.withAlpha(50),
                    borderColor: color.withAlpha(80),
                    borderStrokeWidth: 1.5,
                  );
                }).toList(),
              ),

              // Markers
              MarkerLayer(
                markers: results.map((area) {
                  final color = _scoreColor(area.score);
                  return Marker(
                    point: LatLng(area.latitude, area.longitude),
                    width: 56,
                    height: 56,
                    child: GestureDetector(
                      onTap: () => _showAreaBottomSheet(context, area),
                      child: Container(
                        decoration: BoxDecoration(
                          color: color.withAlpha(40),
                          shape: BoxShape.circle,
                          border: Border.all(color: color, width: 2.5),
                          boxShadow: [
                            BoxShadow(
                              color: color.withAlpha(80),
                              blurRadius: 16,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '#${area.rank}',
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          // ── Top bar ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                16,
                MediaQuery.of(context).padding.top + 8,
                16,
                14,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.background.withAlpha(240),
                    AppColors.background.withAlpha(0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.surfaceLight.withAlpha(200),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Location Map',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
            ),
          ),

          // ── Legend ──
          Positioned(
            bottom: 24,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surface.withAlpha(230),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _LegendDot(color: AppColors.scoreHigh, label: 'High'),
                  SizedBox(width: 14),
                  _LegendDot(color: AppColors.scoreMedium, label: 'Mid'),
                  SizedBox(width: 14),
                  _LegendDot(color: AppColors.scoreLow, label: 'Low'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
