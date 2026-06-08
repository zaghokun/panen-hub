import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/app_status_chip.dart';
import '../../core/widgets/app_loading_state.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../core/network/services/commodity_service.dart';
import '../../core/network/services/farmer_service.dart';
import '../../core/network/services/order_service.dart';
import '../../core/network/api_exceptions.dart';
import '../../providers/app_providers.dart';
import '../../shared/models/app_models.dart';
import '../../shared/enums/app_enums.dart';

import '../../core/utils/status_mapper.dart';

class FarmerDashboardScreen extends ConsumerWidget {
  final VoidCallback onAddCommodity;
  const FarmerDashboardScreen({super.key, required this.onAddCommodity});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final wallet = ref.watch(walletProvider);
    final commodities = ref.watch(farmerCommodityListProvider);
    final orders = ref.watch(orderListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(walletProvider);
            ref.invalidate(farmerCommodityListProvider);
            ref.invalidate(orderListProvider);
            await ref.read(authProvider.notifier).checkSession();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Premium greeting card
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
                child: Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Dashboard Petani 🌾', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white.withValues(alpha: 0.85))),
                    const SizedBox(height: 4),
                    Text(auth.user?.name ?? '', style: AppTextStyles.headlineMedium.copyWith(color: Colors.white)),
                  ])),
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.agriculture, color: Colors.white, size: 26),
                  ),
                ]),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.success.withValues(alpha: 0.2)),
                ),
                child: Row(children: [const Icon(Icons.verified, color: AppColors.success, size: 18), const SizedBox(width: 8), Text('Akun terverifikasi', style: AppTextStyles.caption.copyWith(color: AppColors.success, fontWeight: FontWeight.w500))]),
              ),
              const SizedBox(height: 24),
              // Section header with accent
              Row(children: [
                Container(width: 4, height: 20, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2))),
                const SizedBox(width: 8),
                Text('Ringkasan', style: AppTextStyles.titleMedium),
              ]),
              const SizedBox(height: 14),
              // Stats
              Row(children: [
                _StatCard(icon: Icons.eco, label: 'Komoditas', value: '${commodities.valueOrNull?.length ?? 0}', color: AppColors.primary),
                const SizedBox(width: 12),
                _StatCard(icon: Icons.receipt_long, label: 'Pesanan', value: '${orders.valueOrNull?.length ?? 0}', color: AppColors.info),
              ]),
              const SizedBox(height: 12),
              wallet.when(
                data: (w) => Row(children: [
                  _StatCard(icon: Icons.account_balance_wallet, label: 'Tersedia', value: CurrencyFormatter.format(w.availableBalance), color: AppColors.success),
                  const SizedBox(width: 12),
                  _StatCard(icon: Icons.lock_outline, label: 'Tertahan', value: CurrencyFormatter.format(w.heldBalance), color: AppColors.warning),
                ]),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 28),
              Row(children: [
                Container(width: 4, height: 20, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2))),
                const SizedBox(width: 8),
                Text('Aksi Cepat', style: AppTextStyles.titleMedium),
              ]),
              const SizedBox(height: 14),
              AppButton(label: 'Posting Estimasi Panen', icon: Icons.add_circle_outline, onPressed: onAddCommodity),
              const SizedBox(height: 32),
            ]),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon; final String label; final String value; final Color color;
  const _StatCard({required this.icon, required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    return Expanded(child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: color, width: 3.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(height: 10),
        Text(value, style: AppTextStyles.titleMedium.copyWith(color: color)),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyles.caption),
      ]),
    ));
  }
}

// ─── FARMER COMMODITY LIST ───────────────────────────────
class FarmerCommodityListScreen extends ConsumerWidget {
  final VoidCallback onAdd;
  final void Function(String id)? onCommodityTap;
  const FarmerCommodityListScreen({super.key, required this.onAdd, this.onCommodityTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commodities = ref.watch(farmerCommodityListProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Komoditas Saya')),
      floatingActionButton: FloatingActionButton(onPressed: onAdd, backgroundColor: AppColors.primary, child: const Icon(Icons.add, color: Colors.white)),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(farmerCommodityListProvider);
        },
        child: commodities.when(
          data: (list) {
            if (list.isEmpty) {
              return Stack(
                children: [
                  ListView(),
                  const AppEmptyState(icon: Icons.eco_outlined, title: 'Belum Ada Komoditas', description: 'Posting estimasi panen pertama Anda.'),
                ],
              );
            }
            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20), 
              itemCount: list.length, 
              itemBuilder: (context, i) {
                final c = list[i];
                return GestureDetector(
                  onTap: onCommodityTap != null ? () => onCommodityTap!(c.id) : null,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border.withValues(alpha: 0.5))),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [Expanded(child: Text(c.name, style: AppTextStyles.labelLarge)), AppStatusChip(label: c.isActive ? 'Aktif' : 'Nonaktif', color: c.isActive ? AppColors.success : AppColors.textSecondary)]),
                      const SizedBox(height: 8),
                      Text('${c.category} · ${c.location}', style: AppTextStyles.caption),
                      const SizedBox(height: 4),
                      Row(children: [
                        Text(CurrencyFormatter.formatPerKg(c.pricePerKg), style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary)),
                        const Spacer(),
                        Text('Kuota: ${c.availableQuotaKg.toStringAsFixed(0)} kg', style: AppTextStyles.caption),
                      ]),
                      const SizedBox(height: 4),
                      Text('Panen: ${DateFormatter.short(c.estimatedHarvestDate)}', style: AppTextStyles.caption),
                    ]),
                  ),
                );
              },
            );
          },
          loading: () => const AppLoadingState(),
          error: (_, __) => Stack(
            children: [
              ListView(),
              const Center(child: Text('Gagal memuat data')),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── CREATE COMMODITY SCREEN ─────────────────────────────
class CreateCommodityScreen extends StatefulWidget {
  final VoidCallback onSuccess;
  const CreateCommodityScreen({super.key, required this.onSuccess});
  @override
  State<CreateCommodityScreen> createState() => _CreateCommodityScreenState();
}

class _CreateCommodityScreenState extends State<CreateCommodityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _quotaCtrl = TextEditingController();
  String _category = 'Sayur';
  DateTime? _harvestDate;
  bool _isLoading = false;

  @override
  void dispose() { _nameCtrl.dispose(); _descCtrl.dispose(); _priceCtrl.dispose(); _quotaCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Posting Estimasi Panen')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AppTextField(label: 'Nama Komoditas', hint: 'Cabai Merah Keriting', controller: _nameCtrl, validator: (v) => Validators.required(v, 'Nama'), prefixIcon: Icons.eco_outlined),
          const SizedBox(height: 16),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Kategori', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(value: _category, items: ['Sayur', 'Buah', 'Bumbu', 'Biji-bijian', 'Umbi', 'Rempah'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setState(() => _category = v!)),
          ]),
          const SizedBox(height: 16),
          AppTextField(label: 'Deskripsi', hint: 'Deskripsi kualitas komoditas', controller: _descCtrl, validator: (v) => Validators.required(v, 'Deskripsi'), maxLines: 3),
          const SizedBox(height: 16),
          AppTextField(label: 'Harga per Kg (Rp)', hint: '32000', controller: _priceCtrl, validator: (v) => Validators.positiveNumber(v, 'Harga'), keyboardType: TextInputType.number, prefixIcon: Icons.attach_money),
          const SizedBox(height: 16),
          AppTextField(label: 'Total Kuota (Kg)', hint: '120', controller: _quotaCtrl, validator: (v) => Validators.positiveNumber(v, 'Kuota'), keyboardType: TextInputType.number, prefixIcon: Icons.inventory_2_outlined),
          const SizedBox(height: 16),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Estimasi Tanggal Panen', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () async { final d = await showDatePicker(context: context, initialDate: DateTime.now().add(const Duration(days: 14)), firstDate: DateTime.now().add(const Duration(days: 1)), lastDate: DateTime.now().add(const Duration(days: 365))); if (d != null) setState(() => _harvestDate = d); },
              child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                child: Row(children: [const Icon(Icons.calendar_today, size: 18, color: AppColors.textSecondary), const SizedBox(width: 10), Text(_harvestDate != null ? DateFormatter.full(_harvestDate!) : 'Pilih tanggal panen', style: TextStyle(fontSize: 14, color: _harvestDate != null ? AppColors.textPrimary : AppColors.textHint))])),
            ),
          ]),
          const SizedBox(height: 24),
          AppButton(label: 'Posting Komoditas', isLoading: _isLoading, onPressed: () async {
            if (!_formKey.currentState!.validate()) return;
            if (_harvestDate == null) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih tanggal panen'), backgroundColor: AppColors.error)); return; }
            setState(() => _isLoading = true);
            try {
              await CommodityService().create(
                name: _nameCtrl.text.trim(),
                category: _category.toLowerCase(),
                description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
                pricePerKg: int.parse(_priceCtrl.text),
                availableQuotaKg: double.parse(_quotaCtrl.text),
                estimatedHarvestDate: _harvestDate!.toUtc().toIso8601String(),
                location: 'Indonesia',
              );
              if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Komoditas berhasil diposting!'), backgroundColor: AppColors.success)); widget.onSuccess(); }
            } on DioException catch (e) {
              if (mounted) { final msg = e.error is ApiException ? (e.error as ApiException).message : 'Gagal posting komoditas.'; ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppColors.error)); }
            } finally { if (mounted) setState(() => _isLoading = false); }
          }),
          const SizedBox(height: 32),
        ])),
      ),
    );
  }
}

// ─── FARMER ORDER LIST ───────────────────────────────────
class FarmerOrderListScreen extends ConsumerWidget {
  final void Function(String id) onOrderTap;
  const FarmerOrderListScreen({super.key, required this.onOrderTap});

  void _showUpdateStatusSheet(BuildContext context, WidgetRef ref, PreOrder order) {
    final nextStatuses = StatusMapper.validNextStatuses(order.status);
    if (nextStatuses.isEmpty) return;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Update Status Pesanan', style: AppTextStyles.titleMedium),
          const SizedBox(height: 4),
          Text(order.commodityName, style: AppTextStyles.caption),
          const SizedBox(height: 16),
          ...nextStatuses.map((status) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  String? courier;
                  String? tracking;
                  if (status == OrderStatus.shipped) {
                    Navigator.of(ctx).pop();
                    final result = await _askCourierInfo(context);
                    if (result == null) return;
                    courier = result.$1;
                    tracking = result.$2;
                  } else {
                    Navigator.of(ctx).pop();
                  }
                  try {
                    await OrderService().updateStatus(order.id, status: status.toApi(), notes: null, courierName: courier, trackingNumber: tracking);
                    ref.invalidate(orderListProvider);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Status diupdate ke ${StatusMapper.orderStatusLabel(status)}'),
                        backgroundColor: AppColors.success,
                      ));
                    }
                  } on DioException catch (e) {
                    if (context.mounted) {
                      final msg = e.error is ApiException ? (e.error as ApiException).message : 'Gagal update status.';
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppColors.error));
                    }
                  }
                },
                icon: const Icon(Icons.arrow_forward, size: 18),
                label: Text(StatusMapper.orderStatusLabel(status)),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
              ),
            ),
          )),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  Future<(String, String)?> _askCourierInfo(BuildContext context) async {
    final courierCtrl = TextEditingController();
    final trackingCtrl = TextEditingController();
    return showDialog<(String, String)>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Info Pengiriman'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: courierCtrl, decoration: const InputDecoration(labelText: 'Nama Kurir (cth: JNE)')),
          const SizedBox(height: 12),
          TextField(controller: trackingCtrl, decoration: const InputDecoration(labelText: 'Nomor Resi')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Batal')),
          ElevatedButton(onPressed: () {
            if (courierCtrl.text.trim().isEmpty || trackingCtrl.text.trim().isEmpty) return;
            Navigator.of(ctx).pop((courierCtrl.text.trim(), trackingCtrl.text.trim()));
          }, child: const Text('Kirim')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(orderListProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Pesanan Masuk')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(orderListProvider);
        },
        child: orders.when(
          data: (list) {
            if (list.isEmpty) {
              return Stack(
                children: [
                  ListView(),
                  const AppEmptyState(icon: Icons.receipt_long_outlined, title: 'Belum Ada Pesanan', description: 'Belum ada pre-order masuk.'),
                ],
              );
            }
            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20), 
              itemCount: list.length, 
              itemBuilder: (context, i) {
                final o = list[i];
                return GestureDetector(
                  onTap: () => onOrderTap(o.id),
                  child: Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border.withValues(alpha: 0.5))),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [Expanded(child: Text(o.id, style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600))), AppStatusChip.order(o.status)]),
                      const SizedBox(height: 8),
                      Text(o.commodityName, style: AppTextStyles.labelLarge),
                      Text('Pelanggan: ${o.customerName}', style: AppTextStyles.caption),
                      const Divider(height: 16),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('${o.quantityKg.toStringAsFixed(0)} kg · ${CurrencyFormatter.format(o.totalPrice)}', style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary)),
                        if (StatusMapper.validNextStatuses(o.status).isNotEmpty)
                          GestureDetector(
                            onTap: () => _showUpdateStatusSheet(context, ref, o),
                            child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(6)),
                              child: Row(mainAxisSize: MainAxisSize.min, children: [
                                Icon(Icons.edit, size: 12, color: AppColors.primary),
                                const SizedBox(width: 4),
                                Text('Update Status', style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary)),
                              ])),
                          ),
                      ]),
                    ]),
                  ),
                );
              },
            );
          },
          loading: () => const AppLoadingState(),
          error: (_, __) => Stack(
            children: [
              ListView(),
              const Center(child: Text('Gagal memuat')),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── FARMER WALLET SCREEN ────────────────────────────────
class FarmerWalletScreen extends ConsumerWidget {
  final VoidCallback onWithdraw;
  const FarmerWalletScreen({super.key, required this.onWithdraw});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallet = ref.watch(walletProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Keuangan')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(walletProvider);
        },
        child: wallet.when(
          data: (w) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20), 
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                width: double.infinity, padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]), borderRadius: BorderRadius.circular(20)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Saldo Tersedia', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70)),
                  const SizedBox(height: 4),
                  Text(CurrencyFormatter.format(w.availableBalance), style: AppTextStyles.displayMedium.copyWith(color: Colors.white)),
                  const SizedBox(height: 16),
                  Row(children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Tertahan', style: AppTextStyles.caption.copyWith(color: Colors.white60)),
                      Text(CurrencyFormatter.format(w.heldBalance), style: AppTextStyles.labelLarge.copyWith(color: Colors.white)),
                    ])),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Dicairkan', style: AppTextStyles.caption.copyWith(color: Colors.white60)),
                      Text(CurrencyFormatter.format(w.totalDisbursed), style: AppTextStyles.labelLarge.copyWith(color: Colors.white)),
                    ])),
                  ]),
                ]),
              ),
              const SizedBox(height: 16),
              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.infoLight, borderRadius: BorderRadius.circular(10)),
                child: Row(children: [const Icon(Icons.info_outline, color: AppColors.info, size: 18), const SizedBox(width: 8), Expanded(child: Text('Dana tersedia dapat ditarik setelah pesanan selesai divalidasi.', style: AppTextStyles.caption.copyWith(color: AppColors.info)))])),
              const SizedBox(height: 24),
              AppButton(label: 'Ajukan Pencairan Dana', icon: Icons.account_balance_outlined, onPressed: onWithdraw),
            ])),
          loading: () => const AppLoadingState(),
          error: (_, __) => Stack(
            children: [
              ListView(),
              const Center(child: Text('Gagal memuat')),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── WITHDRAWAL REQUEST ──────────────────────────────────
class WithdrawalRequestScreen extends StatefulWidget {
  final VoidCallback onSuccess;
  const WithdrawalRequestScreen({super.key, required this.onSuccess});
  @override
  State<WithdrawalRequestScreen> createState() => _WithdrawalRequestScreenState();
}

class _WithdrawalRequestScreenState extends State<WithdrawalRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _bankCtrl = TextEditingController();
  final _accountCtrl = TextEditingController();
  final _holderCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() { _amountCtrl.dispose(); _bankCtrl.dispose(); _accountCtrl.dispose(); _holderCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Ajukan Pencairan')),
      body: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Form(key: _formKey, child: Column(children: [
        AppTextField(label: 'Nominal (Rp)', hint: '500000', controller: _amountCtrl, validator: (v) => Validators.maxWithdrawal(v, 1540000), keyboardType: TextInputType.number, prefixIcon: Icons.attach_money),
        const SizedBox(height: 16),
        AppTextField(label: 'Nama Bank', hint: 'BCA', controller: _bankCtrl, validator: (v) => Validators.required(v, 'Bank'), prefixIcon: Icons.account_balance),
        const SizedBox(height: 16),
        AppTextField(label: 'Nomor Rekening', hint: '1234567890', controller: _accountCtrl, validator: Validators.accountNumber, keyboardType: TextInputType.number, prefixIcon: Icons.credit_card),
        const SizedBox(height: 16),
        AppTextField(label: 'Nama Pemilik Rekening', hint: 'Budi Santoso', controller: _holderCtrl, validator: (v) => Validators.required(v, 'Nama'), prefixIcon: Icons.person_outlined),
        const SizedBox(height: 24),
        AppButton(label: 'Ajukan Pencairan', isLoading: _isLoading, onPressed: () async {
          if (!_formKey.currentState!.validate()) return;
          setState(() => _isLoading = true);
          try {
            await FarmerService().requestWithdrawal(
              amount: int.parse(_amountCtrl.text),
              bankName: _bankCtrl.text.trim(),
              accountNumber: _accountCtrl.text.trim(),
              accountHolderName: _holderCtrl.text.trim(),
            );
            if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pencairan diajukan. Menunggu approval admin.'), backgroundColor: AppColors.success)); widget.onSuccess(); }
          } on DioException catch (e) {
            if (mounted) { final msg = e.error is ApiException ? (e.error as ApiException).message : 'Gagal mengajukan pencairan.'; ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppColors.error)); }
          } finally { if (mounted) setState(() => _isLoading = false); }
        }),
      ]))),
    );
  }
}
