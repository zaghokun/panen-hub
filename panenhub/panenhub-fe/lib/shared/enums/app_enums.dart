/// User roles in the PanenHub system
enum UserRole {
  customer,
  farmer,
  admin;

  String toApi() => name;

  static UserRole fromApi(String value) =>
      UserRole.values.firstWhere((e) => e.name == value, orElse: () => UserRole.customer);
}

/// Order status state machine
enum OrderStatus {
  waitingPayment,
  paidEscrow,
  preOrder,
  harvesting,
  sortingQc,
  shipped,
  delivered,
  completed,
  disputed,
  refunded,
  cancelled;

  static const _toApiMap = {
    OrderStatus.waitingPayment: 'waiting_payment',
    OrderStatus.paidEscrow: 'paid_escrow',
    OrderStatus.preOrder: 'pre_order_confirmed',
    OrderStatus.harvesting: 'harvesting',
    OrderStatus.sortingQc: 'sorting_qc',
    OrderStatus.shipped: 'shipped',
    OrderStatus.delivered: 'delivered',
    OrderStatus.completed: 'completed',
    OrderStatus.disputed: 'disputed',
    OrderStatus.refunded: 'refunded',
    OrderStatus.cancelled: 'cancelled',
  };

  static final _fromApiMap = {for (final e in _toApiMap.entries) e.value: e.key};

  String toApi() => _toApiMap[this]!;

  static OrderStatus fromApi(String value) =>
      _fromApiMap[value] ?? OrderStatus.waitingPayment;
}

/// Dispute resolution status
enum DisputeStatus {
  submitted,
  underReview,
  approvedRefund,
  rejectedReleaseToFarmer,
  closed;

  static const _toApiMap = {
    DisputeStatus.submitted: 'submitted',
    DisputeStatus.underReview: 'under_review',
    DisputeStatus.approvedRefund: 'resolved',
    DisputeStatus.rejectedReleaseToFarmer: 'resolved',
    DisputeStatus.closed: 'closed',
  };

  static final _fromApiMap = <String, DisputeStatus>{
    'submitted': DisputeStatus.submitted,
    'under_review': DisputeStatus.underReview,
    'resolved': DisputeStatus.approvedRefund,
    'closed': DisputeStatus.closed,
  };

  String toApi() => _toApiMap[this]!;

  static DisputeStatus fromApi(String value) =>
      _fromApiMap[value] ?? DisputeStatus.submitted;
}

/// Payment escrow status
enum EscrowStatus {
  unpaid,
  waitingVerification,
  paidEscrow,
  failed,
  refunded,
  releasedToFarmer;

  static const _toApiMap = {
    EscrowStatus.unpaid: 'unpaid',
    EscrowStatus.waitingVerification: 'held',
    EscrowStatus.paidEscrow: 'held',
    EscrowStatus.failed: 'unpaid',
    EscrowStatus.refunded: 'refunded',
    EscrowStatus.releasedToFarmer: 'released',
  };

  static final _fromApiMap = <String, EscrowStatus>{
    'unpaid': EscrowStatus.unpaid,
    'held': EscrowStatus.paidEscrow,
    'released': EscrowStatus.releasedToFarmer,
    'refunded': EscrowStatus.refunded,
  };

  String toApi() => _toApiMap[this]!;

  static EscrowStatus fromApi(String value) =>
      _fromApiMap[value] ?? EscrowStatus.unpaid;
}

/// Withdrawal status
enum WithdrawalStatus {
  requested,
  underReview,
  approved,
  rejected,
  paid;

  static const _toApiMap = {
    WithdrawalStatus.requested: 'requested',
    WithdrawalStatus.underReview: 'requested',
    WithdrawalStatus.approved: 'approved',
    WithdrawalStatus.rejected: 'rejected',
    WithdrawalStatus.paid: 'paid',
  };

  static final _fromApiMap = <String, WithdrawalStatus>{
    'requested': WithdrawalStatus.requested,
    'approved': WithdrawalStatus.approved,
    'rejected': WithdrawalStatus.rejected,
    'paid': WithdrawalStatus.paid,
  };

  String toApi() => _toApiMap[this]!;

  static WithdrawalStatus fromApi(String value) =>
      _fromApiMap[value] ?? WithdrawalStatus.requested;
}

/// User account status
enum UserStatus {
  active,
  pendingVerification,
  blocked,
  deleted;

  static const _toApiMap = {
    UserStatus.active: 'active',
    UserStatus.pendingVerification: 'pending_verification',
    UserStatus.blocked: 'blocked',
    UserStatus.deleted: 'inactive',
  };

  static final _fromApiMap = <String, UserStatus>{
    'active': UserStatus.active,
    'pending_verification': UserStatus.pendingVerification,
    'blocked': UserStatus.blocked,
    'inactive': UserStatus.deleted,
  };

  String toApi() => _toApiMap[this]!;

  static UserStatus fromApi(String value) =>
      _fromApiMap[value] ?? UserStatus.active;
}
