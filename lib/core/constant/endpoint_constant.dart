class EndpointConstant {
  static const String registerEndpoint = '/register';
  static const String loginEndpoint = '/login';
  static const String logoutEndpoint = '/logout';
  static const String checkSessionEndpoint = '/me';

  static const String profileEndpoint = '/profile';
  static const String permissionEndpoint = '/permissions';
  static const String allPermissionsEndpoint = '/permissions/all';
  static const String roomsEndpoint = '/rooms';

  static deleteRoomImage({required int roomId, required int imageId}) =>
      '/rooms/$roomId/images/$imageId';

  static uploadRoomImage({required int roomId}) => '/rooms/$roomId/images';
}
