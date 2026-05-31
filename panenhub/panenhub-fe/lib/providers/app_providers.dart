import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../shared/enums/app_enums.dart';
import '../shared/models/app_models.dart';
import '../core/network/services/auth_service.dart';
import '../core/network/services/commodity_service.dart';
import '../core/network/services/order_service.dart';
import '../core/network/services/payment_service.dart';
import '../core/network/services/farmer_service.dart';
import '../core/network/services/admin_service.dart';
import '../core/network/services/notification_service.dart';
import '../core/network/token_storage.dart';
import '../core/network/api_exceptions.dart';

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

  final _authService = AuthService();

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _authService.login(email, password);
      state = state.copyWith(user: user, isLoading: false);
      return true;
    } on DioException catch (e) {
      final apiError = e.error;
      final message = apiError is ApiException ? apiError.message : 'Tidak dapat terhubung ke server.';
      state = state.copyWith(isLoading: false, error: message);
      return false;
    } catch (_) {
      state = state.copyWith(isLoading: false, error: 'Tidak dapat terhubung ke server.');
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    state = const AuthState();
  }

  Future<void> checkSession() async {
    final token = await TokenStorage.getAccessToken();
    if (token == null) {
      state = const AuthState();
      return;
    }
    try {
      final user = await _authService.me();
      state = state.copyWith(user: user);
    } catch (_) {
      await TokenStorage.clear();
      state = const AuthState();
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

// ─── COMMODITY PROVIDERS ─────────────────────────────────

final _commodityService = CommodityService();

final commodityListProvider = FutureProvider.family<List<Commodity>, String?>((ref, search) async {
  return _commodityService.list(search: search);
});

final commodityDetailProvider = FutureProvider.family<Commodity, String>((ref, id) async {
  return _commodityService.detail(id);
});

final farmerCommodityListProvider = FutureProvider<List<Commodity>>((ref) async {
  return _commodityService.farmerList();
});

// ─── ORDER PROVIDERS ─────────────────────────────────────

final _orderService = OrderService();

class OrderListNotifier extends StateNotifier<AsyncValue<List<PreOrder>>> {
  final Ref ref;

  OrderListNotifier(this.ref) : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    await Future.delayed(const Duration(milliseconds: 100));
    await loadOrders();
  }

  Future<void> loadOrders() async {
    state = const AsyncValue.loading();
    try {
      final auth = ref.read(authProvider);
      if (auth.user == null) {
        state = const AsyncValue.data([]);
        return;
      }
      List<PreOrder> orders;
      if (auth.role == UserRole.farmer) {
        orders = await _orderService.farmerList();
      } else {
        orders = await _orderService.customerList();
      }
      state = AsyncValue.data(orders);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateStatus(String orderId, OrderStatus newStatus, {
    String? notes,
    String? courierName,
    String? trackingNumber,
  }) async {
    await _orderService.updateStatus(
      orderId,
      status: newStatus.toApi(),
      notes: notes,
      courierName: courierName,
      trackingNumber: trackingNumber,
    );
    await loadOrders();
  }
}

final orderListProvider = StateNotifierProvider<OrderListNotifier, AsyncValue<List<PreOrder>>>((ref) {
  return OrderListNotifier(ref);
});

final orderDetailProvider = FutureProvider.family<PreOrder, String>((ref, id) async {
  return _orderService.detail(id);
});

// ─── PAYMENT PROVIDERS ──────────────────────────────────

final _paymentService = PaymentService();

final paymentProvider = FutureProvider.family<Payment, String>((ref, orderId) async {
  return _paymentService.getStatus(orderId);
});

// ─── WALLET PROVIDER ────────────────────────────────────

final _farmerService = FarmerService();

final walletProvider = FutureProvider<WalletSummary>((ref) async {
  return _farmerService.getWallet();
});

// ─── DISPUTE PROVIDERS ──────────────────────────────────

final _adminService = AdminService();

final adminDashboardProvider = FutureProvider<Map<String, int>>((ref) async {
  return _adminService.dashboard();
});

final disputeListProvider = FutureProvider<List<Dispute>>((ref) async {
  return _adminService.listDisputes();
});

// ─── WITHDRAWAL PROVIDERS ───────────────────────────────

final withdrawalListProvider = FutureProvider<List<Withdrawal>>((ref) async {
  return _adminService.listWithdrawals();
});

// ─── REVIEW PROVIDERS ───────────────────────────────────

// Note: Backend doesn't have a "list reviews by farmer" endpoint yet.
// For now, return empty. Can be added later.
final reviewListProvider = FutureProvider.family<List<Review>, String>((ref, farmerId) async {
  return [];
});

// ─── NOTIFICATION PROVIDERS ─────────────────────────────

final _notificationService = NotificationService();

final notificationListProvider = FutureProvider<List<AppNotification>>((ref) async {
  return _notificationService.list();
});

// ─── PENDING USERS (ADMIN) ──────────────────────────────

final pendingUsersProvider = FutureProvider<List<AppUser>>((ref) async {
  return _adminService.pendingVerifications();
});

// ─── STATUS HISTORY ─────────────────────────────────────

final orderStatusHistoryProvider =
    FutureProvider.family<List<OrderStatusHistory>, String>((ref, orderId) async {
  return _orderService.statusHistory(orderId);
});

// ─── BOTTOM NAV INDEX ───────────────────────────────────

final bottomNavIndexProvider = StateProvider<int>((ref) => 0);
