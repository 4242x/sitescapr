import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import 'map_screen.dart';
import 'location_detail_screen.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Color _rankColor(int rank) {
    return switch (rank) {
      1 => const Color(0xFFFFD700),
      2 => const Color(0xFFC0C0C0),
      3 => const Color(0xFFCD7F32),
      _ => AppColors.primary,
    };
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
    final businessType = appState.response?.businessType ?? '';

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
          child: Column(
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
                      icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.surfaceLight,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Top Locations',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          Text(
                            'Best areas for your $businessType',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Stats bar ──
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                decoration: glassCard(opacity: 0.1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _statItem(
                      context,
                      '${appState.response?.totalAreasAnalyzed ?? 0}',
                      'Scanned',
                      Icons.radar_rounded,
                    ),
                    Container(
                      width: 1,
                      height: 30,
                      color: AppColors.cardBorder,
                    ),
                    _statItem(
                      context,
                      '${results.length}',
                      'Top Picks',
                      Icons.emoji_events_rounded,
                    ),
                    Container(
                      width: 1,
                      height: 30,
                      color: AppColors.cardBorder,
                    ),
                    _statItem(
                      context,
                      businessType,
                      'Business',
                      Icons.store_rounded,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ── Results list ──
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final area = results[index];
                    final delay = index * 0.15;
                    return _StaggeredItem(
                      animation: _animController,
                      delay: delay,
                      child: _buildLocationCard(context, area, index),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (_, a, b) => const MapScreen(),
              transitionsBuilder: (_, anim, a2, child) => SlideTransition(
                position:
                    Tween<Offset>(
                      begin: const Offset(0, 1),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
                    ),
                child: child,
              ),
              transitionDuration: const Duration(milliseconds: 400),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.map_rounded),
        label: const Text(
          'View on Map',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildLocationCard(BuildContext context, ScoredArea area, int index) {
    return GestureDetector(
      onTap: () {
        context.read<AppState>().selectLocation(index);
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (_, a, b) => const LocationDetailScreen(),
            transitionsBuilder: (_, anim, a2, child) => SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
                  ),
              child: child,
            ),
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: glassCard(),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: _rankColor(area.rank).withAlpha(30),
                          borderRadius: BorderRadius.circular(11),
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
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              area.name,
                              style: Theme.of(
                                context,
                              ).textTheme.titleLarge?.copyWith(fontSize: 16),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Kolkata, West Bengal',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _scoreColor(area.score),
                            width: 3,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              area.score.toStringAsFixed(1),
                              style: TextStyle(
                                color: _scoreColor(area.score),
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'score',
                              style: TextStyle(
                                color: _scoreColor(area.score).withAlpha(150),
                                fontSize: 7,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Sub-scores row
                  Row(
                    children: [
                      _subScorePill(
                        'Demand',
                        (area.demandScore * 100).toStringAsFixed(1),
                        AppColors.scoreHigh,
                      ),
                      const SizedBox(width: 8),
                      _subScorePill(
                        'Friction',
                        (area.frictionScore * 100).toStringAsFixed(1),
                        AppColors.accent,
                      ),
                      const SizedBox(width: 8),
                      _subScorePill(
                        'Growth',
                        (area.growthScore * 100).toStringAsFixed(1),
                        AppColors.secondary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Key metric bars
                  _miniMetricBar('Income', area.incomeIndex, AppColors.primary),
                  const SizedBox(height: 5),
                  _miniMetricBar(
                    'Traffic',
                    area.footTrafficProxy,
                    AppColors.secondary,
                  ),
                  const SizedBox(height: 5),
                  _miniMetricBar(
                    'Density',
                    area.populationDensityIndex,
                    const Color(0xFF9C7CFF),
                  ),
                  const SizedBox(height: 5),
                  _miniMetricBar(
                    'Competition',
                    area.competitionIndex,
                    AppColors.accent,
                  ),
                  const SizedBox(height: 5),
                  _miniMetricBar(
                    'Rent',
                    area.commercialRentIndex,
                    AppColors.scoreMedium,
                  ),
                  const SizedBox(height: 5),
                  _miniMetricBar(
                    'Access.',
                    area.accessibilityPenalty,
                    const Color(0xFFFF8A65),
                  ),
                  const SizedBox(height: 5),
                  _miniMetricBar(
                    'Growth Trend',
                    area.areaGrowthTrend,
                    const Color(0xFF4DD0E1),
                  ),
                  const SizedBox(height: 5),
                  _miniMetricBar(
                    'Infra.',
                    area.infrastructureInvestmentIndex,
                    const Color(0xFF81C784),
                  ),

                  const SizedBox(height: 12),
                  const Divider(color: AppColors.cardBorder, height: 1),
                  const SizedBox(height: 10),

                  // Insights
                  ...area.reasoning.map(
                    (bullet) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 6),
                            width: 5,
                            height: 5,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              bullet,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontSize: 12, height: 1.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 10,
              bottom: 10,
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 12,
                color: AppColors.textMuted.withAlpha(100),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _subScorePill(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withAlpha(50)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              label,
              style: TextStyle(
                color: color.withAlpha(180),
                fontSize: 9,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniMetricBar(String label, double value, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 76,
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              FractionallySizedBox(
                widthFactor: value / 100,
                child: Container(
                  height: 5,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        SizedBox(
          width: 24,
          child: Text(
            '${value.toInt()}',
            textAlign: TextAlign.right,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _statItem(
    BuildContext context,
    String value,
    String label,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 16),
        const SizedBox(height: 3),
        Text(
          value,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 13),
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 9),
        ),
      ],
    );
  }
}

class _StaggeredItem extends AnimatedWidget {
  final double delay;
  final Widget child;

  const _StaggeredItem({
    required Animation<double> animation,
    required this.delay,
    required this.child,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    final controller = listenable as Animation<double>;
    final progress = (controller.value - delay).clamp(0.0, 0.8) / 0.8;
    return Transform.translate(
      offset: Offset(0, 30 * (1 - progress)),
      child: Opacity(opacity: progress, child: child),
    );
  }
}
