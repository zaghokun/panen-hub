import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_providers.dart';
import '../admin/admin_screens.dart';

class AdminHomeShell extends ConsumerWidget {
  const AdminHomeShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(bottomNavIndexProvider);

    final screens = [
      const AdminDashboardScreen(),
      const UserVerificationScreen(),
      const AdminDisputeListScreen(),
      const AdminWithdrawalScreen(),
      ProfileScreen(onLogout: () => Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false)),
    ];

    return Scaffold(
      body: IndexedStack(index: index, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) {
          ref.read(bottomNavIndexProvider.notifier).state = i;
          switch (i) {
            case 0:
              ref.invalidate(adminDashboardProvider);
              ref.invalidate(disputeListProvider);
              ref.invalidate(withdrawalListProvider);
              break;
            case 1:
              ref.invalidate(pendingUsersProvider);
              break;
            case 2:
              ref.invalidate(disputeListProvider);
              break;
            case 3:
              ref.invalidate(withdrawalListProvider);
              break;
            case 4:
              ref.read(authProvider.notifier).checkSession();
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.verified_user_outlined), activeIcon: Icon(Icons.verified_user), label: 'Verifikasi'),
          BottomNavigationBarItem(icon: Icon(Icons.gavel_outlined), activeIcon: Icon(Icons.gavel), label: 'Sengketa'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_outlined), activeIcon: Icon(Icons.account_balance_wallet), label: 'Pencairan'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
