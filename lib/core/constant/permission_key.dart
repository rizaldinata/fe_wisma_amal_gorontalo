abstract class PermissionKeys {
  // ─── Dashboard ──────────────────────────────────────────────────────
  static const viewDashboard = 'view-dashboard';
  static const viewResidentDashboard = 'view-resident-dashboard';

  // ─── Permission Management ───────────────────────────────────────────
  static const viewPermission = 'view-permission';
  static const createPermission = 'create-permission';
  static const updatePermission = 'update-permission';
  static const deletePermission = 'delete-permission';

  // ─── Role Management ─────────────────────────────────────────────────
  static const viewRole = 'view-role';
  static const createRole = 'create-role';
  static const updateRole = 'update-role';
  static const deleteRole = 'delete-role';

  // ─── User Management ─────────────────────────────────────────────────
  static const viewUser = 'view-user';
  static const createUser = 'create-user';
  static const updateUser = 'update-user';
  static const deleteUser = 'delete-user';

  // ─── Room Management ─────────────────────────────────────────────────
  static const viewRooms = 'view-room';
  static const createRooms = 'create-room';
  static const updateRooms = 'update-room';
  static const deleteRooms = 'delete-room';

  // ─── Lease / Sewa ────────────────────────────────────────────────────
  static const viewLease = 'view-lease';
  static const approveLease = 'approve-lease';
  /// Mengajukan sewa kamar (penghuni)
  static const applyLease = 'create-lease';

  // ─── Finance ─────────────────────────────────────────────────────────
  static const financeDashboardView = 'finance-dashboard-view';
  static const financePaymentView = 'finance-payment-view';
  static const financePaymentVerify = 'finance-payment-verify';
  static const financePaymentRefund = 'finance-payment-refund';
  static const financeInvoiceView = 'finance-invoice-view';
  static const financeInvoiceCreate = 'finance-invoice-create';
  static const financeExpenseView = 'finance-expense-view';
  static const financeExpenseCreate = 'finance-expense-create';
  static const financeExpenseUpdate = 'finance-expense-update';
  static const financeExpenseDelete = 'finance-expense-delete';
  static const financeFixedExpenseView = 'finance-fixed-expense-view';
  static const financeFixedExpenseCreate = 'finance-fixed-expense-create';
  static const financeFixedExpenseUpdate = 'finance-fixed-expense-update';
  static const financeFixedExpenseDelete = 'finance-fixed-expense-delete';
  /// Ringkasan keuangan pribadi (member & resident)
  static const financeMeSummaryView = 'finance-me-summary-view';
  static const financeMeInvoiceView = 'finance-me-invoice-view';
  static const financeMePaymentView = 'finance-me-payment-view';

  // ─── Fine / Denda ─────────────────────────────────────────────────────
  static const financeFineView = 'finance-fine-view';
  static const financeFineCreate = 'finance-fine-create';
  static const financeFineWaive = 'finance-fine-waive';
  /// Member/resident melihat denda milik sendiri
  static const financeMeFineView = 'finance-me-fine-view';

  // ─── Inventory ───────────────────────────────────────────────────────
  static const viewInventory = 'view-inventory';
  static const createInventory = 'create-inventory';
  static const updateInventory = 'update-inventory';
  static const deleteInventory = 'delete-inventory';

  // ─── Maintenance ─────────────────────────────────────────────
  static const viewMaintenance = 'view-maintenance';
  static const createMaintenance = 'create-maintenance';
  static const updateMaintenance = 'update-maintenance';
  static const deleteMaintenance = 'delete-maintenance';
  static const scheduleMaintenance = 'schedule-maintenance';
  /// Melihat semua laporan kerusakan dari penghuni (admin)
  static const viewDamageReport = 'view-damage-report';

  // ─── Damage Report (Penghuni) ────────────────────────────────────────
  /// Penghuni melaporkan kerusakan
  static const createDamageReport = 'create-damage-report';
  /// Penghuni melihat laporan kerusakan milik sendiri
  static const viewMyDamageReport = 'view-my-damage-report';

  // ─── Resident Management (Admin) ─────────────────────────────────────
  static const viewResident = 'view-resident';
  static const createResident = 'create-resident';
  static const updateResident = 'update-resident';
  static const deleteResident = 'delete-resident';
  
  // ─── Profile & Resident Flow ────────────────────────────────────────
  static const completeResidentProfile = 'complete-resident-profile';

  // ─── Guest (Tamu) ────────────────────────────────────────────────────
  /// Admin melihat semua tamu
  static const viewGuest = 'view-guest';
  /// Penghuni melihat daftar tamu milik sendiri
  static const viewMyGuest = 'view-my-guest';
  /// Penghuni mendaftarkan tamu baru
  static const createGuest = 'create-guest';
  /// Penghuni menghapus tamu milik sendiri
  static const deleteGuest = 'delete-guest';
  /// Penghuni membayar tagihan tamu
  static const payGuestBill = 'pay-guest-bill';
  /// Admin memverifikasi pembayaran tagihan tamu
  static const verifyGuestBill = 'verify-guest-bill';
  /// Admin melihat semua tagihan tamu
  static const viewGuestBill = 'view-guest-bill';

  // ─── Notification ────────────────────────────────────────────────────
  static const notificationLogView = 'notification-log-view';
  static const notificationSend = 'notification-send';

  // ─── Setting ─────────────────────────────────────────────────────────
  static const settingView = 'setting-view';
  static const settingUpdate = 'setting-update';
}
