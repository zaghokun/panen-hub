import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../shared/enums/app_enums.dart';

/// Maps order status to human-readable label and color
class StatusMapper {
  StatusMapper._();

  static String orderStatusLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.waitingPayment:
        return 'Menunggu Pembayaran';
      case OrderStatus.paidEscrow:
        return 'Dibayar - Dana Ditahan';
      case OrderStatus.preOrder:
        return 'Pre-Order Aktif';
      case OrderStatus.harvesting:
        return 'Panen';
      case OrderStatus.sortingQc:
        return 'Sortir / QC';
      case OrderStatus.shipped:
        return 'Dikirim';
      case OrderStatus.delivered:
        return 'Diterima';
      case OrderStatus.completed:
        return 'Selesai';
      case OrderStatus.disputed:
        return 'Sengketa';
      case OrderStatus.refunded:
        return 'Refund';
      case OrderStatus.cancelled:
        return 'Dibatalkan';
    }
  }

  static Color orderStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.waitingPayment:
        return AppColors.statusWaiting;
      case OrderStatus.paidEscrow:
        return AppColors.statusPaid;
      case OrderStatus.preOrder:
        return AppColors.statusProcess;
      case OrderStatus.harvesting:
        return AppColors.statusProcess;
      case OrderStatus.sortingQc:
        return AppColors.statusProcess;
      case OrderStatus.shipped:
        return AppColors.statusShipped;
      case OrderStatus.delivered:
        return AppColors.statusDelivered;
      case OrderStatus.completed:
        return AppColors.statusCompleted;
      case OrderStatus.disputed:
        return AppColors.statusDisputed;
      case OrderStatus.refunded:
        return AppColors.statusRefunded;
      case OrderStatus.cancelled:
        return AppColors.statusCancelled;
    }
  }

  static Color orderStatusBgColor(OrderStatus status) {
    return orderStatusColor(status).withValues(alpha: 0.12);
  }

  static String disputeStatusLabel(DisputeStatus status) {
    switch (status) {
      case DisputeStatus.submitted:
        return 'Diajukan';
      case DisputeStatus.underReview:
        return 'Dalam Review';
      case DisputeStatus.approvedRefund:
        return 'Refund Disetujui';
      case DisputeStatus.rejectedReleaseToFarmer:
        return 'Ditolak';
      case DisputeStatus.closed:
        return 'Ditutup';
    }
  }

  static Color disputeStatusColor(DisputeStatus status) {
    switch (status) {
      case DisputeStatus.submitted:
        return AppColors.warning;
      case DisputeStatus.underReview:
        return AppColors.info;
      case DisputeStatus.approvedRefund:
        return AppColors.success;
      case DisputeStatus.rejectedReleaseToFarmer:
        return AppColors.error;
      case DisputeStatus.closed:
        return AppColors.textSecondary;
    }
  }

  static String withdrawalStatusLabel(WithdrawalStatus status) {
    switch (status) {
      case WithdrawalStatus.requested:
        return 'Menunggu';
      case WithdrawalStatus.underReview:
        return 'Dalam Review';
      case WithdrawalStatus.approved:
        return 'Disetujui';
      case WithdrawalStatus.rejected:
        return 'Ditolak';
      case WithdrawalStatus.paid:
        return 'Dicairkan';
    }
  }

  /// Valid next statuses for farmer to update
  static List<OrderStatus> validNextStatuses(OrderStatus current) {
    switch (current) {
      case OrderStatus.paidEscrow:
      case OrderStatus.preOrder:
        return [OrderStatus.harvesting];
      case OrderStatus.harvesting:
        return [OrderStatus.sortingQc];
      case OrderStatus.sortingQc:
        return [OrderStatus.shipped];
      default:
        return [];
    }
  }
}
