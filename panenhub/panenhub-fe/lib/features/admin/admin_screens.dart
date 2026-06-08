import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/widgets/app_button.dart';

import '../../core/widgets/app_status_chip.dart';
import '../../core/widgets/app_loading_state.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../core/widgets/app_confirmation_dialog.dart';
import '../../core/network/services/admin_service.dart';
import '../../core/network/api_exceptions.dart';
import '../../providers/app_providers.dart';
import '../../core/utils/status_mapper.dart';

// ─── ADMIN DASHBOARD ─────────────────────────────────────
class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final disputes = ref.watch(disputeListProvider);
    final withdrawals = ref.watch(withdrawalListProvider);
    final dashboard = ref.watch(adminDashboardProvider);
    final stats = dashboard.valueOrNull;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(adminDashboardProvider);
            ref.invalidate(disputeListProvider);
            ref.invalidate(withdrawalListProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Premium admin header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
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
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Dashboard Admin', style: AppTextStyles.headlineMedium.copyWith(color: Colors.white)),
                      const SizedBox(height: 2),
                      Text('Ringkasan kondisi platform', style: AppTextStyles.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.8))),
                    ]),
                  ]),
                ]),
              ),
              const SizedBox(height: 24),
              Row(children: [
                Container(width: 4, height: 20, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2))),
                const SizedBox(width: 8),
                Text('Statistik Platform', style: AppTextStyles.titleMedium),
              ]),
              const SizedBox(height: 14),
              _AdminStatCard(icon: Icons.person_add, label: 'Menunggu Verifikasi', value: '${stats?['pendingVerifications'] ?? 0}', color: AppColors.warning),
              const SizedBox(height: 10),
              _AdminStatCard(icon: Icons.report_problem, label: 'Sengketa Aktif', value: '${disputes.valueOrNull?.length ?? 0}', color: AppColors.error),
              const SizedBox(height: 10),
              _AdminStatCard(icon: Icons.account_balance_wallet, label: 'Withdrawal Pending', value: '${withdrawals.valueOrNull?.length ?? 0}', color: AppColors.info),
              const SizedBox(height: 10),
              _AdminStatCard(icon: Icons.receipt_long, label: 'Total Transaksi', value: '${stats?['totalOrders'] ?? 0}', color: AppColors.primary),
              const SizedBox(height: 10),
              _AdminStatCard(icon: Icons.eco, label: 'Komoditas Aktif', value: '${stats?['activeCommodities'] ?? 0}', color: AppColors.success),
            ]),
          ),
        ),
      ),
    );
  }
}

class _AdminStatCard extends StatelessWidget {
  final IconData icon; final String label; final String value; final Color color;
  const _AdminStatCard({required this.icon, required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: color, width: 3.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(children: [
        Container(width: 44, height: 44, decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 22)),
        const SizedBox(width: 14),
        Expanded(child: Text(label, style: AppTextStyles.labelLarge)),
        Text(value, style: AppTextStyles.headlineMedium.copyWith(color: color)),
      ]),
    );
  }
}

// ─── USER VERIFICATION ───────────────────────────────────
class UserVerificationScreen extends ConsumerWidget {
  const UserVerificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = ref.watch(pendingUsersProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Verifikasi Pengguna')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(pendingUsersProvider);
        },
        child: pending.when(
          data: (users) {
            if (users.isEmpty) {
              return Stack(
                children: [
                  ListView(),
                  const AppEmptyState(icon: Icons.verified_user, title: 'Semua Terverifikasi', description: 'Tidak ada akun yang menunggu verifikasi.'),
                ],
              );
            }
            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20), 
              itemCount: users.length, 
              itemBuilder: (context, i) {
                final u = users[i];
                return Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border.withValues(alpha: 0.5))),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      CircleAvatar(radius: 20, backgroundColor: AppColors.warningLight, child: Text(u.name[0], style: AppTextStyles.titleMedium.copyWith(color: AppColors.warning))),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(u.name, style: AppTextStyles.labelLarge), Text(u.email, style: AppTextStyles.caption)])),
                      AppStatusChip(label: 'Pending', color: AppColors.warning),
                    ]),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(child: OutlinedButton(onPressed: () async {
                        try {
                          await AdminService().verifyFarmer(u.id, action: 'reject');
                          ref.invalidate(pendingUsersProvider);
                          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Akun ditolak'), backgroundColor: AppColors.error));
                        } on DioException catch (e) {
                          if (context.mounted) { final msg = e.error is ApiException ? (e.error as ApiException).message : 'Gagal menolak akun.'; ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppColors.error)); }
                        }
                      }, style: OutlinedButton.styleFrom(foregroundColor: AppColors.error, side: const BorderSide(color: AppColors.error)), child: const Text('Tolak'))),
                      const SizedBox(width: 10),
                      Expanded(child: ElevatedButton(onPressed: () async {
                        try {
                          await AdminService().verifyFarmer(u.id, action: 'approve');
                          ref.invalidate(pendingUsersProvider);
                          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Akun diverifikasi!'), backgroundColor: AppColors.success));
                        } on DioException catch (e) {
                          if (context.mounted) { final msg = e.error is ApiException ? (e.error as ApiException).message : 'Gagal verifikasi akun.'; ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppColors.error)); }
                        }
                      }, child: const Text('Verifikasi'))),
                    ]),
                  ]),
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

// ─── ADMIN DISPUTE LIST ──────────────────────────────────
class AdminDisputeListScreen extends ConsumerWidget {
  const AdminDisputeListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final disputes = ref.watch(disputeListProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Sengketa')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(disputeListProvider);
        },
        child: disputes.when(
          data: (list) {
            if (list.isEmpty) {
              return Stack(
                children: [
                  ListView(),
                  const AppEmptyState(icon: Icons.gavel, title: 'Tidak Ada Sengketa', description: 'Tidak ada sengketa yang perlu ditinjau.'),
                ],
              );
            }
            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20), 
              itemCount: list.length, 
              itemBuilder: (context, i) {
                final d = list[i];
                return Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border.withValues(alpha: 0.5))),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [Expanded(child: Text(d.orderId, style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600))), AppStatusChip.dispute(d.status)]),
                    const SizedBox(height: 8),
                    Text(d.reason, style: AppTextStyles.labelLarge),
                    Text('Pelanggan: ${d.customerName}', style: AppTextStyles.caption),
                    Text('Petani: ${d.farmerName}', style: AppTextStyles.caption),
                    const Divider(height: 16),
                    Text(d.description, style: AppTextStyles.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    Row(children: [
                      Text('Escrow: ${CurrencyFormatter.format(d.escrowAmount)}', style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary)),
                      const Spacer(),
                      Text(DateFormatter.short(d.createdAt), style: AppTextStyles.caption),
                    ]),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(child: OutlinedButton(onPressed: () async {
                        final r = await AppConfirmationDialog.show(context, title: 'Tolak Sengketa', message: 'Dana escrow akan dicairkan ke petani.', isDanger: true);
                        if (r == true && context.mounted) {
                          try {
                            await AdminService().decideDispute(d.id, decision: 'reject');
                            ref.invalidate(disputeListProvider);
                            if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sengketa ditolak. Dana dicairkan ke petani.'), backgroundColor: AppColors.success));
                          } on DioException catch (e) {
                            if (context.mounted) { final msg = e.error is ApiException ? (e.error as ApiException).message : 'Gagal memproses.'; ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppColors.error)); }
                          }
                        }
                      }, style: OutlinedButton.styleFrom(foregroundColor: AppColors.error, side: const BorderSide(color: AppColors.error)), child: const Text('Tolak'))),
                      const SizedBox(width: 10),
                      Expanded(child: ElevatedButton(onPressed: () async {
                        final r = await AppConfirmationDialog.show(context, title: 'Setujui Refund', message: 'Dana escrow akan dikembalikan ke pelanggan.');
                        if (r == true && context.mounted) {
                          try {
                            await AdminService().decideDispute(d.id, decision: 'approve_refund');
                            ref.invalidate(disputeListProvider);
                            if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Refund disetujui.'), backgroundColor: AppColors.success));
                          } on DioException catch (e) {
                            if (context.mounted) { final msg = e.error is ApiException ? (e.error as ApiException).message : 'Gagal memproses.'; ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppColors.error)); }
                          }
                        }
                      }, child: const Text('Refund'))),
                    ]),
                  ]),
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

// ─── ADMIN WITHDRAWAL APPROVAL ───────────────────────────
class AdminWithdrawalScreen extends ConsumerWidget {
  const AdminWithdrawalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final withdrawals = ref.watch(withdrawalListProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Pencairan Dana')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(withdrawalListProvider);
        },
        child: withdrawals.when(
          data: (list) {
            if (list.isEmpty) {
              return Stack(
                children: [
                  ListView(),
                  const AppEmptyState(icon: Icons.account_balance_wallet, title: 'Tidak Ada Request', description: 'Belum ada pencairan yang perlu diproses.'),
                ],
              );
            }
            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20), 
              itemCount: list.length, 
              itemBuilder: (context, i) {
                final w = list[i];
                return Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border.withValues(alpha: 0.5))),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [Expanded(child: Text(w.farmerName, style: AppTextStyles.labelLarge)), AppStatusChip(label: StatusMapper.withdrawalStatusLabel(w.status), color: AppColors.warning)]),
                    const SizedBox(height: 8),
                    Text(CurrencyFormatter.format(w.amount), style: AppTextStyles.headlineMedium.copyWith(color: AppColors.primary)),
                    const SizedBox(height: 4),
                    Text('${w.bankName} · ${w.accountNumber}', style: AppTextStyles.caption),
                    Text('a.n. ${w.accountHolderName}', style: AppTextStyles.caption),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(child: OutlinedButton(onPressed: () async {
                        try {
                          await AdminService().rejectWithdrawal(w.id, reason: 'Ditolak admin');
                          ref.invalidate(withdrawalListProvider);
                          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pencairan ditolak'), backgroundColor: AppColors.error));
                        } on DioException catch (e) {
                          if (context.mounted) { final msg = e.error is ApiException ? (e.error as ApiException).message : 'Gagal memproses.'; ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppColors.error)); }
                        }
                      }, style: OutlinedButton.styleFrom(foregroundColor: AppColors.error, side: const BorderSide(color: AppColors.error)), child: const Text('Tolak'))),
                      const SizedBox(width: 10),
                      Expanded(child: ElevatedButton(onPressed: () async {
                        try {
                          await AdminService().approveWithdrawal(w.id);
                          ref.invalidate(withdrawalListProvider);
                          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pencairan disetujui!'), backgroundColor: AppColors.success));
                        } on DioException catch (e) {
                          if (context.mounted) { final msg = e.error is ApiException ? (e.error as ApiException).message : 'Gagal memproses.'; ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppColors.error)); }
                        }
                      }, child: const Text('Approve'))),
                    ]),
                  ]),
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

// ─── PROFILE SCREEN ──────────────────────────────────────
class ProfileScreen extends ConsumerWidget {
  final VoidCallback onLogout;
  const ProfileScreen({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final u = auth.user;
    if (u == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Profil')),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(authProvider.notifier).checkSession();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20), 
          child: Column(children: [
            CircleAvatar(radius: 40, backgroundColor: AppColors.primarySurface, child: Text(u.name[0], style: AppTextStyles.displayMedium.copyWith(color: AppColors.primary))),
            const SizedBox(height: 12),
            Text(u.name, style: AppTextStyles.headlineMedium),
            Text(u.email, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            AppStatusChip(label: u.role.name.toUpperCase(), color: AppColors.primary),
            const SizedBox(height: 24),
            _ProfileTile(icon: Icons.phone, label: 'Telepon', value: u.phone),
            if (u.businessName != null) _ProfileTile(icon: Icons.business, label: 'Bisnis', value: u.businessName!),
            if (u.businessAddress != null) _ProfileTile(icon: Icons.location_on, label: 'Alamat', value: u.businessAddress!),
            const SizedBox(height: 24),
            AppButton(label: 'Keluar', isDanger: true, isOutlined: true, icon: Icons.logout, onPressed: () async {
              final confirmed = await AppConfirmationDialog.show(context, title: 'Keluar', message: 'Yakin ingin keluar dari akun?', isDanger: true);
              if (confirmed == true) { ref.read(authProvider.notifier).logout(); onLogout(); }
            }),
          ]),
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon; final String label; final String value;
  const _ProfileTile({required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border.withValues(alpha: 0.5))),
      child: Row(children: [Icon(icon, size: 20, color: AppColors.textSecondary), const SizedBox(width: 12), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: AppTextStyles.caption), Text(value, style: AppTextStyles.bodyMedium)])]),
    );
  }
}

// ─── NOTIFICATION SCREEN ─────────────────────────────────
class NotificationListScreen extends ConsumerWidget {
  const NotificationListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifs = ref.watch(notificationListProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Notifikasi')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(notificationListProvider);
        },
        child: notifs.when(
          data: (list) {
            if (list.isEmpty) {
              return Stack(
                children: [
                  ListView(),
                  const AppEmptyState(icon: Icons.notifications_none, title: 'Tidak Ada Notifikasi', description: 'Belum ada notifikasi baru.'),
                ],
              );
            }
            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20), 
              itemCount: list.length, 
              itemBuilder: (context, i) {
                final n = list[i];
                return GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(n.title), backgroundColor: AppColors.primary));
                  },
                  child: Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: n.isRead ? AppColors.surface : AppColors.primarySurface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border.withValues(alpha: 0.5))),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Icon(n.isRead ? Icons.notifications_none : Icons.notifications, size: 22, color: n.isRead ? AppColors.textSecondary : AppColors.primary),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(n.title, style: AppTextStyles.labelLarge),
                        const SizedBox(height: 2),
                        Text(n.message, style: AppTextStyles.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Text(DateFormatter.dateTime(n.createdAt), style: AppTextStyles.caption),
                      ])),
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
