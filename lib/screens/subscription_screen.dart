import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

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
                    Text(
                      'Choose Your Plan',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Start free, upgrade when you need more. No hidden fees.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),

                // ── Free tier ──
                _TierCard(
                  name: 'Free',
                  price: '₹0',
                  period: 'forever',
                  description: 'Try SiteScapr with no commitment.',
                  features: const [
                    '2 top-ranked results per analysis',
                    'Basic neighborhood scores',
                    'Map visualization',
                    'Kolkata coverage',
                  ],
                  cta: 'Get Started',
                  highlighted: false,
                  onTap: () => _showDummy(context),
                ),
                const SizedBox(height: 16),

                // ── Pro tier ──
                _TierCard(
                  name: 'Pro',
                  price: '₹999',
                  period: 'per month',
                  description:
                      'Everything you need to make a confident site decision.',
                  features: const [
                    'All ranked results (unlimited)',
                    'Full breakdown of all scoring metrics',
                    'AI reasoning per neighborhood',
                    'Export results as CSV / PDF',
                    'Save & compare locations',
                    'Priority support',
                  ],
                  cta: 'Start Free Trial',
                  highlighted: true,
                  onTap: () => _showDummy(context),
                ),
                const SizedBox(height: 16),

                // ── Enterprise tier ──
                _TierCard(
                  name: 'Enterprise',
                  price: 'Custom',
                  period: 'contact us',
                  description: 'For teams and multi-city rollouts.',
                  features: const [
                    'Everything in Pro',
                    'Multi-city analysis',
                    'Custom data integrations',
                    'Dedicated account manager',
                    'SLA & white-label options',
                  ],
                  cta: 'Contact Sales',
                  highlighted: false,
                  onTap: () => _showDummy(context),
                ),

                const SizedBox(height: 20),
                Text(
                  'All prices in INR. Pro tier includes a 7-day free trial.\nCancel anytime. Payment integration coming soon.',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDummy(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Payment integration coming soon!'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _TierCard extends StatelessWidget {
  final String name;
  final String price;
  final String period;
  final String description;
  final List<String> features;
  final String cta;
  final bool highlighted;
  final VoidCallback onTap;

  const _TierCard({
    required this.name,
    required this.price,
    required this.period,
    required this.description,
    required this.features,
    required this.cta,
    required this.highlighted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: highlighted ? AppColors.primaryGradient : null,
        color: highlighted ? null : AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: highlighted ? null : Border.all(color: AppColors.cardBorder),
        boxShadow: highlighted
            ? [
                BoxShadow(
                  color: AppColors.primary.withAlpha(40),
                  blurRadius: 30,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge
          if (highlighted)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(30),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'MOST POPULAR',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ),

          // Name
          Text(
            name,
            style: TextStyle(
              color: highlighted
                  ? Colors.white.withAlpha(200)
                  : AppColors.textMuted,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),

          // Price
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: TextStyle(
                  color: highlighted ? Colors.white : AppColors.textPrimary,
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  '/ $period',
                  style: TextStyle(
                    color: highlighted
                        ? Colors.white.withAlpha(150)
                        : AppColors.textMuted,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: TextStyle(
              color: highlighted
                  ? Colors.white.withAlpha(180)
                  : AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 18),

          // Features
          ...features.map(
            (f) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: 16,
                    color: highlighted
                        ? Colors.white.withAlpha(220)
                        : AppColors.secondary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      f,
                      style: TextStyle(
                        color: highlighted
                            ? Colors.white.withAlpha(220)
                            : AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // CTA
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: highlighted ? Colors.white : AppColors.primary,
                foregroundColor: highlighted ? AppColors.primary : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                cta,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
