import 'package:flutter/material.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/utils/status_mapper.dart';
import '../../shared/enums/app_enums.dart';

/// Colored chip for order/dispute/withdrawal status
class AppStatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color? backgroundColor;

  const AppStatusChip({
    super.key,
    required this.label,
    required this.color,
    this.backgroundColor,
  });

  factory AppStatusChip.order(OrderStatus status) {
    return AppStatusChip(
      label: StatusMapper.orderStatusLabel(status),
      color: StatusMapper.orderStatusColor(status),
      backgroundColor: StatusMapper.orderStatusBgColor(status),
    );
  }

  factory AppStatusChip.dispute(DisputeStatus status) {
    return AppStatusChip(
      label: StatusMapper.disputeStatusLabel(status),
      color: StatusMapper.disputeStatusColor(status),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor ?? color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
