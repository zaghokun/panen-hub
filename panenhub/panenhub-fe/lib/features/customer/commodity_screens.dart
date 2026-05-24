import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';

import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/widgets/app_loading_state.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../providers/app_providers.dart';
import '../../shared/models/app_models.dart';
import '../../data/mock_data_source.dart';

// ─── COMMODITY LIST SCREEN ───────────────────────────────
class CommodityListScreen extends ConsumerStatefulWidget {
  final void Function(String id) onCommodityTap;
  const CommodityListScreen({super.key, required this.onCommodityTap});

  @override
  ConsumerState<CommodityListScreen> createState() => _CommodityListScreenState();
}

class _CommodityListScreenState extends ConsumerState<CommodityListScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'Semua';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final commodities = ref.watch(commodityListProvider(_searchQuery.isEmpty ? null : _searchQuery));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Cari Komoditas')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Cari nama, kategori, lokasi...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: () { _searchController.clear(); setState(() => _searchQuery = ''); })
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: MockDataSource.categories.map((cat) {
                final sel = cat == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(label: Text(cat, style: TextStyle(fontSize: 12, color: sel ? Colors.white : AppColors.textPrimary)), selected: sel, selectedColor: AppColors.primary, backgroundColor: AppColors.surface, side: BorderSide(color: sel ? AppColors.primary : AppColors.border), onSelected: (_) => setState(() => _selectedCategory = cat)),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: commodities.when(
              data: (list) {
                final filtered = _selectedCategory == 'Semua' ? list : list.where((c) => c.category == _selectedCategory).toList();
                if (filtered.isEmpty) {
                  return const AppEmptyState(icon: Icons.search_off, title: 'Komoditas Tidak Ditemukan', description: 'Belum ada komoditas yang sesuai filter.');
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) => _CommodityListCard(commodity: filtered[i], onTap: () => widget.onCommodityTap(filtered[i].id)),
                );
              },
              loading: () => const AppLoadingState(),
              error: (_, __) => const Center(child: Text('Gagal memuat data')),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommodityListCard extends StatelessWidget {
  final Commodity commodity;
  final VoidCallback onTap;
  const _CommodityListCard({required this.commodity, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border.withValues(alpha: 0.5))),
        child: Row(
          children: [
            Container(width: 72, height: 72, decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.eco, color: AppColors.primary, size: 32)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(commodity.name, style: AppTextStyles.labelLarge),
                const SizedBox(height: 2),
                Text('${commodity.farmerName} · ${commodity.location}', style: AppTextStyles.caption),
                const SizedBox(height: 4),
                Row(children: [
                  Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: AppColors.secondaryLight, borderRadius: BorderRadius.circular(4)), child: Text(commodity.category, style: AppTextStyles.labelSmall.copyWith(color: AppColors.secondary))),
                  const SizedBox(width: 8),
                  Icon(Icons.calendar_today, size: 12, color: AppColors.textSecondary),
                  const SizedBox(width: 3),
                  Text(DateFormatter.relative(commodity.estimatedHarvestDate), style: AppTextStyles.caption),
                ]),
                const SizedBox(height: 6),
                Row(children: [
                  Text(CurrencyFormatter.formatPerKg(commodity.pricePerKg), style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary)),
                  const Spacer(),
                  Text('Kuota: ${commodity.availableQuotaKg.toStringAsFixed(0)} kg', style: AppTextStyles.caption),
                ]),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── COMMODITY DETAIL SCREEN ─────────────────────────────
class CommodityDetailScreen extends ConsumerWidget {
  final String commodityId;
  final void Function(String id) onPreOrder;
  const CommodityDetailScreen({super.key, required this.commodityId, required this.onPreOrder});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commodity = ref.watch(commodityDetailProvider(commodityId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Detail Komoditas')),
      body: commodity.when(
        data: (c) => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 200, width: double.infinity, color: AppColors.primarySurface, child: const Icon(Icons.eco, size: 80, color: AppColors.primary)),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: AppColors.secondaryLight, borderRadius: BorderRadius.circular(6)), child: Text(c.category, style: AppTextStyles.labelSmall.copyWith(color: AppColors.secondary))),
                    const Spacer(),
                    Icon(Icons.star, size: 16, color: AppColors.secondary),
                    const SizedBox(width: 4),
                    Text('${c.farmerRating}', style: AppTextStyles.labelMedium),
                  ]),
                  const SizedBox(height: 12),
                  Text(c.name, style: AppTextStyles.headlineLarge),
                  const SizedBox(height: 8),
                  Text(CurrencyFormatter.formatPerKg(c.pricePerKg), style: AppTextStyles.headlineMedium.copyWith(color: AppColors.primary)),
                  const SizedBox(height: 16),
                  _InfoRow(icon: Icons.calendar_today, label: 'Estimasi Panen', value: DateFormatter.full(c.estimatedHarvestDate)),
                  _InfoRow(icon: Icons.inventory_2_outlined, label: 'Kuota Tersedia', value: '${c.availableQuotaKg.toStringAsFixed(0)} kg'),
                  _InfoRow(icon: Icons.location_on_outlined, label: 'Lokasi', value: c.location),
                  const SizedBox(height: 16),
                  Text('Deskripsi', style: AppTextStyles.titleMedium),
                  const SizedBox(height: 8),
                  Text(c.description, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 20),
                  // Farmer info
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                        builder: (ctx) => Consumer(builder: (ctx, ref, _) {
                          final reviews = ref.watch(reviewListProvider(c.farmerId));
                          return Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Row(children: [
                                CircleAvatar(radius: 22, backgroundColor: AppColors.primarySurface, child: Text(c.farmerName[0], style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary))),
                                const SizedBox(width: 12),
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(c.farmerName, style: AppTextStyles.labelLarge),
                                  Text('Petani Mitra PanenHub', style: AppTextStyles.caption),
                                ])),
                              ]),
                              const Divider(height: 24),
                              Text('Ulasan', style: AppTextStyles.titleMedium),
                              const SizedBox(height: 12),
                              reviews.when(
                                data: (list) {
                                  if (list.isEmpty) return Text('Belum ada ulasan.', style: AppTextStyles.caption);
                                  return Column(children: list.take(3).map((r) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      Row(children: List.generate(5, (i) => Icon(i < r.rating ? Icons.star : Icons.star_border, size: 14, color: AppColors.secondary))),
                                      const SizedBox(width: 8),
                                      Expanded(child: Text(r.comment, style: AppTextStyles.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis)),
                                    ]),
                                  )).toList());
                                },
                                loading: () => const SizedBox(height: 40, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
                                error: (_, __) => Text('Gagal memuat ulasan', style: AppTextStyles.caption),
                              ),
                              const SizedBox(height: 8),
                            ]),
                          );
                        }),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
                      child: Row(children: [
                        CircleAvatar(radius: 22, backgroundColor: AppColors.primarySurface, child: Text(c.farmerName[0], style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary))),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(c.farmerName, style: AppTextStyles.labelLarge),
                          Text('Petani Mitra PanenHub', style: AppTextStyles.caption),
                        ])),
                        Icon(Icons.chevron_right, color: AppColors.textSecondary),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 100),
                ]),
              ),
            ],
          ),
        ),
        loading: () => const AppLoadingState(),
        error: (_, __) => const Center(child: Text('Gagal memuat detail')),
      ),
      bottomNavigationBar: commodity.whenData((c) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: AppColors.surface, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -2))]),
        child: SafeArea(
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Total Harga', style: AppTextStyles.caption),
              Text(CurrencyFormatter.formatPerKg(c.pricePerKg), style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary)),
            ])),
            ElevatedButton(
              onPressed: c.availableQuotaKg > 0 ? () => onPreOrder(c.id) : null,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14)),
              child: const Text('Buat Pre-Order'),
            ),
          ]),
        ),
      )).value ?? const SizedBox.shrink(),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 10),
        Text('$label: ', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
        Expanded(child: Text(value, style: AppTextStyles.bodyMedium)),
      ]),
    );
  }
}
