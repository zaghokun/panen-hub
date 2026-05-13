/// User roles in the PanenHub system
enum UserRole {
  customer,
  farmer,
  admin,
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
  cancelled,
}

/// Dispute resolution status
enum DisputeStatus {
  submitted,
  underReview,
  approvedRefund,
  rejectedReleaseToFarmer,
  closed,
}

/// Payment escrow status
enum EscrowStatus {
  unpaid,
  waitingVerification,
  paidEscrow,
  failed,
  refunded,
  releasedToFarmer,
}

/// Withdrawal status
enum WithdrawalStatus {
  requested,
  underReview,
  approved,
  rejected,
  paid,
}

/// User account status
enum UserStatus {
  active,
  pendingVerification,
  blocked,
  deleted,
}
