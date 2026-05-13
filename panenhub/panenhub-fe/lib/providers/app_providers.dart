import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/mock_data_source.dart';
import '../shared/enums/app_enums.dart';
import '../shared/models/app_models.dart';

// ─── AUTH STATE ─────────────────────────────────────────

class AuthState {
  final AppUser? user;
  final bool isLoading;
  final String? error;

  const AuthState({this.user, this.isLoading = false, this.error});

  bool get isAuthenticated => user != null;
  UserRole? get role => user?.role;

  AuthState copyWith({AppUser? user, bool? isLoading, String? error, bool clearUser = false}) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    await Future.delayed(const Duration(milliseconds: 800));

    AppUser? user;
    if (email == 'customer@panenhub.test' && password == 'password') {
      user = MockDataSource.customerUser;
    } else if (email == 'farmer@panenhub.test' && password == 'password') {
      user = MockDataSource.farmerUser;
    } else if (email == 'admin@panenhub.test' && password == 'password') {
      user = MockDataSource.adminUser;
    }

    if (user != null) {
      state = state.copyWith(user: user, isLoading: false);
      return true;
    } else {
      state = state.copyWith(isLoading: false, error: 'Email atau password salah');
      return false;
    }
  }

  void logout() {
    state = const AuthState();
  }

  void checkSession() {
    // In mock mode, no persisted session
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

// ─── COMMODITY PROVIDERS ─────────────────────────────────

final commodityListProvider = FutureProvider.family<List<Commodity>, String?>((ref, search) async {
  await Future.delayed(const Duration(milliseconds: 600));
  final items = MockDataSource.commodities.where((c) => c.isActive).toList();
  if (search != null && search.isNotEmpty) {
    return items
        .where((c) =>
            c.name.toLowerCase().contains(search.toLowerCase()) ||
            c.category.toLowerCase().contains(search.toLowerCase()) ||
            c.location.toLowerCase().contains(search.toLowerCase()))
        .toList();
  }
  return items;
});

final commodityDetailProvider = FutureProvider.family<Commodity, String>((ref, id) async {
  await Future.delayed(const Duration(milliseconds: 400));
  return MockDataSource.commodities.firstWhere((c) => c.id == id);
});

final farmerCommodityListProvider = FutureProvider<List<Commodity>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 500));
  final auth = ref.read(authProvider);
  return MockDataSource.commodities.where((c) => c.farmerId == auth.user?.id).toList();
});

// ─── ORDER PROVIDERS ─────────────────────────────────────

class OrderListNotifier extends StateNotifier<AsyncValue<List<PreOrder>>> {
  final Ref ref;

  OrderListNotifier(this.ref) : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    // Small delay to ensure auth state is ready
    await Future.delayed(const Duration(milliseconds: 100));
    await loadOrders();
  }

  Future<void> loadOrders() async {
    state = const AsyncValue.loading();
    await Future.delayed(const Duration(milliseconds: 600));
    final auth = ref.read(authProvider);
    if (auth.user == null) {
      state = const AsyncValue.data([]);
      return;
    }
    List<PreOrder> filtered;
    if (auth.role == UserRole.customer) {
      filtered = MockDataSource.orders.where((o) => o.customerId == auth.user?.id).toList();
    } else if (auth.role == UserRole.farmer) {
      filtered = MockDataSource.orders.where((o) => o.farmerId == auth.user?.id).toList();
    } else {
      filtered = List.from(MockDataSource.orders);
    }
    state = AsyncValue.data(filtered);
  }

  Future<void> updateStatus(String orderId, OrderStatus newStatus) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = MockDataSource.orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      MockDataSource.orders[index] = MockDataSource.orders[index].copyWith(status: newStatus);
    }
    await loadOrders();
  }
}

final orderListProvider = StateNotifierProvider<OrderListNotifier, AsyncValue<List<PreOrder>>>((ref) {
  return OrderListNotifier(ref);
});

final orderDetailProvider = FutureProvider.family<PreOrder, String>((ref, id) async {
  await Future.delayed(const Duration(milliseconds: 400));
  return MockDataSource.orders.firstWhere((o) => o.id == id);
});

// ─── PAYMENT PROVIDERS ──────────────────────────────────

final paymentProvider = FutureProvider.family<Payment, String>((ref, orderId) async {
  await Future.delayed(const Duration(milliseconds: 400));
  return MockDataSource.payments.firstWhere((p) => p.orderId == orderId,
      orElse: () => Payment(
            id: 'PAY-NEW',
            orderId: orderId,
            amount: 0,
            method: 'BCA Virtual Account',
            virtualAccountNumber: '8801234567890099',
            escrowStatus: 'pending',
          ));
});

// ─── WALLET PROVIDER ────────────────────────────────────

final walletProvider = FutureProvider<WalletSummary>((ref) async {
  await Future.delayed(const Duration(milliseconds: 500));
  return MockDataSource.walletSummary;
});

// ─── DISPUTE PROVIDERS ──────────────────────────────────

final disputeListProvider = FutureProvider<List<Dispute>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 500));
  return MockDataSource.disputes;
});

// ─── WITHDRAWAL PROVIDERS ───────────────────────────────

final withdrawalListProvider = FutureProvider<List<Withdrawal>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 500));
  return MockDataSource.withdrawals;
});

// ─── REVIEW PROVIDERS ───────────────────────────────────

final reviewListProvider = FutureProvider.family<List<Review>, String>((ref, farmerId) async {
  await Future.delayed(const Duration(milliseconds: 400));
  return MockDataSource.reviews.where((r) => r.farmerId == farmerId).toList();
});

// ─── NOTIFICATION PROVIDERS ─────────────────────────────

final notificationListProvider = FutureProvider<List<AppNotification>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 400));
  return MockDataSource.notifications;
});

// ─── PENDING USERS (ADMIN) ──────────────────────────────

final pendingUsersProvider = FutureProvider<List<AppUser>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 500));
  return [MockDataSource.pendingFarmer, MockDataSource.pendingFarmer2];
});

// ─── STATUS HISTORY ─────────────────────────────────────

final orderStatusHistoryProvider =
    FutureProvider.family<List<OrderStatusHistory>, String>((ref, orderId) async {
  await Future.delayed(const Duration(milliseconds: 300));
  return MockDataSource.orderStatusHistories[orderId] ?? [];
});

// ─── BOTTOM NAV INDEX ───────────────────────────────────

final bottomNavIndexProvider = StateProvider<int>((ref) => 0);
