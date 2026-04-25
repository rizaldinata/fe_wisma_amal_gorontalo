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

  //role
  static const viewRole = 'view-role';
  static const deleteRole = 'delete-role';
  static const updateRole = 'update-role';
  static const createRole = 'create-role';

  //permission
  static const viewPermission = 'view-permission';
  static const deletePermission = 'delete-permission';
  static const updatePermission = 'update-permission';
  static const createPermission = 'create-permission';

  // inventory
  static const accessInventory = 'access-inventory-management';
  static const viewInventory = 'view-inventory';
  static const createInventory = 'create-inventory';
  static const updateInventory = 'update-inventory';
  static const deleteInventory = 'delete-inventory';

  // maintenance
  static const accessMaintenance = 'access-maintenance-management';
  static const viewMaintenance = 'view-maintenance';
  static const createMaintenance = 'create-maintenance';
  static const updateMaintenance = 'update-maintenance';
  static const deleteMaintenance = 'delete-maintenance';
  static const scheduleMaintenance = 'schedule-maintenance';
  static const viewDamageReport = 'view-damage-report';

  // resident management
  static const accessResidentManagement = 'access-resident-management';
  static const viewResident = 'view-resident';
  static const createResident = 'create-resident';
  static const updateResident = 'update-resident';
  static const deleteResident = 'delete-resident';
  static const completeResidentProfile = 'complete-resident-profile';

  // settings
  static const settingManagementAccess = 'setting-management-access';
  static const settingView = 'setting-view';
  static const settingUpdate = 'setting-update';

  // finance
  static const String financeDashboardView = 'finance-dashboard-view';
}
