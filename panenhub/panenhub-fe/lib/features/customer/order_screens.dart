import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/app_status_chip.dart';
import '../../core/widgets/app_loading_state.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../core/widgets/app_confirmation_dialog.dart';
import '../../core/network/services/order_service.dart';
import '../../core/network/services/payment_service.dart';
import '../../core/network/services/qc_service.dart';
import '../../core/network/services/dispute_service.dart';
import '../../core/network/services/review_service.dart';
import '../../core/network/api_exceptions.dart';
import '../../providers/app_providers.dart';
import '../../shared/enums/app_enums.dart';


// ─── CREATE PREORDER SCREEN ──────────────────────────────
class CreatePreOrderScreen extends ConsumerStatefulWidget {
  final String commodityId;
  final VoidCallback onSuccess;
  const CreatePreOrderScreen({super.key, required this.commodityId, required this.onSuccess});

  @override
  ConsumerState<CreatePreOrderScreen> createState() => _CreatePreOrderScreenState();
}

class _CreatePreOrderScreenState extends ConsumerState<CreatePreOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _qtyController = TextEditingController();
  final _addressController = TextEditingController(text: 'Jl. Pemuda No. 45, Semarang');
  final _notesController = TextEditingController();
  DateTime? _deliveryDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _qtyController.addListener(() => setState(() {}));
  }

  @override
  void dispose() { _qtyController.dispose(); _addressController.dispose(); _notesController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final commodity = ref.watch(commodityDetailProvider(widget.commodityId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Buat Pre-Order')),
      body: commodity.when(
        data: (c) => SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
          child: Form(
            key: _formKey,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Commodity summary
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
                child: Row(children: [
                  Container(width: 48, height: 48, decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.eco, color: AppColors.primary)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(c.name, style: AppTextStyles.labelLarge),
                    Text('${CurrencyFormatter.formatPerKg(c.pricePerKg)} · Kuota: ${c.availableQuotaKg.toStringAsFixed(0)} kg', style: AppTextStyles.caption),
                  ])),
                ]),
              ),
              const SizedBox(height: 24),
              AppTextField(label: 'Jumlah (kg)', hint: 'Masukkan jumlah kg', controller: _qtyController, validator: (v) => Validators.maxQuantity(v, c.availableQuotaKg), keyboardType: TextInputType.number, prefixIcon: Icons.scale_outlined),
              const SizedBox(height: 16),
              // Delivery date
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Tanggal Pengiriman', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () async {
                    final date = await showDatePicker(context: context, initialDate: c.estimatedHarvestDate.add(const Duration(days: 2)), firstDate: c.estimatedHarvestDate, lastDate: DateTime.now().add(const Duration(days: 180)));
                    if (date != null) setState(() => _deliveryDate = date);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                    child: Row(children: [
                      const Icon(Icons.calendar_today, size: 18, color: AppColors.textSecondary),
                      const SizedBox(width: 10),
                      Text(_deliveryDate != null ? DateFormatter.full(_deliveryDate!) : 'Pilih tanggal pengiriman', style: TextStyle(fontSize: 14, color: _deliveryDate != null ? AppColors.textPrimary : AppColors.textHint)),
                    ]),
                  ),
                ),
              ]),
              const SizedBox(height: 16),
              AppTextField(label: 'Alamat Pengiriman', hint: 'Alamat lengkap', controller: _addressController, validator: (v) => Validators.required(v, 'Alamat'), prefixIcon: Icons.location_on_outlined, maxLines: 2),
              const SizedBox(height: 16),
              AppTextField(label: 'Catatan (Opsional)', hint: 'Catatan tambahan untuk petani', controller: _notesController, maxLines: 3, prefixIcon: Icons.note_outlined),
              const SizedBox(height: 24),
              // Summary
              if (_qtyController.text.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(14)),
                  child: Column(children: [
                    _SummaryRow('Harga per kg', CurrencyFormatter.formatPerKg(c.pricePerKg)),
                    _SummaryRow('Jumlah', '${_qtyController.text} kg'),
                    const Divider(height: 20),
                    _SummaryRow('Total', CurrencyFormatter.format(c.pricePerKg * (double.tryParse(_qtyController.text) ?? 0).toInt()), isBold: true),
                  ]),
                ),
                const SizedBox(height: 24),
              ],
              AppButton(label: 'Konfirmasi Pre-Order', isLoading: _isLoading, onPressed: () async {
                if (!_formKey.currentState!.validate()) return;
                if (_deliveryDate == null) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih tanggal pengiriman'), backgroundColor: AppColors.error)); return; }
                final confirmed = await AppConfirmationDialog.show(context, title: 'Konfirmasi Pre-Order', message: 'Anda akan memesan ${_qtyController.text} kg ${c.name} untuk dikirim pada ${DateFormatter.full(_deliveryDate!)}.');
                if (confirmed == true) {
                  setState(() => _isLoading = true);
                  try {
                    await OrderService().create(
                      commodityId: widget.commodityId,
                      quantityKg: double.parse(_qtyController.text),
                      deliveryDate: _deliveryDate!.toUtc().toIso8601String(),
                      deliveryAddress: _addressController.text.trim(),
                      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
                    );
                    ref.invalidate(orderListProvider);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pre-order berhasil! Lanjutkan ke pembayaran.'), backgroundColor: AppColors.success));
                      widget.onSuccess();
                    }
                  } on DioException catch (e) {
                    if (mounted) {
                      final msg = e.error is ApiException ? (e.error as ApiException).message : 'Gagal membuat pre-order.';
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppColors.error));
                    }
                  } finally {
                    if (mounted) setState(() => _isLoading = false);
                  }
                }
              }),
              const SizedBox(height: 32),
            ]),
          ),
        ),
        loading: () => const AppLoadingState(),
        error: (_, __) => const Center(child: Text('Gagal memuat data')),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label; final String value; final bool isBold;
  const _SummaryRow(this.label, this.value, {this.isBold = false});
  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: isBold ? AppTextStyles.labelLarge : AppTextStyles.bodyMedium),
      Text(value, style: isBold ? AppTextStyles.labelLarge.copyWith(color: AppColors.primary) : AppTextStyles.bodyMedium),
    ]));
  }
}

// ─── ORDER LIST SCREEN ───────────────────────────────────
class OrderListScreen extends ConsumerWidget {
  final void Function(String id) onOrderTap;
  const OrderListScreen({super.key, required this.onOrderTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(orderListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Pesanan Saya')),
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
                  const AppEmptyState(icon: Icons.receipt_long_outlined, title: 'Belum Ada Pesanan', description: 'Belum ada pre-order aktif. Cari komoditas segar dan mulai booking panen.'),
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
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border.withValues(alpha: 0.5))),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Expanded(child: Text(o.id, style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600))),
                        AppStatusChip.order(o.status),
                      ]),
                      const SizedBox(height: 8),
                      Text(o.commodityName, style: AppTextStyles.labelLarge),
                      const SizedBox(height: 4),
                      Text('${o.farmerName} · ${o.quantityKg.toStringAsFixed(0)} kg', style: AppTextStyles.caption),
                      const Divider(height: 20),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text(CurrencyFormatter.format(o.totalPrice), style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary)),
                        Text(DateFormatter.short(o.deliveryDate), style: AppTextStyles.caption),
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
              const Center(child: Text('Gagal memuat pesanan')),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── ORDER DETAIL SCREEN ─────────────────────────────────
class OrderDetailScreen extends ConsumerWidget {
  final String orderId;
  final VoidCallback? onQC;
  final VoidCallback? onDispute;
  final VoidCallback? onReview;
  const OrderDetailScreen({super.key, required this.orderId, this.onQC, this.onDispute, this.onReview});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = ref.watch(orderDetailProvider(orderId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Detail Pesanan')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(orderDetailProvider(orderId));
        },
        child: order.when(
          data: (o) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Status header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(16)),
                child: Column(children: [
                  AppStatusChip.order(o.status),
                  const SizedBox(height: 8),
                  Text(o.id, style: AppTextStyles.labelMedium),
                ]),
              ),
              const SizedBox(height: 20),
              // Timeline
              Text('Status Rantai Pasok', style: AppTextStyles.titleMedium),
              const SizedBox(height: 12),
              _buildTimeline(o.status),
              const SizedBox(height: 20),
              // Info
              _DetailSection(title: 'Komoditas', children: [
                _DetailRow('Nama', o.commodityName),
                _DetailRow('Jumlah', '${o.quantityKg.toStringAsFixed(0)} kg'),
                _DetailRow('Harga/kg', CurrencyFormatter.formatPerKg(o.pricePerKg)),
              ]),
              _DetailSection(title: 'Petani', children: [_DetailRow('Nama', o.farmerName)]),
              _DetailSection(title: 'Pengiriman', children: [
                _DetailRow('Alamat', o.deliveryAddress),
                _DetailRow('Tanggal', DateFormatter.full(o.deliveryDate)),
              ]),
              _DetailSection(title: 'Pembayaran', children: [
                _DetailRow('Total', CurrencyFormatter.format(o.totalPrice)),
                _DetailRow('Escrow', 'Dana ditahan aman'),
              ]),
              const SizedBox(height: 20),
              // CTAs — only show customer-specific actions for customers
              if (ref.read(authProvider).role == UserRole.customer) ...[
                if (o.status == OrderStatus.shipped) ...[
                  AppButton(label: 'Konfirmasi Penerimaan', icon: Icons.check_circle_outline, onPressed: () async {
                    final accepted = await AppConfirmationDialog.show(context, title: 'Konfirmasi Penerimaan', message: 'Apakah barang sudah diterima?');
                    if (accepted == true) {
                      try {
                        await OrderService().confirmReceipt(o.id);
                        ref.invalidate(orderListProvider);
                        if (context.mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Penerimaan dikonfirmasi. Silakan lakukan Quality Control.'), backgroundColor: AppColors.success)); Navigator.of(context).pop(); }
                      } on DioException catch (e) {
                        if (context.mounted) { final msg = e.error is ApiException ? (e.error as ApiException).message : 'Gagal konfirmasi penerimaan.'; ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppColors.error)); }
                      }
                    }
                  }),
                ],
                if (o.status == OrderStatus.delivered) ...[
                  AppButton(label: 'Submit Quality Control', icon: Icons.fact_check_outlined, onPressed: () async {
                    final accepted = await AppConfirmationDialog.show(context, title: 'Quality Control', message: 'Apakah barang dalam kondisi BAIK dan jumlah SESUAI? Jika ya, dana akan dirilis ke petani dan pesanan selesai.');
                    if (accepted == true) {
                      try {
                        await QcService().submit(o.id, conditionStatus: 'good', quantityStatus: 'complete');
                        ref.invalidate(orderListProvider);
                        if (context.mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('QC berhasil. Pesanan selesai, dana dirilis ke petani.'), backgroundColor: AppColors.success)); Navigator.of(context).pop(); }
                      } on DioException catch (e) {
                        if (context.mounted) { final msg = e.error is ApiException ? (e.error as ApiException).message : 'Gagal submit QC.'; ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppColors.error)); }
                      }
                    }
                  }),
                  const SizedBox(height: 8),
                  AppButton(label: 'Barang Tidak Sesuai (Sengketa)', isOutlined: true, isDanger: true, icon: Icons.report_problem_outlined, onPressed: onDispute),
                ],
                if (o.status == OrderStatus.completed) ...[
                  AppButton(label: 'Beri Ulasan', icon: Icons.star_outline, onPressed: onReview),
                ],
                if (o.status == OrderStatus.waitingPayment) ...[
                  AppButton(label: 'Bayar Sekarang', icon: Icons.payment, onPressed: () async {
                    try {
                      await PaymentService().create(o.id);
                      ref.invalidate(orderListProvider);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pembayaran berhasil! Dana ditahan di escrow.'), backgroundColor: AppColors.success));
                        Navigator.of(context).pop();
                      }
                    } on DioException catch (e) {
                      if (context.mounted) { final msg = e.error is ApiException ? (e.error as ApiException).message : 'Gagal memproses pembayaran.'; ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppColors.error)); }
                    }
                  }),
                ],
              ],
              const SizedBox(height: 32),
            ]),
          ),
          loading: () => const AppLoadingState(),
          error: (_, __) => Stack(
            children: [
              ListView(),
              const Center(child: Text('Gagal memuat detail')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeline(OrderStatus current) {
    final steps = [
      ('Pre-Order', OrderStatus.waitingPayment),
      ('Dibayar', OrderStatus.paidEscrow),
      ('Panen', OrderStatus.harvesting),
      ('Sortir/QC', OrderStatus.sortingQc),
      ('Dikirim', OrderStatus.shipped),
      ('Diterima', OrderStatus.delivered),
      ('Selesai', OrderStatus.completed),
    ];
    int currentIndex = steps.indexWhere((s) => s.$2 == current);
    // Handle non-linear statuses (disputed, refunded, cancelled)
    // Show them as the last known step in the main flow
    if (currentIndex == -1) {
      if (current == OrderStatus.disputed || current == OrderStatus.refunded) {
        // Show up to delivered as completed, then add the special status
        currentIndex = steps.indexWhere((s) => s.$2 == OrderStatus.delivered);
      } else if (current == OrderStatus.cancelled) {
        currentIndex = 0; // cancelled early, show only first step
      }
    }

    return Column(
      children: steps.asMap().entries.map((entry) {
        final i = entry.key;
        final step = entry.value;
        final done = i <= currentIndex;
        final isLast = i == steps.length - 1;
        return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Column(children: [
            Container(width: 24, height: 24, decoration: BoxDecoration(shape: BoxShape.circle, color: done ? AppColors.primary : AppColors.border), child: done ? const Icon(Icons.check, size: 14, color: Colors.white) : null),
            if (!isLast) Container(width: 2, height: 28, color: done ? AppColors.primary : AppColors.border),
          ]),
          const SizedBox(width: 12),
          Padding(padding: const EdgeInsets.only(top: 2), child: Text(step.$1, style: AppTextStyles.bodyMedium.copyWith(color: done ? AppColors.textPrimary : AppColors.textHint, fontWeight: done ? FontWeight.w600 : FontWeight.w400))),
        ]);
      }).toList(),
    );
  }
}

class _DetailSection extends StatelessWidget {
  final String title; final List<Widget> children;
  const _DetailSection({required this.title, required this.children});
  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.only(bottom: 16), child: Container(
      width: double.infinity, padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border.withValues(alpha: 0.5))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: AppTextStyles.labelLarge), const SizedBox(height: 8), ...children]),
    ));
  }
}

class _DetailRow extends StatelessWidget {
  final String label; final String value;
  const _DetailRow(this.label, this.value);
  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.only(bottom: 4), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: AppTextStyles.caption), Flexible(child: Text(value, style: AppTextStyles.bodyMedium, textAlign: TextAlign.end)),
    ]));
  }
}

// ─── DISPUTE SCREEN ──────────────────────────────────────
class CreateDisputeScreen extends StatefulWidget {
  final String orderId;
  final VoidCallback onSuccess;
  const CreateDisputeScreen({super.key, required this.orderId, required this.onSuccess});

  @override
  State<CreateDisputeScreen> createState() => _CreateDisputeScreenState();
}

class _CreateDisputeScreenState extends State<CreateDisputeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final _descController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() { _reasonController.dispose(); _descController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Ajukan Sengketa')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.warningLight, borderRadius: BorderRadius.circular(12)),
            child: Row(children: [const Icon(Icons.info_outline, color: AppColors.warning), const SizedBox(width: 8), Expanded(child: Text('Laporkan masalah kualitas dengan bukti agar admin dapat meninjau.', style: AppTextStyles.caption.copyWith(color: AppColors.warning)))])),
          const SizedBox(height: 20),
          AppTextField(label: 'Alasan', hint: 'Barang busuk / rusak / kurang jumlah', controller: _reasonController, validator: (v) => Validators.required(v, 'Alasan'), prefixIcon: Icons.report_outlined),
          const SizedBox(height: 16),
          AppTextField(label: 'Deskripsi Masalah', hint: 'Jelaskan detail masalah (min. 20 karakter)', controller: _descController, validator: (v) => Validators.minLength(v, 20, 'Deskripsi'), maxLines: 4, prefixIcon: Icons.description_outlined),
          const SizedBox(height: 16),
          Text('Foto Bukti', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fitur upload foto akan segera hadir'), backgroundColor: AppColors.info));
            },
            child: Container(
              height: 100, width: double.infinity,
              decoration: BoxDecoration(border: Border.all(color: AppColors.border, style: BorderStyle.solid), borderRadius: BorderRadius.circular(12)),
              child: const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.camera_alt_outlined, color: AppColors.textHint, size: 28), SizedBox(height: 4), Text('Tambah Foto Bukti', style: TextStyle(color: AppColors.textHint, fontSize: 12))])),
            ),
          ),
          const SizedBox(height: 24),
          AppButton(label: 'Kirim Sengketa', isDanger: true, isLoading: _isLoading, onPressed: () async {
            if (!_formKey.currentState!.validate()) return;
            setState(() => _isLoading = true);
            try {
              await DisputeService().create(widget.orderId, reason: _reasonController.text.contains('busuk') || _reasonController.text.contains('rusak') ? 'quality_issue' : 'other', description: _descController.text.trim());
              if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sengketa berhasil diajukan. Admin akan meninjau.'), backgroundColor: AppColors.success)); widget.onSuccess(); }
            } on DioException catch (e) {
              if (mounted) { final msg = e.error is ApiException ? (e.error as ApiException).message : 'Gagal mengajukan sengketa.'; ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppColors.error)); }
            } finally { if (mounted) setState(() => _isLoading = false); }
          }),
        ])),
      ),
    );
  }
}

// ─── REVIEW SCREEN ───────────────────────────────────────
class CreateReviewScreen extends StatefulWidget {
  final String orderId;
  final VoidCallback onSuccess;
  const CreateReviewScreen({super.key, required this.orderId, required this.onSuccess});

  @override
  State<CreateReviewScreen> createState() => _CreateReviewScreenState();
}

class _CreateReviewScreenState extends State<CreateReviewScreen> {
  int _rating = 0;
  final _commentController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() { _commentController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Beri Ulasan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          const SizedBox(height: 20),
          Text('Bagaimana pengalaman Anda?', style: AppTextStyles.titleLarge),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(5, (i) => GestureDetector(
            onTap: () => setState(() => _rating = i + 1),
            child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: Icon(i < _rating ? Icons.star : Icons.star_border, size: 44, color: AppColors.secondary)),
          ))),
          const SizedBox(height: 8),
          Text(_rating == 0 ? 'Tap bintang untuk memberi rating' : '$_rating/5', style: AppTextStyles.caption),
          const SizedBox(height: 24),
          AppTextField(label: 'Komentar', hint: 'Ceritakan pengalaman Anda (opsional)', controller: _commentController, maxLines: 4, maxLength: 500),
          const SizedBox(height: 24),
          AppButton(label: 'Kirim Ulasan', isLoading: _isLoading, onPressed: _rating == 0 ? null : () async {
            setState(() => _isLoading = true);
            try {
              await ReviewService().create(widget.orderId, rating: _rating, comment: _commentController.text.trim().isEmpty ? 'Bagus' : _commentController.text.trim());
              if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ulasan berhasil dikirim!'), backgroundColor: AppColors.success)); widget.onSuccess(); }
            } on DioException catch (e) {
              if (mounted) { final msg = e.error is ApiException ? (e.error as ApiException).message : 'Gagal mengirim ulasan.'; ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppColors.error)); }
            } finally { if (mounted) setState(() => _isLoading = false); }
          }),
        ]),
      ),
    );
  }
}
