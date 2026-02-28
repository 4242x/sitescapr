import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

class LocationDetailScreen extends StatefulWidget {
  const LocationDetailScreen({super.key});

  @override
  State<LocationDetailScreen> createState() => _LocationDetailScreenState();
}

class _LocationDetailScreenState extends State<LocationDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Color _scoreColor(double score) {
    if (score >= 25) return AppColors.scoreHigh;
    if (score >= 15) return AppColors.scoreMedium;
    return AppColors.scoreLow;
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final results = appState.topResults;
    if (results.isEmpty) return const SizedBox.shrink();

    final area =
        results[appState.selectedLocationIndex.clamp(0, results.length - 1)];
    final scoreColor = _scoreColor(area.score);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.background, Color(0xFFE8EAF0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── App bar ──
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.arrow_back_ios_rounded,
                          size: 20,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.surfaceLight,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          area.name,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Rank #${area.rank}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Score gauge ──
                _AnimatedGauge(
                  animation: _animController,
                  score: area.score,
                  color: scoreColor,
                ),

                // ── Sub-scores row ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      _subScoreCard(
                        'Demand',
                        (area.demandScore * 100).toStringAsFixed(1),
                        AppColors.scoreHigh,
                      ),
                      const SizedBox(width: 10),
                      _subScoreCard(
                        'Friction',
                        (area.frictionScore * 100).toStringAsFixed(1),
                        AppColors.accent,
                      ),
                      const SizedBox(width: 10),
                      _subScoreCard(
                        'Growth',
                        (area.growthScore * 100).toStringAsFixed(1),
                        AppColors.secondary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── All 9 metric bars ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: glassCard(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Metric Breakdown',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 18),
                        _animatedBar(
                          'Income Index',
                          area.incomeIndex,
                          AppColors.primary,
                          Icons.account_balance_wallet_rounded,
                        ),
                        const SizedBox(height: 12),
                        _animatedBar(
                          'Foot Traffic',
                          area.footTrafficProxy,
                          AppColors.secondary,
                          Icons.directions_walk_rounded,
                        ),
                        const SizedBox(height: 12),
                        _animatedBar(
                          'Pop. Density',
                          area.populationDensityIndex,
                          const Color(0xFF9C7CFF),
                          Icons.people_rounded,
                        ),
                        const SizedBox(height: 12),
                        _animatedBar(
                          'Competition',
                          area.competitionIndex,
                          AppColors.accent,
                          Icons.storefront_rounded,
                        ),
                        const SizedBox(height: 12),
                        _animatedBar(
                          'Rent Index',
                          area.commercialRentIndex,
                          AppColors.scoreMedium,
                          Icons.real_estate_agent_rounded,
                        ),
                        const SizedBox(height: 12),
                        _animatedBar(
                          'Accessibility Penalty',
                          area.accessibilityPenalty,
                          const Color(0xFFFF8A65),
                          Icons.directions_bus_rounded,
                        ),
                        const SizedBox(height: 12),
                        _animatedBar(
                          'Growth Trend',
                          area.areaGrowthTrend,
                          const Color(0xFF4DD0E1),
                          Icons.trending_up_rounded,
                        ),
                        const SizedBox(height: 12),
                        _animatedBar(
                          'Vacancy Improvement',
                          area.vacancyRateImprovement,
                          const Color(0xFFAED581),
                          Icons.business_rounded,
                        ),
                        const SizedBox(height: 12),
                        _animatedBar(
                          'Infrastructure',
                          area.infrastructureInvestmentIndex,
                          const Color(0xFF81C784),
                          Icons.construction_rounded,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ── Radar chart ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: glassCard(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Performance Radar',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 240,
                          child: RadarChart(
                            RadarChartData(
                              radarShape: RadarShape.polygon,
                              tickCount: 4,
                              ticksTextStyle: const TextStyle(
                                fontSize: 0,
                                color: Colors.transparent,
                              ),
                              tickBorderData: BorderSide(
                                color: AppColors.cardBorder.withAlpha(60),
                              ),
                              gridBorderData: BorderSide(
                                color: AppColors.cardBorder.withAlpha(80),
                                width: 1,
                              ),
                              radarBorderData: const BorderSide(
                                color: Colors.transparent,
                              ),
                              titleTextStyle: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 9,
                                fontWeight: FontWeight.w500,
                              ),
                              getTitle: (index, _) => RadarChartTitle(
                                text: const [
                                  'Income',
                                  'Traffic',
                                  'Density',
                                  'Comp.',
                                  'Rent',
                                  'Access.',
                                  'Growth',
                                  'Vacancy',
                                  'Infra.',
                                ][index],
                              ),
                              dataSets: [
                                RadarDataSet(
                                  fillColor: AppColors.primary.withAlpha(35),
                                  borderColor: AppColors.primary,
                                  borderWidth: 2,
                                  entryRadius: 3,
                                  dataEntries: [
                                    RadarEntry(value: area.incomeIndex),
                                    RadarEntry(value: area.footTrafficProxy),
                                    RadarEntry(
                                      value: area.populationDensityIndex,
                                    ),
                                    RadarEntry(value: area.competitionIndex),
                                    RadarEntry(value: area.commercialRentIndex),
                                    RadarEntry(
                                      value: area.accessibilityPenalty,
                                    ),
                                    RadarEntry(value: area.areaGrowthTrend),
                                    RadarEntry(
                                      value: area.vacancyRateImprovement,
                                    ),
                                    RadarEntry(
                                      value: area.infrastructureInvestmentIndex,
                                    ),
                                  ],
                                ),
                              ],
                              titlePositionPercentageOffset: 0.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ── Insights ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: glassCard(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.lightbulb_rounded,
                              color: AppColors.scoreMedium,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Key Insights',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        ...area.reasoning.asMap().entries.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withAlpha(30),
                                    borderRadius: BorderRadius.circular(7),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '${entry.key + 1}',
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    entry.value,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(height: 1.5),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ── Mini map ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    height: 180,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: LatLng(area.latitude, area.longitude),
                        initialZoom: 14.0,
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.none,
                        ),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
                          subdomains: const ['a', 'b', 'c', 'd'],
                          userAgentPackageName: 'com.sitescapr.app',
                        ),
                        CircleLayer(
                          circles: [
                            CircleMarker(
                              point: LatLng(area.latitude, area.longitude),
                              radius: 40,
                              color: scoreColor.withAlpha(30),
                              borderColor: scoreColor.withAlpha(60),
                              borderStrokeWidth: 1.5,
                            ),
                          ],
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(area.latitude, area.longitude),
                              width: 40,
                              height: 40,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: scoreColor.withAlpha(50),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: scoreColor,
                                    width: 2.5,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.location_on_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _subScoreCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: glassCard(),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color.withAlpha(180),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _animatedBar(String label, double value, Color color, IconData icon) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        final progress = CurvedAnimation(
          parent: _animController,
          curve: Curves.easeOutCubic,
        ).value;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 15),
                const SizedBox(width: 7),
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Text(
                  '${(value * progress).toInt()}/100',
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Stack(
              children: [
                Container(
                  height: 7,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: (value / 100) * progress,
                  child: Container(
                    height: 7,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color.withAlpha(180), color],
                      ),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(color: color.withAlpha(50), blurRadius: 6),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _AnimatedGauge extends AnimatedWidget {
  final double score;
  final Color color;

  const _AnimatedGauge({
    required Animation<double> animation,
    required this.score,
    required this.color,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    final progress = CurvedAnimation(
      parent: listenable as Animation<double>,
      curve: Curves.easeOutCubic,
    ).value;
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
        width: 130,
        height: 130,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 130,
              height: 130,
              child: CircularProgressIndicator(
                value: (score / 40).clamp(0, 1) * progress,
                strokeWidth: 9,
                strokeCap: StrokeCap.round,
                backgroundColor: AppColors.surfaceLight,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  (score * progress).toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                Text(
                  'Final Score',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: color.withAlpha(150),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext, Widget?) builder;
  final Widget? child;

  const AnimatedBuilder({
    super.key,
    required Animation<double> animation,
    required this.builder,
    this.child,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    return builder(context, child);
  }
}
