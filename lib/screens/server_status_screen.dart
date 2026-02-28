import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class ServerStatusScreen extends StatefulWidget {
  const ServerStatusScreen({super.key});

  @override
  State<ServerStatusScreen> createState() => _ServerStatusScreenState();
}

class _ServerStatusScreenState extends State<ServerStatusScreen>
    with SingleTickerProviderStateMixin {
  bool? _isOnline;
  String _message = 'Checking...';
  int _latencyMs = 0;
  Timer? _timer;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _checkStatus();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => _checkStatus());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _checkStatus() async {
    final stopwatch = Stopwatch()..start();
    try {
      final response = await http
          .get(Uri.parse(ApiService.baseUrl))
          .timeout(const Duration(seconds: 5));
      stopwatch.stop();
      if (mounted) {
        setState(() {
          _isOnline = response.statusCode == 200;
          _latencyMs = stopwatch.elapsedMilliseconds;
          _message = _isOnline!
              ? 'SiteScapr API is running'
              : 'Server returned status ${response.statusCode}';
        });
      }
    } catch (e) {
      stopwatch.stop();
      if (mounted) {
        setState(() {
          _isOnline = false;
          _latencyMs = 0;
          _message = 'Cannot connect to server.\n$e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _isOnline == null
        ? AppColors.textMuted
        : _isOnline!
        ? AppColors.scoreHigh
        : AppColors.scoreLow;

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
              // App bar
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
                    Text(
                      'Server Status',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Pulsing indicator
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  final scale = 1.0 + _pulseController.value * 0.15;
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color.withAlpha(20),
                        border: Border.all(color: color, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: color.withAlpha(40),
                            blurRadius: 40,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        _isOnline == null
                            ? Icons.hourglass_top_rounded
                            : _isOnline!
                            ? Icons.check_circle_rounded
                            : Icons.error_rounded,
                        color: color,
                        size: 52,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 28),
              Text(
                _isOnline == null
                    ? 'Checking...'
                    : _isOnline!
                    ? 'Server Online'
                    : 'Server Offline',
                style: TextStyle(
                  color: color,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  _message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              if (_isOnline == true) ...[
                const SizedBox(height: 10),
                Text(
                  'Latency: ${_latencyMs}ms',
                  style: TextStyle(
                    color: _latencyMs < 200
                        ? AppColors.scoreHigh
                        : _latencyMs < 500
                        ? AppColors.scoreMedium
                        : AppColors.scoreLow,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Text(
                'Auto-refreshes every 10 seconds',
                style: Theme.of(context).textTheme.bodySmall,
              ),

              const SizedBox(height: 28),

              // Backend URL
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                padding: const EdgeInsets.all(14),
                decoration: glassCard(opacity: 0.1),
                child: Row(
                  children: [
                    const Icon(
                      Icons.dns_rounded,
                      color: AppColors.textMuted,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        ApiService.baseUrl,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Manual refresh
              ElevatedButton.icon(
                onPressed: _checkStatus,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Check Now'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),

              const Spacer(),
            ],
          ),
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
