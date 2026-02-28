import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import 'results_screen.dart';
import 'hypothetical_screen.dart';
import 'subscription_screen.dart';
import 'server_status_screen.dart';
import 'methodology_screen.dart';

class InputFormScreen extends StatefulWidget {
  const InputFormScreen({super.key});

  @override
  State<InputFormScreen> createState() => _InputFormScreenState();
}

class _InputFormScreenState extends State<InputFormScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _slideAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  String _formatBudget(int value) {
    if (value >= 100000) {
      final lakhs = value / 100000;
      return '₹${lakhs.toStringAsFixed(lakhs == lakhs.roundToDouble() ? 0 : 1)}L';
    }
    return '₹${(value / 1000).toStringAsFixed(0)}K';
  }

  IconData _businessIcon(String type) {
    return switch (type) {
      'Cafe' => Icons.coffee_rounded,
      'Restaurant' => Icons.restaurant_rounded,
      'Retail Store' => Icons.store_rounded,
      'Supermarket' => Icons.shopping_cart_rounded,
      'Salon & Beauty' => Icons.content_cut_rounded,
      'Hotel / Hospitality' => Icons.hotel_rounded,
      'Souvenir / Gift Shop' => Icons.card_giftcard_rounded,
      'Gym / Fitness Centre' => Icons.fitness_center_rounded,
      'Pharmacy' => Icons.local_pharmacy_rounded,
      'Tech Office' => Icons.computer_rounded,
      'Medical Clinic' => Icons.local_hospital_rounded,
      'Educational Institute' => Icons.school_rounded,
      _ => Icons.store_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      drawer: _buildDrawer(context),
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
          child: FadeTransition(
            opacity: _slideAnim,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.08),
                end: Offset.zero,
              ).animate(_slideAnim),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    // Header with menu
                    Row(
                      children: [
                        Builder(
                          builder: (ctx) => IconButton(
                            onPressed: () => Scaffold.of(ctx).openDrawer(),
                            icon: const Icon(Icons.menu_rounded, size: 24),
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.surfaceLight,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.location_on_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Text(
                          'SiteScapr',
                          style: Theme.of(
                            context,
                          ).textTheme.headlineMedium?.copyWith(fontSize: 26),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Find the perfect location for your business',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 28),

                    // ── Business Type ──
                    _sectionLabel('Business Type'),
                    const SizedBox(height: 10),
                    Container(
                      decoration: glassCard(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: appState.businessType,
                          isExpanded: true,
                          dropdownColor: AppColors.surface,
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: AppColors.primary,
                          ),
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: AppColors.textPrimary),
                          items: AppState.businessTypes.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Row(
                                children: [
                                  Icon(
                                    _businessIcon(type),
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(type),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) appState.setBusinessType(val);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ── Target Demographic ──
                    _sectionLabel('Target Demographic'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: AppState.demographics.map((demo) {
                        final selected = appState.selectedDemographics.contains(
                          demo,
                        );
                        return GestureDetector(
                          onTap: () => appState.toggleDemographic(demo),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              gradient: selected
                                  ? AppColors.primaryGradient
                                  : null,
                              color: selected ? null : AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: selected
                                    ? Colors.transparent
                                    : AppColors.cardBorder,
                              ),
                              boxShadow: selected
                                  ? [
                                      BoxShadow(
                                        color: AppColors.primary.withAlpha(60),
                                        blurRadius: 12,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  selected
                                      ? Icons.check_circle_rounded
                                      : Icons.circle_outlined,
                                  size: 18,
                                  color: selected
                                      ? Colors.white
                                      : AppColors.textMuted,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  demo,
                                  style: TextStyle(
                                    color: selected
                                        ? Colors.white
                                        : AppColors.textSecondary,
                                    fontWeight: selected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 28),

                    // ── Budget Range ──
                    _sectionLabel('Monthly Budget'),
                    const SizedBox(height: 6),
                    Container(
                      decoration: glassCard(),
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatBudget(appState.budgetRange),
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                              Text(
                                '/month',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Slider(
                            value: appState.budgetRange.toDouble(),
                            min: 50000,
                            max: 500000,
                            divisions: 18,
                            onChanged: (val) =>
                                appState.setBudgetRange(val.round()),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '₹50K',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(
                                '₹5L',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 36),

                    // ── Analyze Button ──
                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: ElevatedButton(
                        onPressed: appState.status == AppStatus.loading
                            ? null
                            : () async {
                                await appState.analyzeLocations();
                                if (context.mounted &&
                                    appState.status == AppStatus.success) {
                                  Navigator.of(context).push(
                                    PageRouteBuilder(
                                      pageBuilder: (_, a, b) =>
                                          const ResultsScreen(),
                                      transitionsBuilder:
                                          (_, anim, a2, child) =>
                                              SlideTransition(
                                                position:
                                                    Tween<Offset>(
                                                      begin: const Offset(1, 0),
                                                      end: Offset.zero,
                                                    ).animate(
                                                      CurvedAnimation(
                                                        parent: anim,
                                                        curve:
                                                            Curves.easeOutCubic,
                                                      ),
                                                    ),
                                                child: child,
                                              ),
                                      transitionDuration: const Duration(
                                        milliseconds: 400,
                                      ),
                                    ),
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            child: appState.status == AppStatus.loading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.auto_awesome_rounded,
                                        size: 22,
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        'Analyze Locations',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ),

                    // ── Error message ──
                    if (appState.status == AppStatus.error &&
                        appState.errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.scoreLow.withAlpha(25),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.scoreLow.withAlpha(70),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              color: AppColors.scoreLow,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                appState.errorMessage!,
                                style: const TextStyle(
                                  color: AppColors.scoreLow,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: AppColors.textSecondary,
        fontSize: 13,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.location_on_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'SiteScapr',
                    style: Theme.of(
                      context,
                    ).textTheme.headlineSmall?.copyWith(fontSize: 20),
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.cardBorder, height: 1),
            const SizedBox(height: 8),

            _drawerItem(Icons.search_rounded, 'Analyze', () {
              Navigator.of(context).pop();
            }),
            _drawerItem(Icons.tune_rounded, 'Hypothetical Scorer', () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const HypotheticalScreen()),
              );
            }),
            _drawerItem(Icons.workspace_premium_rounded, 'Subscriptions', () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
              );
            }),
            _drawerItem(Icons.science_rounded, 'Methodology', () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MethodologyScreen()),
              );
            }),
            _drawerItem(Icons.dns_rounded, 'Server Status', () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ServerStatusScreen()),
              );
            }),

            const Spacer(),
            const Divider(color: AppColors.cardBorder, height: 1),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'SiteScapr v2.0',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 22),
      title: Text(
        label,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
