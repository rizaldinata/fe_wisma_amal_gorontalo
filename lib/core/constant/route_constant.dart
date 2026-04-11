class RouteConstant {
  // Kalau path diawali / → berarti root / halaman awal
  // Kalau nggak diawali / → berarti child/nested

  //splash page
  static const String rootPath = '/';
  static const String rootName = 'root';

  //auth page
  static const String loginName = '/login';
  static const String registerName = '/register';

  //dashboard dan admin panel
  static const String dashboardName = 'dashboard';
  static const String landingName = 'landing';
  static const String permissionName = 'permissions';
  static const String roleName = 'role';
  static const String settingName = 'setting';

  // Manajemen penghuni
  static const String residentName = 'residents';

  // Manajemen kamar & reservasi
  static const String roomAndReservationName = 'room-reservations';
  static const String roomName = '$roomAndReservationName/rooms';
  static const String addRoomName = '$roomAndReservationName/$roomName/add';
  static const String detailRoomName = '$roomAndReservationName/$roomName/:id';
  static const String editRoomName =
      '$roomAndReservationName/$detailRoomName/form';
  static const String reservationName = '$roomAndReservationName/reservations';
  static const String roomScheduleName = '$roomAndReservationName/schedule';

  // Manajemen Keuangan
  static const String financeName = 'finances';

  // Manajemen Inventaris & Pemeliharaan
  static const String inventory = 'inventory';
  static const String inventoryForm = '$inventory/form';
  static const String maintanance = 'maintanance';
  static const String maintananceForm = '$maintanance/form';
  static const String maintananceDetail = '$maintanance/detail';

  // Laporan Kerusakan
  static const String maintenanceReport = 'maintenance-reports';
  static const String maintenanceReportCreate = '$maintenanceReport/create';
  static const String maintenanceReportDetail = '$maintenanceReport/:id';

  // Modul Finance
  static const String financeDashboardName = 'finance/dashboard';
}
