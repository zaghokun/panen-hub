import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_providers.dart';
import '../farmer/farmer_screens.dart';
import '../customer/order_screens.dart';
import '../customer/commodity_screens.dart';
import '../admin/admin_screens.dart';

class FarmerHomeShell extends ConsumerWidget {
  const FarmerHomeShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(bottomNavIndexProvider);

    final screens = [
      FarmerDashboardScreen(onAddCommodity: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => CreateCommodityScreen(onSuccess: () => Navigator.of(context).pop())))),
      FarmerCommodityListScreen(
        onAdd: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => CreateCommodityScreen(onSuccess: () => Navigator.of(context).pop()))),
        onCommodityTap: (id) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => CommodityDetailScreen(commodityId: id, onPreOrder: (_) {}))),
      ),
      FarmerOrderListScreen(onOrderTap: (id) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => OrderDetailScreen(orderId: id)))),
      FarmerWalletScreen(onWithdraw: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => WithdrawalRequestScreen(onSuccess: () => Navigator.of(context).pop())))),
      ProfileScreen(onLogout: () => Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false)),
    ];

    return Scaffold(
      body: IndexedStack(index: index, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) => ref.read(bottomNavIndexProvider.notifier).state = i,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.eco_outlined), activeIcon: Icon(Icons.eco), label: 'Komoditas'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), activeIcon: Icon(Icons.receipt_long), label: 'Pesanan'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_outlined), activeIcon: Icon(Icons.account_balance_wallet), label: 'Keuangan'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
