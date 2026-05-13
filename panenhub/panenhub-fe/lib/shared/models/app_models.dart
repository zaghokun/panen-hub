import '../../shared/enums/app_enums.dart';

/// Application user entity
class AppUser {
  final String id;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final String? avatarUrl;
  final bool isVerified;
  final String? businessName;
  final String? businessType;
  final String? businessAddress;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.avatarUrl,
    required this.isVerified,
    this.businessName,
    this.businessType,
    this.businessAddress,
  });
}

/// Farmer profile with land information
class FarmerProfile {
  final String id;
  final String userId;
  final String farmName;
  final String address;
  final double landArea;
  final double? latitude;
  final double? longitude;
  final String? photoUrl;
  final String verificationStatus;

  const FarmerProfile({
    required this.id,
    required this.userId,
    required this.farmName,
    required this.address,
    required this.landArea,
    this.latitude,
    this.longitude,
    this.photoUrl,
    required this.verificationStatus,
  });
}

/// Commodity / Harvest offer entity
class Commodity {
  final String id;
  final String farmerId;
  final String farmerName;
  final String name;
  final String category;
  final String description;
  final int pricePerKg;
  final double availableQuotaKg;
  final DateTime estimatedHarvestDate;
  final String location;
  final List<String> imageUrls;
  final bool isActive;
  final double farmerRating;

  const Commodity({
    required this.id,
    required this.farmerId,
    required this.farmerName,
    required this.name,
    required this.category,
    required this.description,
    required this.pricePerKg,
    required this.availableQuotaKg,
    required this.estimatedHarvestDate,
    required this.location,
    required this.imageUrls,
    required this.isActive,
    this.farmerRating = 0.0,
  });
}

/// Pre-order entity
class PreOrder {
  final String id;
  final String customerId;
  final String customerName;
  final String farmerId;
  final String farmerName;
  final String commodityId;
  final String commodityName;
  final double quantityKg;
  final int pricePerKg;
  final int totalPrice;
  final DateTime deliveryDate;
  final OrderStatus status;
  final String deliveryAddress;
  final String? notes;
  final DateTime createdAt;

  const PreOrder({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.farmerId,
    required this.farmerName,
    required this.commodityId,
    required this.commodityName,
    required this.quantityKg,
    required this.pricePerKg,
    required this.totalPrice,
    required this.deliveryDate,
    required this.status,
    required this.deliveryAddress,
    this.notes,
    required this.createdAt,
  });

  PreOrder copyWith({OrderStatus? status}) {
    return PreOrder(
      id: id,
      customerId: customerId,
      customerName: customerName,
      farmerId: farmerId,
      farmerName: farmerName,
      commodityId: commodityId,
      commodityName: commodityName,
      quantityKg: quantityKg,
      pricePerKg: pricePerKg,
      totalPrice: totalPrice,
      deliveryDate: deliveryDate,
      status: status ?? this.status,
      deliveryAddress: deliveryAddress,
      notes: notes,
      createdAt: createdAt,
    );
  }
}

/// Payment entity
class Payment {
  final String id;
  final String orderId;
  final int amount;
  final String method;
  final String virtualAccountNumber;
  final String escrowStatus;
  final DateTime? paidAt;
  final DateTime? expiresAt;

  const Payment({
    required this.id,
    required this.orderId,
    required this.amount,
    required this.method,
    required this.virtualAccountNumber,
    required this.escrowStatus,
    this.paidAt,
    this.expiresAt,
  });
}

/// Quality Control report
class QualityControlReport {
  final String id;
  final String orderId;
  final bool isAccepted;
  final String? note;
  final List<String> evidenceImageUrls;
  final DateTime createdAt;

  const QualityControlReport({
    required this.id,
    required this.orderId,
    required this.isAccepted,
    this.note,
    required this.evidenceImageUrls,
    required this.createdAt,
  });
}

/// Dispute entity
class Dispute {
  final String id;
  final String orderId;
  final String customerId;
  final String customerName;
  final String farmerName;
  final String commodityName;
  final String reason;
  final String description;
  final List<String> evidenceImageUrls;
  final DisputeStatus status;
  final String? adminDecisionNote;
  final int escrowAmount;
  final DateTime createdAt;

  const Dispute({
    required this.id,
    required this.orderId,
    required this.customerId,
    required this.customerName,
    required this.farmerName,
    required this.commodityName,
    required this.reason,
    required this.description,
    required this.evidenceImageUrls,
    required this.status,
    this.adminDecisionNote,
    required this.escrowAmount,
    required this.createdAt,
  });
}

/// Withdrawal request entity
class Withdrawal {
  final String id;
  final String farmerId;
  final String farmerName;
  final int amount;
  final String bankName;
  final String accountNumber;
  final String accountHolderName;
  final WithdrawalStatus status;
  final String? adminNote;
  final DateTime createdAt;

  const Withdrawal({
    required this.id,
    required this.farmerId,
    required this.farmerName,
    required this.amount,
    required this.bankName,
    required this.accountNumber,
    required this.accountHolderName,
    required this.status,
    this.adminNote,
    required this.createdAt,
  });
}

/// Wallet summary for farmer
class WalletSummary {
  final int availableBalance;
  final int heldBalance;
  final int inProcessBalance;
  final int totalDisbursed;

  const WalletSummary({
    required this.availableBalance,
    required this.heldBalance,
    required this.inProcessBalance,
    required this.totalDisbursed,
  });
}

/// Review entity
class Review {
  final String id;
  final String orderId;
  final String customerId;
  final String customerName;
  final String farmerId;
  final int rating;
  final String comment;
  final DateTime createdAt;

  const Review({
    required this.id,
    required this.orderId,
    required this.customerId,
    required this.customerName,
    required this.farmerId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });
}

/// Order status history entry
class OrderStatusHistory {
  final String status;
  final String label;
  final DateTime timestamp;
  final String? note;

  const OrderStatusHistory({
    required this.status,
    required this.label,
    required this.timestamp,
    this.note,
  });
}

/// Notification entity
class AppNotification {
  final String id;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });
}
