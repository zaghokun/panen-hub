import '../enums/app_enums.dart';

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

  factory AppUser.fromJson(Map<String, dynamic> json) {
    final profile = json['customerProfile'] as Map<String, dynamic>?;
    final farmerProfile = json['farmerProfile'] as Map<String, dynamic>?;
    return AppUser(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: (json['phone'] as String?) ?? '',
      role: UserRole.fromApi(json['role'] as String),
      avatarUrl: farmerProfile?['photoUrl'] as String?,
      isVerified: farmerProfile?['verificationStatus'] == 'verified',
      businessName: profile?['businessName'] as String?,
      businessType: profile?['businessType'] as String?,
      businessAddress: profile?['businessAddress'] as String?,
    );
  }
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

  factory FarmerProfile.fromJson(Map<String, dynamic> json) => FarmerProfile(
    id: json['id'] as String,
    userId: json['userId'] as String,
    farmName: json['farmName'] as String,
    address: json['address'] as String,
    landArea: (json['landArea'] as num).toDouble(),
    latitude: (json['latitude'] as num?)?.toDouble(),
    longitude: (json['longitude'] as num?)?.toDouble(),
    photoUrl: json['photoUrl'] as String?,
    verificationStatus: json['verificationStatus'] as String? ?? 'pending',
  );
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

  factory Commodity.fromJson(Map<String, dynamic> json) {
    final farmer = json['farmer'] as Map<String, dynamic>?;
    return Commodity(
      id: json['id'] as String,
      farmerId: json['farmerId'] as String,
      farmerName: farmer?['name'] as String? ?? '',
      name: json['name'] as String,
      category: json['category'] as String,
      description: (json['description'] as String?) ?? '',
      pricePerKg: json['pricePerKg'] as int,
      availableQuotaKg: (json['availableQuotaKg'] as num).toDouble(),
      estimatedHarvestDate: DateTime.parse(json['estimatedHarvestDate'] as String),
      location: json['location'] as String,
      imageUrls: json['imageUrl'] != null ? [json['imageUrl'] as String] : [],
      isActive: json['status'] == 'active',
    );
  }
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

  factory PreOrder.fromJson(Map<String, dynamic> json) {
    final commodity = json['commodity'] as Map<String, dynamic>?;
    final customer = json['customer'] as Map<String, dynamic>?;
    final farmer = json['farmer'] as Map<String, dynamic>?;
    return PreOrder(
      id: json['id'] as String,
      customerId: json['customerId'] as String,
      customerName: customer?['name'] as String? ?? '',
      farmerId: json['farmerId'] as String,
      farmerName: farmer?['name'] as String? ?? '',
      commodityId: json['commodityId'] as String,
      commodityName: commodity?['name'] as String? ?? '',
      quantityKg: (json['quantityKg'] as num).toDouble(),
      pricePerKg: json['pricePerKg'] as int,
      totalPrice: json['totalPrice'] as int,
      deliveryDate: DateTime.parse(json['deliveryDate'] as String),
      status: OrderStatus.fromApi(json['status'] as String),
      deliveryAddress: json['deliveryAddress'] as String,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  PreOrder copyWith({OrderStatus? status}) => PreOrder(
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

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
    id: json['id'] as String? ?? '',
    orderId: json['orderId'] as String? ?? '',
    amount: json['amount'] as int,
    method: json['method'] as String? ?? 'bank_transfer',
    virtualAccountNumber: json['paymentReference'] as String? ?? '',
    escrowStatus: json['escrowStatus'] as String? ?? 'unpaid',
    paidAt: json['paidAt'] != null ? DateTime.parse(json['paidAt'] as String) : null,
    expiresAt: null,
  );
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

  factory QualityControlReport.fromJson(Map<String, dynamic> json) => QualityControlReport(
    id: json['id'] as String,
    orderId: json['orderId'] as String,
    isAccepted: json['conditionStatus'] == 'good' && json['quantityStatus'] == 'complete',
    note: json['qualityNotes'] as String?,
    evidenceImageUrls: json['photoUrl'] != null ? [json['photoUrl'] as String] : [],
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
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

  factory Dispute.fromJson(Map<String, dynamic> json) {
    final customer = json['customer'] as Map<String, dynamic>?;
    final farmer = json['farmer'] as Map<String, dynamic>?;
    final order = json['order'] as Map<String, dynamic>?;
    final commodity = order?['commodity'] as Map<String, dynamic>?;
    final evidences = json['evidences'] as List<dynamic>?;
    return Dispute(
      id: json['id'] as String,
      orderId: json['orderId'] as String,
      customerId: json['customerId'] as String,
      customerName: customer?['name'] as String? ?? '',
      farmerName: farmer?['name'] as String? ?? '',
      commodityName: commodity?['name'] as String? ?? '',
      reason: json['reason'] as String,
      description: json['description'] as String,
      evidenceImageUrls: evidences?.map((e) => (e as Map<String, dynamic>)['fileUrl'] as String).toList() ?? [],
      status: DisputeStatus.fromApi(json['status'] as String),
      adminDecisionNote: json['adminNotes'] as String?,
      escrowAmount: order?['totalPrice'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
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

  factory Withdrawal.fromJson(Map<String, dynamic> json) {
    final farmer = json['farmer'] as Map<String, dynamic>?;
    return Withdrawal(
      id: json['id'] as String,
      farmerId: json['farmerId'] as String,
      farmerName: farmer?['name'] as String? ?? '',
      amount: json['amount'] as int,
      bankName: json['bankName'] as String,
      accountNumber: json['accountNumber'] as String,
      accountHolderName: json['accountHolderName'] as String,
      status: WithdrawalStatus.fromApi(json['status'] as String),
      adminNote: json['adminNotes'] as String?,
      createdAt: DateTime.parse(json['requestedAt'] as String),
    );
  }
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

  factory WalletSummary.fromJson(Map<String, dynamic> json) => WalletSummary(
    availableBalance: json['balanceAvailable'] as int? ?? 0,
    heldBalance: json['balancePending'] as int? ?? 0,
    inProcessBalance: 0,
    totalDisbursed: json['totalEarned'] as int? ?? 0,
  );
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

  factory Review.fromJson(Map<String, dynamic> json) {
    final customer = json['customer'] as Map<String, dynamic>?;
    return Review(
      id: json['id'] as String,
      orderId: json['orderId'] as String,
      customerId: json['customerId'] as String,
      customerName: customer?['name'] as String? ?? '',
      farmerId: json['farmerId'] as String,
      rating: json['rating'] as int,
      comment: json['comment'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
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

  factory OrderStatusHistory.fromJson(Map<String, dynamic> json) {
    final status = json['status'] as String;
    return OrderStatusHistory(
      status: status,
      label: _statusLabel(status),
      timestamp: DateTime.parse(json['createdAt'] as String),
      note: json['notes'] as String?,
    );
  }

  static String _statusLabel(String status) => switch (status) {
    'waiting_payment' => 'Menunggu Pembayaran',
    'paid_escrow' => 'Dibayar (Escrow)',
    'pre_order_confirmed' => 'Pre-order Dikonfirmasi',
    'harvesting' => 'Sedang Dipanen',
    'sorting_qc' => 'Sortir & QC',
    'shipped' => 'Dikirim',
    'delivered' => 'Diterima',
    'completed' => 'Selesai',
    'disputed' => 'Sengketa',
    'refunded' => 'Refund',
    _ => status,
  };
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

  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
    id: json['id'] as String,
    title: json['title'] as String,
    message: json['message'] as String,
    type: json['type'] as String,
    isRead: json['isRead'] as bool? ?? false,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}
