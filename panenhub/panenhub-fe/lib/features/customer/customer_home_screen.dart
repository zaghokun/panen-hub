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

              // Premium Greeting Card with gradient
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selamat Datang 👋',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            auth.user?.name ?? '',
                            style: AppTextStyles.headlineMedium.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          (auth.user?.name ?? 'U')[0],
                          style: AppTextStyles.titleLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Search Bar with shadow
              GestureDetector(
                onTap: onSearchTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.primarySurface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.search, color: AppColors.primary, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Text('Cari komoditas segar...', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Categories
              Text('Kategori', style: AppTextStyles.titleMedium),
              const SizedBox(height: 12),
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: ['Semua', 'Sayur', 'Buah', 'Bumbu', 'Biji-bijian', 'Umbi', 'Lainnya'].map((cat) {
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
                        onSelected: (_) => onSearchTap(),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 28),

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
                      Row(
                        children: [
                          Container(
                            width: 4,
                            height: 20,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('Pesanan Aktif', style: AppTextStyles.titleMedium),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...active.take(2).map((order) => _OrderCard(order: order, onTap: () => onOrderTap(order.id))),
                      const SizedBox(height: 24),
                    ],
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              // Escrow Banner – polished
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.shield_outlined, color: Colors.white, size: 26),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pembayaran Aman',
                            style: AppTextStyles.labelLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Dana ditahan aman sampai pesanan diterima sesuai.',
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.white.withValues(alpha: 0.8),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Recommended Commodities
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('Komoditas Mendekati Panen', style: AppTextStyles.titleMedium),
                ],
              ),
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
            border: Border.all(color: AppColors.border.withValues(alpha: 0.4)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primarySurface, AppColors.primaryLight.withValues(alpha: 0.5)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.eco, color: AppColors.primary, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(commodity.name, style: AppTextStyles.labelLarge),
                    const SizedBox(height: 3),
                    Text(
                      '${commodity.farmerName} · ${commodity.location}',
                      style: AppTextStyles.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(CurrencyFormatter.formatPerKg(commodity.pricePerKg), style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star, size: 13, color: AppColors.secondary),
                              const SizedBox(width: 2),
                              Text(commodity.farmerRating.toString(), style: AppTextStyles.caption.copyWith(color: AppColors.secondary, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
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
            border: Border.all(color: AppColors.border.withValues(alpha: 0.4)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
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
