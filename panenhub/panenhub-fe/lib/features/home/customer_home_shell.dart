import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/app_providers.dart';
import '../customer/customer_home_screen.dart';
import '../customer/commodity_screens.dart';
import '../customer/order_screens.dart';
import '../admin/admin_screens.dart';

class CustomerHomeShell extends ConsumerWidget {
  const CustomerHomeShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(bottomNavIndexProvider);

    final screens = [
      CustomerHomeScreen(
        onCommodityTap: (id) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => CommodityDetailScreen(commodityId: id, onPreOrder: (cid) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => CreatePreOrderScreen(commodityId: cid, onSuccess: () => Navigator.of(context).pop())))))),
        onOrderTap: (id) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => OrderDetailScreen(orderId: id, onDispute: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => CreateDisputeScreen(orderId: id, onSuccess: () { Navigator.of(context).pop(); Navigator.of(context).pop(); }))), onReview: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => CreateReviewScreen(orderId: id, onSuccess: () { Navigator.of(context).pop(); Navigator.of(context).pop(); })))))),
        onSearchTap: () => ref.read(bottomNavIndexProvider.notifier).state = 1,
      ),
      CommodityListScreen(onCommodityTap: (id) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => CommodityDetailScreen(commodityId: id, onPreOrder: (cid) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => CreatePreOrderScreen(commodityId: cid, onSuccess: () => Navigator.of(context).pop()))))))),
      OrderListScreen(onOrderTap: (id) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => OrderDetailScreen(orderId: id, onDispute: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => CreateDisputeScreen(orderId: id, onSuccess: () { Navigator.of(context).pop(); Navigator.of(context).pop(); }))), onReview: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => CreateReviewScreen(orderId: id, onSuccess: () { Navigator.of(context).pop(); Navigator.of(context).pop(); }))))))),
      const NotificationListScreen(),
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
              ref.invalidate(orderListProvider);
              ref.invalidate(commodityListProvider);
              break;
            case 1:
              ref.invalidate(commodityListProvider);
              break;
            case 2:
              ref.invalidate(orderListProvider);
              break;
            case 3:
              ref.invalidate(notificationListProvider);
              break;
            case 4:
              ref.read(authProvider.notifier).checkSession();
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.search_outlined), activeIcon: Icon(Icons.search), label: 'Cari'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), activeIcon: Icon(Icons.receipt_long), label: 'Pesanan'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_outlined), activeIcon: Icon(Icons.notifications), label: 'Notifikasi'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
