import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import '../../providers/app_providers.dart';

import '../../core/utils/status_mapper.dart';
import '../../data/mock_data_source.dart';

class FarmerDashboardScreen extends ConsumerWidget {
  final VoidCallback onAddCommodity;
  const FarmerDashboardScreen({super.key, required this.onAddCommodity});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final wallet = ref.watch(walletProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Dashboard Petani 🌾', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Text(auth.user?.name ?? '', style: AppTextStyles.headlineMedium),
              ])),
              CircleAvatar(radius: 24, backgroundColor: AppColors.primarySurface, child: const Icon(Icons.agriculture, color: AppColors.primary)),
            ]),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.successLight, borderRadius: BorderRadius.circular(10)),
              child: Row(children: [const Icon(Icons.verified, color: AppColors.success, size: 18), const SizedBox(width: 8), Text('Akun terverifikasi', style: AppTextStyles.caption.copyWith(color: AppColors.success))]),
            ),
            const SizedBox(height: 20),
            // Stats
            Row(children: [
              _StatCard(icon: Icons.eco, label: 'Komoditas', value: '${MockDataSource.commodities.where((c) => c.farmerId == auth.user?.id).length}', color: AppColors.primary),
              const SizedBox(width: 12),
              _StatCard(icon: Icons.receipt_long, label: 'Pesanan', value: '${MockDataSource.orders.where((o) => o.farmerId == auth.user?.id).length}', color: AppColors.info),
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
            const SizedBox(height: 24),
            Text('Aksi Cepat', style: AppTextStyles.titleMedium),
            const SizedBox(height: 12),
            AppButton(label: 'Posting Estimasi Panen', icon: Icons.add_circle_outline, onPressed: onAddCommodity),
            const SizedBox(height: 32),
          ]),
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border.withValues(alpha: 0.5))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 22, color: color),
        const SizedBox(height: 8),
        Text(value, style: AppTextStyles.titleMedium.copyWith(color: color)),
        Text(label, style: AppTextStyles.caption),
      ]),
    ));
  }
}

// ─── FARMER COMMODITY LIST ───────────────────────────────
class FarmerCommodityListScreen extends ConsumerWidget {
  final VoidCallback onAdd;
  const FarmerCommodityListScreen({super.key, required this.onAdd});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commodities = ref.watch(farmerCommodityListProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Komoditas Saya')),
      floatingActionButton: FloatingActionButton(onPressed: onAdd, backgroundColor: AppColors.primary, child: const Icon(Icons.add, color: Colors.white)),
      body: commodities.when(
        data: (list) {
          if (list.isEmpty) return const AppEmptyState(icon: Icons.eco_outlined, title: 'Belum Ada Komoditas', description: 'Posting estimasi panen pertama Anda.');
          return ListView.builder(padding: const EdgeInsets.all(20), itemCount: list.length, itemBuilder: (context, i) {
            final c = list[i];
            return Container(
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
            );
          });
        },
        loading: () => const AppLoadingState(),
        error: (_, __) => const Center(child: Text('Gagal memuat data')),
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
            setState(() => _isLoading = true); await Future.delayed(const Duration(seconds: 1)); setState(() => _isLoading = false);
            if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Komoditas berhasil diposting!'), backgroundColor: AppColors.success)); widget.onSuccess(); }
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(orderListProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Pesanan Masuk')),
      body: orders.when(
        data: (list) {
          if (list.isEmpty) return const AppEmptyState(icon: Icons.receipt_long_outlined, title: 'Belum Ada Pesanan', description: 'Belum ada pre-order masuk.');
          return ListView.builder(padding: const EdgeInsets.all(20), itemCount: list.length, itemBuilder: (context, i) {
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
                      Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(6)),
                        child: Text('Update Status', style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary))),
                  ]),
                ]),
              ),
            );
          });
        },
        loading: () => const AppLoadingState(),
        error: (_, __) => const Center(child: Text('Gagal memuat')),
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
      body: wallet.when(
        data: (w) => SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
        error: (_, __) => const Center(child: Text('Gagal memuat')),
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
          setState(() => _isLoading = true); await Future.delayed(const Duration(seconds: 1)); setState(() => _isLoading = false);
          if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pencairan diajukan. Menunggu approval admin.'), backgroundColor: AppColors.success)); widget.onSuccess(); }
        }),
      ]))),
    );
  }
}
