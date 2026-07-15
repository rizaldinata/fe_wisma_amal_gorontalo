import 'dart:typed_data';
import 'package:frontend/domain/entity/guest/guest_entity.dart';
import 'package:frontend/domain/repository/guest_repository.dart';

class CreateGuestUseCase {
  final GuestRepository _repository;

  CreateGuestUseCase(this._repository);

  Future<List<MyGuestItem>> call({
    required List<Map<String, dynamic>> guests,
    required List<Uint8List> identityImages,
    required List<String> identityImageNames,
    required String checkInAt,
    required String checkOutAt,
  }) =>
      _repository.createGuest(
        guests: guests,
        identityImages: identityImages,
        identityImageNames: identityImageNames,
        checkInAt: checkInAt,
        checkOutAt: checkOutAt,
      );
}
