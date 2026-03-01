import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'theme/app_theme.dart';
import 'providers/app_state.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  runApp(const SiteScaprApp());
}

class SiteScaprApp extends StatelessWidget {
  const SiteScaprApp({super.key});

  @override
  Widget build(BuildContext context) {
    final publishableKey = dotenv.env['CLERK_PUBLISHABLE_KEY'] ?? '';

    return ClerkAuth(
      config: ClerkAuthConfig(publishableKey: publishableKey),
      child: ChangeNotifierProvider(
        create: (_) => AppState(),
        child: MaterialApp(
          title: 'SiteScapr',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark,
          home: const AuthGate(),
        ),
      ),
    );
  }
}

/// Routes to splash (→ app) if signed in, or shows Clerk sign-in/up if not.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return ClerkAuthBuilder(
      signedInBuilder: (context, authState) => const SplashScreen(),
      signedOutBuilder: (context, authState) => const _AuthScreen(),
    );
  }
}

/// Full-screen Clerk authentication (sign-in / sign-up).
class _AuthScreen extends StatelessWidget {
  const _AuthScreen();

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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              children: [
                const SizedBox(height: 40),
                // Logo
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withAlpha(80),
                        blurRadius: 30,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.location_on_rounded,
                    color: Colors.white,
                    size: 42,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Welcome to SiteScapr',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  'Sign in to find the best location for your business',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Clerk's built-in auth widget
                const ClerkErrorListener(child: ClerkAuthentication()),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
