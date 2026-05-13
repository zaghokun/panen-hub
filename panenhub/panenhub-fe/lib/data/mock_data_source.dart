import '../shared/enums/app_enums.dart';
import '../shared/models/app_models.dart';

/// Mock data source with realistic Indonesian agricultural data
class MockDataSource {
  MockDataSource._();

  // ─── USERS ────────────────────────────────────────────
  static const customerUser = AppUser(
    id: 'USR001',
    name: 'Restoran Segar Jaya',
    email: 'customer@panenhub.test',
    phone: '081234567890',
    role: UserRole.customer,
    isVerified: true,
    businessName: 'Restoran Segar Jaya',
    businessType: 'Restoran',
    businessAddress: 'Jl. Pemuda No. 45, Semarang',
  );

  static const farmerUser = AppUser(
    id: 'USR002',
    name: 'Pak Budi Santoso',
    email: 'farmer@panenhub.test',
    phone: '081298765432',
    role: UserRole.farmer,
    isVerified: true,
  );

  static const adminUser = AppUser(
    id: 'USR003',
    name: 'Admin PanenHub',
    email: 'admin@panenhub.test',
    phone: '081200000001',
    role: UserRole.admin,
    isVerified: true,
  );

  static const pendingFarmer = AppUser(
    id: 'USR004',
    name: 'Bu Sari Wulandari',
    email: 'sari@example.com',
    phone: '081377889900',
    role: UserRole.farmer,
    isVerified: false,
  );

  static const pendingFarmer2 = AppUser(
    id: 'USR005',
    name: 'Pak Heru Prasetyo',
    email: 'heru@example.com',
    phone: '081366778899',
    role: UserRole.farmer,
    isVerified: false,
  );

  // ─── FARMER PROFILE ──────────────────────────────────
  static const farmerProfile = FarmerProfile(
    id: 'FP001',
    userId: 'USR002',
    farmName: 'Kebun Subur Makmur',
    address: 'Desa Bandungan, Kab. Semarang, Jawa Tengah',
    landArea: 2.5,
    latitude: -7.2167,
    longitude: 110.3400,
    verificationStatus: 'verified',
  );

  // ─── COMMODITIES ──────────────────────────────────────
  static final commodities = [
    Commodity(
      id: 'CMD001',
      farmerId: 'USR002',
      farmerName: 'Pak Budi Santoso',
      name: 'Cabai Merah Keriting',
      category: 'Bumbu',
      description: 'Cabai merah keriting segar dari kebun dataran tinggi Bandungan. Dipanen langsung saat matang sempurna untuk menjaga kualitas rasa pedas dan warna merah cerah.',
      pricePerKg: 32000,
      availableQuotaKg: 120,
      estimatedHarvestDate: DateTime.now().add(const Duration(days: 14)),
      location: 'Bandungan, Semarang',
      imageUrls: [],
      isActive: true,
      farmerRating: 4.8,
    ),
    Commodity(
      id: 'CMD002',
      farmerId: 'USR002',
      farmerName: 'Pak Budi Santoso',
      name: 'Tomat Segar',
      category: 'Sayur',
      description: 'Tomat merah segar kualitas premium untuk kebutuhan restoran dan katering. Ukuran seragam, daging tebal, cocok untuk saus dan masakan.',
      pricePerKg: 14000,
      availableQuotaKg: 250,
      estimatedHarvestDate: DateTime.now().add(const Duration(days: 21)),
      location: 'Ungaran, Semarang',
      imageUrls: [],
      isActive: true,
      farmerRating: 4.8,
    ),
    Commodity(
      id: 'CMD003',
      farmerId: 'USR004',
      farmerName: 'Bu Sari Wulandari',
      name: 'Bawang Merah Brebes',
      category: 'Bumbu',
      description: 'Bawang merah asli Brebes, kualitas ekspor. Aroma kuat dan tahan lama disimpan. Cocok untuk bumbu dasar restoran.',
      pricePerKg: 28000,
      availableQuotaKg: 300,
      estimatedHarvestDate: DateTime.now().add(const Duration(days: 10)),
      location: 'Brebes, Jawa Tengah',
      imageUrls: [],
      isActive: true,
      farmerRating: 4.5,
    ),
    Commodity(
      id: 'CMD004',
      farmerId: 'USR002',
      farmerName: 'Pak Budi Santoso',
      name: 'Kangkung Organik',
      category: 'Sayur',
      description: 'Kangkung organik tanpa pestisida kimia. Batang renyah, daun hijau segar. Dipanen pagi hari untuk menjaga kesegaran.',
      pricePerKg: 8000,
      availableQuotaKg: 80,
      estimatedHarvestDate: DateTime.now().add(const Duration(days: 5)),
      location: 'Bandungan, Semarang',
      imageUrls: [],
      isActive: true,
      farmerRating: 4.8,
    ),
    Commodity(
      id: 'CMD005',
      farmerId: 'USR004',
      farmerName: 'Bu Sari Wulandari',
      name: 'Jagung Manis',
      category: 'Sayur',
      description: 'Jagung manis super dari lahan organik. Biji penuh, rasa manis alami. Ideal untuk sup, bakwan, dan olahan kuliner.',
      pricePerKg: 12000,
      availableQuotaKg: 200,
      estimatedHarvestDate: DateTime.now().add(const Duration(days: 18)),
      location: 'Ungaran, Semarang',
      imageUrls: [],
      isActive: true,
      farmerRating: 4.5,
    ),
    Commodity(
      id: 'CMD006',
      farmerId: 'USR005',
      farmerName: 'Pak Heru Prasetyo',
      name: 'Wortel Premium',
      category: 'Sayur',
      description: 'Wortel premium dari dataran tinggi Tawangmangu. Warna oranye cerah, manis alami, ukuran besar seragam.',
      pricePerKg: 15000,
      availableQuotaKg: 150,
      estimatedHarvestDate: DateTime.now().add(const Duration(days: 12)),
      location: 'Tawangmangu, Karanganyar',
      imageUrls: [],
      isActive: true,
      farmerRating: 4.3,
    ),
  ];

  // ─── ORDERS ───────────────────────────────────────────
  static final orders = [
    PreOrder(
      id: 'ORD001',
      customerId: 'USR001',
      customerName: 'Restoran Segar Jaya',
      farmerId: 'USR002',
      farmerName: 'Pak Budi Santoso',
      commodityId: 'CMD001',
      commodityName: 'Cabai Merah Keriting',
      quantityKg: 25,
      pricePerKg: 32000,
      totalPrice: 800000,
      deliveryDate: DateTime.now().add(const Duration(days: 16)),
      status: OrderStatus.shipped,
      deliveryAddress: 'Jl. Pemuda No. 45, Semarang',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    PreOrder(
      id: 'ORD002',
      customerId: 'USR001',
      customerName: 'Restoran Segar Jaya',
      farmerId: 'USR002',
      farmerName: 'Pak Budi Santoso',
      commodityId: 'CMD002',
      commodityName: 'Tomat Segar',
      quantityKg: 50,
      pricePerKg: 14000,
      totalPrice: 700000,
      deliveryDate: DateTime.now().add(const Duration(days: 23)),
      status: OrderStatus.paidEscrow,
      deliveryAddress: 'Jl. Pemuda No. 45, Semarang',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    PreOrder(
      id: 'ORD003',
      customerId: 'USR001',
      customerName: 'Restoran Segar Jaya',
      farmerId: 'USR004',
      farmerName: 'Bu Sari Wulandari',
      commodityId: 'CMD003',
      commodityName: 'Bawang Merah Brebes',
      quantityKg: 30,
      pricePerKg: 28000,
      totalPrice: 840000,
      deliveryDate: DateTime.now().add(const Duration(days: 12)),
      status: OrderStatus.completed,
      deliveryAddress: 'Jl. Pemuda No. 45, Semarang',
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
    ),
    PreOrder(
      id: 'ORD004',
      customerId: 'USR001',
      customerName: 'Restoran Segar Jaya',
      farmerId: 'USR002',
      farmerName: 'Pak Budi Santoso',
      commodityId: 'CMD004',
      commodityName: 'Kangkung Organik',
      quantityKg: 15,
      pricePerKg: 8000,
      totalPrice: 120000,
      deliveryDate: DateTime.now().add(const Duration(days: 7)),
      status: OrderStatus.waitingPayment,
      deliveryAddress: 'Jl. Pemuda No. 45, Semarang',
      createdAt: DateTime.now(),
    ),
  ];

  // ─── PAYMENTS ─────────────────────────────────────────
  static final payments = [
    Payment(
      id: 'PAY001',
      orderId: 'ORD001',
      amount: 800000,
      method: 'BCA Virtual Account',
      virtualAccountNumber: '8801234567890001',
      escrowStatus: 'held',
      paidAt: DateTime.now().subtract(const Duration(days: 4)),
    ),
    Payment(
      id: 'PAY002',
      orderId: 'ORD002',
      amount: 700000,
      method: 'Mandiri Virtual Account',
      virtualAccountNumber: '8901234567890002',
      escrowStatus: 'held',
      paidAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  // ─── DISPUTES ─────────────────────────────────────────
  static final disputes = [
    Dispute(
      id: 'DSP001',
      orderId: 'ORD003',
      customerId: 'USR001',
      customerName: 'Restoran Segar Jaya',
      farmerName: 'Bu Sari Wulandari',
      commodityName: 'Bawang Merah Brebes',
      reason: 'Sebagian barang busuk',
      description: 'Dari total 30 kg bawang merah yang diterima, sekitar 5 kg dalam kondisi busuk dan berair. Kualitas tidak sesuai dengan deskripsi produk.',
      evidenceImageUrls: [],
      status: DisputeStatus.submitted,
      escrowAmount: 840000,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  // ─── WITHDRAWALS ──────────────────────────────────────
  static final withdrawals = [
    Withdrawal(
      id: 'WDR001',
      farmerId: 'USR002',
      farmerName: 'Pak Budi Santoso',
      amount: 500000,
      bankName: 'BCA',
      accountNumber: '1234567890',
      accountHolderName: 'Budi Santoso',
      status: WithdrawalStatus.requested,
      createdAt: DateTime.now().subtract(const Duration(hours: 12)),
    ),
  ];

  // ─── REVIEWS ──────────────────────────────────────────
  static final reviews = [
    Review(
      id: 'REV001',
      orderId: 'ORD003',
      customerId: 'USR001',
      customerName: 'Restoran Segar Jaya',
      farmerId: 'USR004',
      rating: 4,
      comment: 'Bawang merah kualitas bagus, hanya sedikit yang tidak sesuai. Pengiriman tepat waktu.',
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
    Review(
      id: 'REV002',
      orderId: 'ORD001',
      customerId: 'USR001',
      customerName: 'Restoran Segar Jaya',
      farmerId: 'USR002',
      rating: 5,
      comment: 'Cabai merah keriting kualitas terbaik! Pedas sempurna dan segar. Pasti order lagi.',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
  ];

  // ─── WALLET ───────────────────────────────────────────
  static const walletSummary = WalletSummary(
    availableBalance: 1540000,
    heldBalance: 800000,
    inProcessBalance: 500000,
    totalDisbursed: 3200000,
  );

  // ─── NOTIFICATIONS ────────────────────────────────────
  static final notifications = [
    AppNotification(
      id: 'NTF001',
      title: 'Pesanan Dikirim',
      message: 'Pesanan ORD001 (Cabai Merah Keriting) sedang dalam perjalanan.',
      type: 'order',
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    AppNotification(
      id: 'NTF002',
      title: 'Pembayaran Berhasil',
      message: 'Pembayaran untuk pesanan ORD002 (Tomat Segar) telah berhasil. Dana ditahan di escrow.',
      type: 'payment',
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    AppNotification(
      id: 'NTF003',
      title: 'Sengketa Diajukan',
      message: 'Pelanggan mengajukan sengketa untuk pesanan ORD003.',
      type: 'dispute',
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  // ─── CATEGORIES ───────────────────────────────────────
  static const categories = [
    'Semua',
    'Sayur',
    'Buah',
    'Bumbu',
    'Biji-bijian',
    'Umbi',
    'Rempah',
  ];

  // ─── STATUS HISTORIES ─────────────────────────────────
  static final orderStatusHistories = {
    'ORD001': [
      OrderStatusHistory(
        status: 'created',
        label: 'Pre-Order Dibuat',
        timestamp: DateTime.now().subtract(const Duration(days: 5)),
      ),
      OrderStatusHistory(
        status: 'paid',
        label: 'Pembayaran Escrow',
        timestamp: DateTime.now().subtract(const Duration(days: 4)),
      ),
      OrderStatusHistory(
        status: 'harvesting',
        label: 'Panen',
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
      ),
      OrderStatusHistory(
        status: 'sorting',
        label: 'Sortir / QC',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
      ),
      OrderStatusHistory(
        status: 'shipped',
        label: 'Dikirim',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        note: 'Kurir: Pak Joko - 081234000000',
      ),
    ],
  };
}
