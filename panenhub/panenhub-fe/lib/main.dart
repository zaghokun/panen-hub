import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app/theme/app_theme.dart';
import 'features/splash/splash_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/register_screen.dart';
import 'features/home/customer_home_shell.dart';
import 'features/home/farmer_home_shell.dart';
import 'features/home/admin_home_shell.dart';
import 'providers/app_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(const ProviderScope(child: PanenHubApp()));
}

class PanenHubApp extends StatelessWidget {
  const PanenHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PanenHub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const _SplashWrapper());
          case '/onboarding':
            return MaterialPageRoute(builder: (_) => const _OnboardingWrapper());
          case '/login':
            return MaterialPageRoute(builder: (_) => const _LoginWrapper());
          case '/register':
            return MaterialPageRoute(builder: (_) => const _RegisterWrapper());
          case '/customer/home':
            return MaterialPageRoute(builder: (_) => const _ResetNavWrapper(child: CustomerHomeShell()));
          case '/farmer/home':
            return MaterialPageRoute(builder: (_) => const _ResetNavWrapper(child: FarmerHomeShell()));
          case '/admin/home':
            return MaterialPageRoute(builder: (_) => const _ResetNavWrapper(child: AdminHomeShell()));
          default:
            return MaterialPageRoute(builder: (_) => const _SplashWrapper());
        }
      },
    );
  }
}

class _ResetNavWrapper extends ConsumerStatefulWidget {
  final Widget child;
  const _ResetNavWrapper({required this.child});

  @override
  ConsumerState<_ResetNavWrapper> createState() => _ResetNavWrapperState();
}

class _ResetNavWrapperState extends ConsumerState<_ResetNavWrapper> {
  @override
  void initState() {
    super.initState();
    // Reset bottom nav index only once when entering a home shell
    Future.microtask(() {
      ref.read(bottomNavIndexProvider.notifier).state = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class _SplashWrapper extends StatelessWidget {
  const _SplashWrapper();

  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      onNavigateToLogin: () => Navigator.of(context).pushReplacementNamed('/onboarding'),
      onNavigateToHome: (role) => Navigator.of(context).pushReplacementNamed('/$role/home'),
    );
  }
}

class _OnboardingWrapper extends StatelessWidget {
  const _OnboardingWrapper();

  @override
  Widget build(BuildContext context) {
    return OnboardingScreen(
      onLogin: () => Navigator.of(context).pushReplacementNamed('/login'),
      onRegister: () => Navigator.of(context).pushNamed('/register'),
    );
  }
}

class _LoginWrapper extends StatelessWidget {
  const _LoginWrapper();

  @override
  Widget build(BuildContext context) {
    return LoginScreen(
      onRegister: () => Navigator.of(context).pushNamed('/register'),
      onSuccess: (role) => Navigator.of(context).pushNamedAndRemoveUntil('/$role/home', (_) => false),
    );
  }
}

class _RegisterWrapper extends StatelessWidget {
  const _RegisterWrapper();

  @override
  Widget build(BuildContext context) {
    return RegisterScreen(
      onLogin: () => Navigator.of(context).pop(),
      onSuccess: () => Navigator.of(context).pushReplacementNamed('/login'),
    );
  }
}
