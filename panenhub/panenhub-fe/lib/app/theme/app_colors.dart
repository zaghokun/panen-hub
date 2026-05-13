import 'package:flutter/material.dart';

/// PanenHub Color Tokens
/// Based on green agriculture professional theme
class AppColors {
  AppColors._();

  // Primary - Green Agriculture
  static const primary = Color(0xFF2E7D32);
  static const primaryDark = Color(0xFF1B5E20);
  static const primaryLight = Color(0xFFA5D6A7);
  static const primarySurface = Color(0xFFE8F5E9);

  // Secondary - Harvest Amber
  static const secondary = Color(0xFFF9A825);
  static const secondaryLight = Color(0xFFFFF8E1);

  // Background & Surface
  static const background = Color(0xFFFAFAF5);
  static const surface = Color(0xFFFFFFFF);
  static const border = Color(0xFFE5E7EB);
  static const divider = Color(0xFFF0F0F0);

  // Text
  static const textPrimary = Color(0xFF1F2933);
  static const textSecondary = Color(0xFF6B7280);
  static const textHint = Color(0xFF9CA3AF);
  static const textOnPrimary = Color(0xFFFFFFFF);

  // Semantic
  static const success = Color(0xFF2E7D32);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFD32F2F);
  static const info = Color(0xFF1976D2);

  // Semantic Light
  static const successLight = Color(0xFFE8F5E9);
  static const warningLight = Color(0xFFFFF8E1);
  static const errorLight = Color(0xFFFFEBEE);
  static const infoLight = Color(0xFFE3F2FD);

  // Status Chip Colors
  static const statusWaiting = Color(0xFFF59E0B);
  static const statusPaid = Color(0xFF1976D2);
  static const statusProcess = Color(0xFF7C3AED);
  static const statusShipped = Color(0xFF0891B2);
  static const statusDelivered = Color(0xFF059669);
  static const statusCompleted = Color(0xFF2E7D32);
  static const statusDisputed = Color(0xFFD32F2F);
  static const statusRefunded = Color(0xFF6B7280);
  static const statusCancelled = Color(0xFF9CA3AF);
}
