import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/widgets/app_status_chip.dart';
import '../../core/widgets/app_loading_state.dart';
import '../../providers/app_providers.dart';
import '../../shared/enums/app_enums.dart';
import '../../shared/models/app_models.dart';
import '../../data/mock_data_source.dart';

// ─── CUSTOMER HOME SCREEN ────────────────────────────────
class CustomerHomeScreen extends ConsumerWidget {
  final void Function(String id) onCommodityTap;
  final void Function(String id) onOrderTap;
  final VoidCallback onSearchTap;

  const CustomerHomeScreen({super.key, required this.onCommodityTap, required this.onOrderTap, required this.onSearchTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final orders = ref.watch(orderListProvider);
    final commodities = ref.watch(commodityListProvider(null));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.md),
              // Greeting
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Selamat Datang 👋', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                        const SizedBox(height: 4),
                        Text(auth.user?.name ?? '', style: AppTextStyles.headlineMedium),
                      ],
                    ),
                  ),
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primarySurface,
                    child: Text(
                      (auth.user?.name ?? 'U')[0],
                      style: AppTextStyles.titleLarge.copyWith(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Search Bar
              GestureDetector(
                onTap: onSearchTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: AppColors.textHint, size: 20),
                      const SizedBox(width: 10),
                      Text('Cari komoditas segar...', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Categories
              Text('Kategori', style: AppTextStyles.titleMedium),
              const SizedBox(height: 12),
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: MockDataSource.categories.map((cat) {
                    final isFirst = cat == 'Semua';
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(cat),
                        selected: isFirst,
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(color: isFirst ? Colors.white : AppColors.textPrimary, fontSize: 13),
                        backgroundColor: AppColors.surface,
                        side: BorderSide(color: isFirst ? AppColors.primary : AppColors.border),
                        onSelected: (_) {},
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),

              // Active Orders
              orders.when(
                data: (list) {
                  final active = list.where((o) =>
                      o.status != OrderStatus.completed &&
                      o.status != OrderStatus.cancelled &&
                      o.status != OrderStatus.refunded).toList();
                  if (active.isEmpty) return const SizedBox.shrink();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Pesanan Aktif', style: AppTextStyles.titleMedium),
                      const SizedBox(height: 12),
                      ...active.take(2).map((order) => _OrderCard(order: order, onTap: () => onOrderTap(order.id))),
                      const SizedBox(height: 24),
                    ],
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              // Escrow Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.shield_outlined, color: Colors.white, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Pembayaran Aman', style: AppTextStyles.labelLarge.copyWith(color: Colors.white)),
                          const SizedBox(height: 4),
                          Text('Dana ditahan aman sampai pesanan diterima sesuai.', style: AppTextStyles.caption.copyWith(color: Colors.white70)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Recommended Commodities
              Text('Komoditas Mendekati Panen', style: AppTextStyles.titleMedium),
              const SizedBox(height: 12),
              commodities.when(
                data: (list) {
                  final sorted = List<Commodity>.from(list)..sort((a, b) => a.estimatedHarvestDate.compareTo(b.estimatedHarvestDate));
                  return Column(
                    children: sorted.take(4).map((c) => _CommodityCard(commodity: c, onTap: () => onCommodityTap(c.id))).toList(),
                  );
                },
                loading: () => const AppLoadingState(),
                error: (_, __) => const Text('Gagal memuat komoditas'),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── COMMODITY CARD ──────────────────────────────────────
class _CommodityCard extends StatelessWidget {
  final Commodity commodity;
  final VoidCallback onTap;
  const _CommodityCard({required this.commodity, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Row(
            children: [
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.eco, color: AppColors.primary, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(commodity.name, style: AppTextStyles.labelLarge),
                    const SizedBox(height: 2),
                    Text('${commodity.farmerName} · ${commodity.location}', style: AppTextStyles.caption),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(CurrencyFormatter.formatPerKg(commodity.pricePerKg), style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary)),
                        const Spacer(),
                        Icon(Icons.star, size: 14, color: AppColors.secondary),
                        const SizedBox(width: 2),
                        Text(commodity.farmerRating.toString(), style: AppTextStyles.caption),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── ORDER CARD ──────────────────────────────────────────
class _OrderCard extends StatelessWidget {
  final PreOrder order;
  final VoidCallback onTap;
  const _OrderCard({required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(order.commodityName, style: AppTextStyles.labelLarge)),
                  AppStatusChip.order(order.status),
                ],
              ),
              const SizedBox(height: 8),
              Text('${order.quantityKg.toStringAsFixed(0)} kg · ${CurrencyFormatter.format(order.totalPrice)}', style: AppTextStyles.bodyMedium),
              const SizedBox(height: 4),
              Text('Pengiriman: ${DateFormatter.short(order.deliveryDate)}', style: AppTextStyles.caption),
            ],
          ),
        ),
      ),
    );
  }
}
