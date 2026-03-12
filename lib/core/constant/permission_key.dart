// 'view-dashboard',

// // crud permission
// 'access-permission-management',
// 'view-permission',
// 'create-permission',
// 'update-permission',
// 'delete-permission',

// // crud user
// 'access-user-management',
// 'view-user',
// 'create-user',
// 'update-user',
// 'delete-user',

// // crud room
// 'access-room-management',
// 'view-room',
// 'create-room',
// 'update-room',
// 'delete-room',

// // sewa menyewa
// 'view-lease',
// 'approve-lease',
abstract class PermissionKeys {
  static const accessAdminPanel = 'access-admin-panel';
  static const accessResidentArea = 'access-resident-area';

  //dashboard
  static const viewDashboard = 'view-dashboard';

  //rooms
  static const viewRooms = 'view-room';
  static const deleteRooms = 'delete-room';
  static const updateRooms = 'update-room';
  static const createRooms = 'create-room';

  //lease
  static const viewLease = 'view-lease';
  static const applyLease = 'approve-lease';

  //user
  static const viewUser = 'view-user';
  static const deleteUser = 'delete-user';
  static const updateUser = 'update-user';
  static const createUser = 'create-user';

  //permission
  static const viewPermission = 'view-permission';
  static const deletePermission = 'delete-permission';
  static const updatePermission = 'update-permission';
  static const createPermission = 'create-permission';

  // finance
  static const String financeDashboardView = 'finance-dashboard-view';
}
