import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../providers/app_state.dart';

/// Client-side scoring using the same v2 formula as the backend.
class HypotheticalScreen extends StatefulWidget {
  const HypotheticalScreen({super.key});

  @override
  State<HypotheticalScreen> createState() => _HypotheticalScreenState();
}

class _HypotheticalScreenState extends State<HypotheticalScreen> {
  String _businessType = 'Cafe';

  // 9 metrics
  double _incomeIndex = 60;
  double _footTraffic = 60;
  double _popDensity = 60;
  double _competition = 50;
  double _commercialRent = 50;
  double _accessibility = 30;
  double _growthTrend = 50;
  double _vacancy = 50;
  double _infrastructure = 50;

  // Clustering benefit factor by business type (mirrors backend)
  static const Map<String, double> _cbfMap = {
    'Cafe': 0.50,
    'Restaurant': 0.50,
    'Retail Store': 0.30,
    'Supermarket': 0.30,
    'Salon & Beauty': 0.30,
    'Hotel / Hospitality': 0.20,
    'Souvenir / Gift Shop': 0.35,
    'Gym / Fitness Centre': 0.15,
    'Pharmacy': 0.15,
    'Tech Office': 0.00,
    'Medical Clinic': 0.00,
    'Educational Institute': 0.00,
  };

  // Weight profiles by business type (demand, friction, growth triples)
  static const Map<String, List<List<double>>> _profiles = {
    'Tech Office': [
      [0.55, 0.15, 0.30],
      [0.20, 0.20, 0.60],
      [0.30, 0.20, 0.50],
    ],
    'Medical Clinic': [
      [0.40, 0.25, 0.35],
      [0.25, 0.30, 0.45],
      [0.35, 0.25, 0.40],
    ],
    'Educational Institute': [
      [0.45, 0.20, 0.35],
      [0.20, 0.25, 0.55],
      [0.35, 0.20, 0.45],
    ],
    'Restaurant': [
      [0.20, 0.50, 0.30],
      [0.50, 0.30, 0.20],
      [0.50, 0.30, 0.20],
    ],
    'Cafe': [
      [0.20, 0.35, 0.45],
      [0.50, 0.30, 0.20],
      [0.50, 0.30, 0.20],
    ],
    'Retail Store': [
      [0.25, 0.45, 0.30],
      [0.45, 0.35, 0.20],
      [0.50, 0.30, 0.20],
    ],
    'Supermarket': [
      [0.20, 0.40, 0.40],
      [0.40, 0.35, 0.25],
      [0.50, 0.30, 0.20],
    ],
    'Salon & Beauty': [
      [0.25, 0.45, 0.30],
      [0.45, 0.35, 0.20],
      [0.50, 0.30, 0.20],
    ],
    'Hotel / Hospitality': [
      [0.65, 0.25, 0.10],
      [0.15, 0.25, 0.60],
      [0.35, 0.25, 0.40],
    ],
    'Souvenir / Gift Shop': [
      [0.50, 0.40, 0.10],
      [0.30, 0.30, 0.40],
      [0.45, 0.30, 0.25],
    ],
    'Pharmacy': [
      [0.25, 0.30, 0.45],
      [0.35, 0.35, 0.30],
      [0.45, 0.30, 0.25],
    ],
    'Gym / Fitness Centre': [
      [0.45, 0.20, 0.35],
      [0.35, 0.35, 0.30],
      [0.45, 0.30, 0.25],
    ],
  };

  static const List<List<double>> _defaultProfile = [
    [0.30, 0.35, 0.35],
    [0.40, 0.35, 0.25],
    [0.50, 0.30, 0.20],
  ];

  Map<String, double> _calculate() {
    final cbf = _cbfMap[_businessType] ?? 0.15;
    final profile = _profiles[_businessType] ?? _defaultProfile;

    final inc = _incomeIndex / 100;
    final traf = _footTraffic / 100;
    final dens = _popDensity / 100;
    final comp = _competition / 100;
    final rent = _commercialRent / 100;
    final acc = _accessibility / 100;
    final grow = _growthTrend / 100;
    final vac = _vacancy / 100;
    final infra = _infrastructure / 100;

    final demand =
        profile[0][0] * inc + profile[0][1] * traf + profile[0][2] * dens;
    final adjComp = comp * (1.0 - cbf);
    final friction =
        profile[1][0] * adjComp + profile[1][1] * rent + profile[1][2] * acc;
    final growth =
        profile[2][0] * grow + profile[2][1] * vac + profile[2][2] * infra;

    final ls = (0.40 * demand) - (0.35 * friction) + (0.25 * growth);
    final displayScore = (ls * 100 * 10).roundToDouble() / 10; // round to 1 dp

    return {
      'score': displayScore,
      'demand': (demand * 1000).roundToDouble() / 10,
      'friction': (friction * 1000).roundToDouble() / 10,
      'growth': (growth * 1000).roundToDouble() / 10,
    };
  }

  Color _scoreColor(double score) {
    if (score >= 25) return AppColors.scoreHigh;
    if (score >= 15) return AppColors.scoreMedium;
    return AppColors.scoreLow;
  }

  @override
  Widget build(BuildContext context) {
    final result = _calculate();
    final score = result['score']!;
    final demand = result['demand']!;
    final friction = result['friction']!;
    final growth = result['growth']!;
    final color = _scoreColor(score);

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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App bar
                Row(
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
                            'Hypothetical Scorer',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          Text(
                            'Set custom parameters to check a score',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Score display
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: color, width: 4),
                      boxShadow: [
                        BoxShadow(color: color.withAlpha(50), blurRadius: 30),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          score.toStringAsFixed(1),
                          style: TextStyle(
                            color: color,
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'Score',
                          style: TextStyle(
                            color: color.withAlpha(150),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Sub-scores
                Row(
                  children: [
                    _pill(
                      'Demand',
                      demand.toStringAsFixed(1),
                      AppColors.scoreHigh,
                    ),
                    const SizedBox(width: 8),
                    _pill(
                      'Friction',
                      friction.toStringAsFixed(1),
                      AppColors.accent,
                    ),
                    const SizedBox(width: 8),
                    _pill(
                      'Growth',
                      growth.toStringAsFixed(1),
                      AppColors.secondary,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Business Type
                _label('Business Type'),
                const SizedBox(height: 8),
                Container(
                  decoration: glassCard(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _businessType,
                      isExpanded: true,
                      dropdownColor: AppColors.surface,
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.primary,
                      ),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      items: AppState.businessTypes.map((t) {
                        return DropdownMenuItem(value: t, child: Text(t));
                      }).toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _businessType = v);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Metric sliders
                _label('Demand Metrics'),
                const SizedBox(height: 8),
                _slider(
                  'Income Index',
                  _incomeIndex,
                  AppColors.primary,
                  (v) => setState(() => _incomeIndex = v),
                ),
                _slider(
                  'Foot Traffic',
                  _footTraffic,
                  AppColors.secondary,
                  (v) => setState(() => _footTraffic = v),
                ),
                _slider(
                  'Pop. Density',
                  _popDensity,
                  const Color(0xFF9C7CFF),
                  (v) => setState(() => _popDensity = v),
                ),

                const SizedBox(height: 16),
                _label('Friction Metrics'),
                const SizedBox(height: 8),
                _slider(
                  'Competition',
                  _competition,
                  AppColors.accent,
                  (v) => setState(() => _competition = v),
                ),
                _slider(
                  'Commercial Rent',
                  _commercialRent,
                  AppColors.scoreMedium,
                  (v) => setState(() => _commercialRent = v),
                ),
                _slider(
                  'Accessibility Penalty',
                  _accessibility,
                  const Color(0xFFFF8A65),
                  (v) => setState(() => _accessibility = v),
                ),

                const SizedBox(height: 16),
                _label('Growth Metrics'),
                const SizedBox(height: 8),
                _slider(
                  'Growth Trend',
                  _growthTrend,
                  const Color(0xFF4DD0E1),
                  (v) => setState(() => _growthTrend = v),
                ),
                _slider(
                  'Vacancy Improvement',
                  _vacancy,
                  const Color(0xFFAED581),
                  (v) => setState(() => _vacancy = v),
                ),
                _slider(
                  'Infrastructure',
                  _infrastructure,
                  const Color(0xFF81C784),
                  (v) => setState(() => _infrastructure = v),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _pill(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
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
                fontSize: 14,
              ),
            ),
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

  Widget _label(String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: AppColors.textSecondary,
        fontSize: 12,
        letterSpacing: 1,
      ),
    );
  }

  Widget _slider(
    String label,
    double value,
    Color color,
    ValueChanged<double> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${value.toInt()}',
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: color,
              inactiveTrackColor: AppColors.surfaceLight,
              thumbColor: color,
              overlayColor: color.withAlpha(30),
              trackHeight: 5,
            ),
            child: Slider(
              value: value,
              min: 0,
              max: 100,
              divisions: 100,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
