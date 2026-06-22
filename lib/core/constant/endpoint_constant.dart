class EndpointConstant {
  static const String registerEndpoint = '/register';
  static const String loginEndpoint = '/login';
  static const String logoutEndpoint = '/logout';
  static const String checkSessionEndpoint = '/me';
  static const String residentProfileEndpoint = '/resident/profile';
  static const String adminResidentsEndpoint = '/v1/room-schedules';
  static String adminResidentDetailEndpoint(String id) => '/v1/room-schedules/$id';
  static const String roomSchedulesEndpoint = '/rooms-schedules';

  // crud permission
  static const String adminPermissionEndpoint = '/admin/permissions';
  static String adminPermissionDetail(int id) => '/admin/permissions/$id';

  static const String profileEndpoint = '/profile';
  static const String permissionEndpoint = '/permissions';
  static const String allPermissionsEndpoint = '/permissions/all';
  static const String roomsEndpoint = '/rooms';
  static const String adminRolesEndpoint = '/admin/roles';

  static deleteRoomImage({required int roomId, required int imageId}) =>
      '/rooms/$roomId/images/$imageId';

  static uploadRoomImage({required int roomId}) => '/rooms/$roomId/images';

  static const String adminGuestsEndpoint = '/admin/guests';
  static String checkoutAdminGuestEndpoint(int id) => '/admin/guests/$id/checkout';
  static const String myGuestsEndpoint = '/guests';
  static String checkoutMyGuestEndpoint(int id) => '/guests/$id/checkout';
  static String deleteGuestEndpoint(int id) => '/guests/$id';
  static String guestBillEndpoint(int guestId) => '/guests/$guestId/bill';
  static String payGuestBillEndpoint(int guestId) =>
      '/guests/$guestId/bill/pay';
  static const String adminGuestBillsEndpoint = '/admin/guest-bills';
  static String verifyGuestBillEndpoint(int billId) =>
      '/admin/guest-bills/$billId/verify';

  static const String notificationLogsEndpoint = '/notification/logs';
  static const String notificationSummaryEndpoint = '/notification/logs/summary';
  static const String notificationSendEndpoint = '/notification/send';
  static const String notificationRecipientsEndpoint = '/notification/recipients';
  static String resendNotificationLogEndpoint(int id) => '/notification/logs/$id/resend';
  static const String markAllNotificationLogsReadEndpoint = '/notification/logs/mark-all-read';
}
