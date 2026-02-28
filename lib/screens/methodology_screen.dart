import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MethodologyScreen extends StatelessWidget {
  const MethodologyScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                            'Methodology',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          Text(
                            'How SiteScapr scores locations',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Overview ──
                _SectionCard(
                  icon: Icons.auto_awesome_rounded,
                  title: 'Scoring Formula (v2)',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _formulaBox(
                        'Location Score (LS)',
                        '(Demand × 0.40) − (Friction × 0.35) + (Growth × 0.25)',
                        AppColors.primary,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'All sub-index inputs are normalised to 0–1 before applying weights. '
                        'Final score is displayed on a 0–100 scale.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.6,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Demand Score ──
                _SectionCard(
                  icon: Icons.trending_up_rounded,
                  title: 'Demand Score',
                  color: AppColors.scoreHigh,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _formulaBox(
                        'Demand',
                        '(w₁ × income) + (w₂ × foot_traffic) + (w₃ × pop_density)',
                        AppColors.scoreHigh,
                      ),
                      const SizedBox(height: 12),
                      _metricTile(
                        'Income Index',
                        'Average disposable income level in the area (0–100).',
                        Icons.account_balance_wallet_rounded,
                      ),
                      _metricTile(
                        'Foot Traffic Proxy',
                        'Estimated daily commercial footfall from transit, workplaces, and attractions (0–100).',
                        Icons.directions_walk_rounded,
                      ),
                      _metricTile(
                        'Population Density Index',
                        'Resident population density — higher means more potential customers nearby (0–100).',
                        Icons.people_rounded,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Friction Score ──
                _SectionCard(
                  icon: Icons.block_rounded,
                  title: 'Friction Score',
                  color: AppColors.accent,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _formulaBox(
                        'Friction',
                        '(w₄ × adj_competition) + (w₅ × rent) + (w₆ × accessibility)',
                        AppColors.accent,
                      ),
                      const SizedBox(height: 6),
                      _formulaBox(
                        'Adj. Competition',
                        'competition × (1 − clustering_benefit_factor)',
                        AppColors.accent.withAlpha(180),
                      ),
                      const SizedBox(height: 12),
                      _metricTile(
                        'Competition Index',
                        'Saturation of similar businesses — higher means more competition (0–100).',
                        Icons.storefront_rounded,
                      ),
                      _metricTile(
                        'Commercial Rent Index',
                        'Market rent level for commercial space (0–100). Index 100 ≈ ₹3,00,000/month.',
                        Icons.real_estate_agent_rounded,
                      ),
                      _metricTile(
                        'Accessibility Penalty',
                        'How hard the area is to reach — higher penalty = worse connectivity (0–100).',
                        Icons.directions_bus_rounded,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Growth Score ──
                _SectionCard(
                  icon: Icons.rocket_launch_rounded,
                  title: 'Growth Score',
                  color: AppColors.secondary,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _formulaBox(
                        'Growth',
                        '(w₇ × area_trend) + (w₈ × vacancy) + (w₉ × infrastructure)',
                        AppColors.secondary,
                      ),
                      const SizedBox(height: 12),
                      _metricTile(
                        'Area Growth Trend',
                        'How rapidly the area is developing — new commercial activity, rising property values (0–100).',
                        Icons.trending_up_rounded,
                      ),
                      _metricTile(
                        'Vacancy Rate Improvement',
                        'Rate at which commercial vacancies are being filled — higher = healthier market (0–100).',
                        Icons.business_rounded,
                      ),
                      _metricTile(
                        'Infrastructure Investment',
                        'Ongoing government/private infrastructure projects — metro, roads, tech parks (0–100).',
                        Icons.construction_rounded,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Clustering ──
                _SectionCard(
                  icon: Icons.hub_rounded,
                  title: 'Clustering Benefit',
                  color: const Color(0xFF9C7CFF),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Some businesses benefit from being near competitors (e.g. restaurant streets). '
                        'The clustering benefit factor reduces the effective competition penalty.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.6,
                          fontSize: 12.5,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _clusterRow('Restaurant / Café', '0.50', 'High'),
                      _clusterRow('Souvenir / Gift Shop', '0.35', 'High'),
                      _clusterRow(
                        'Retail / Supermarket / Salon',
                        '0.30',
                        'Medium',
                      ),
                      _clusterRow('Hotel / Hospitality', '0.20', 'Medium'),
                      _clusterRow('Gym / Pharmacy', '0.15', 'Low-Med'),
                      _clusterRow(
                        'Tech Office / Clinic / Edu.',
                        '0.00',
                        'None',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Weight profiles ──
                _SectionCard(
                  icon: Icons.tune_rounded,
                  title: 'Business-Type Weight Profiles',
                  color: AppColors.scoreMedium,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Each business type uses a custom weight profile that adjusts how much each '
                        'sub-score component matters. For example, a restaurant weights foot traffic '
                        'heavily in demand, while a tech office prioritizes income and infrastructure.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.6,
                          fontSize: 12.5,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            _profileRow(
                              '',
                              'Inc',
                              'Traf',
                              'Dens',
                              isHeader: true,
                            ),
                            const Divider(
                              color: AppColors.cardBorder,
                              height: 12,
                            ),
                            _profileRow('Restaurant', '0.20', '0.50', '0.30'),
                            _profileRow('Café', '0.20', '0.35', '0.45'),
                            _profileRow('Tech Office', '0.55', '0.15', '0.30'),
                            _profileRow('Pharmacy', '0.25', '0.30', '0.45'),
                            _profileRow('Hotel', '0.65', '0.25', '0.10'),
                            _profileRow('Gym', '0.45', '0.20', '0.35'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Shown: demand sub-weights for selected types. '
                        'Friction and Growth weights also vary per type.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Budget filter ──
                _SectionCard(
                  icon: Icons.filter_alt_rounded,
                  title: 'Budget Filter',
                  color: const Color(0xFF4DD0E1),
                  child: Text(
                    'Areas are excluded if their estimated monthly rent exceeds 1.5× your stated budget. '
                    'Rent Index 100 ≈ ₹3,00,000/month. This gives a comfortable negotiation margin '
                    'while filtering out genuinely unaffordable locations.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.6,
                      fontSize: 12.5,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Data coverage ──
                _SectionCard(
                  icon: Icons.map_rounded,
                  title: 'Data Coverage',
                  color: const Color(0xFF81C784),
                  child: Text(
                    '15 Kolkata neighborhoods analyzed: Park Street, New Town, Salt Lake Sector V, '
                    'Behala, Ballygunge, Shyambazar, Esplanade, Gariahat, Rajarhat, Jadavpur, '
                    'Alipore, Tollygunge, Dum Dum, Kasba, and Howrah. '
                    'Indices are compiled from census data, commercial real-estate reports, '
                    'transit authority stats, and municipal investment records.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.6,
                      fontSize: 12.5,
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

  Widget _formulaBox(String label, String formula, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            formula,
            style: TextStyle(
              color: color.withAlpha(220),
              fontWeight: FontWeight.w500,
              fontSize: 13,
              fontFamily: 'monospace',
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricTile(String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.textMuted, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 12.5, height: 1.5),
                children: [
                  TextSpan(
                    text: '$title — ',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text: description,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _clusterRow(String type, String factor, String level) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Text(
              type,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
          SizedBox(
            width: 40,
            child: Text(
              factor,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              level,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileRow(
    String type,
    String v1,
    String v2,
    String v3, {
    bool isHeader = false,
  }) {
    final style = TextStyle(
      color: isHeader ? AppColors.textMuted : AppColors.textSecondary,
      fontSize: 11,
      fontWeight: isHeader ? FontWeight.w600 : FontWeight.w400,
      fontFamily: isHeader ? null : 'monospace',
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              type,
              style: TextStyle(
                color: isHeader ? AppColors.textMuted : AppColors.textPrimary,
                fontSize: 11,
                fontWeight: isHeader ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
          SizedBox(
            width: 40,
            child: Text(v1, textAlign: TextAlign.center, style: style),
          ),
          SizedBox(
            width: 40,
            child: Text(v2, textAlign: TextAlign.center, style: style),
          ),
          SizedBox(
            width: 40,
            child: Text(v3, textAlign: TextAlign.center, style: style),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.title,
    this.color = AppColors.primary,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: glassCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}
