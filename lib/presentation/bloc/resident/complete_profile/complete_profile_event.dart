import 'package:file_picker/file_picker.dart';
import 'package:equatable/equatable.dart';

abstract class CompleteProfileEvent extends Equatable {
  const CompleteProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfileEvent extends CompleteProfileEvent {}

class SubmitProfileEvent extends CompleteProfileEvent {
  final String idCardNumber;
  final String phoneNumber;
  final String gender;
  final String? job;
  final String addressKtp;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final PlatformFile? ktpPhoto;

  const SubmitProfileEvent({
    required this.idCardNumber,
    required this.phoneNumber,
    required this.gender,
    this.job,
    required this.addressKtp,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.ktpPhoto,
  });

  @override
  List<Object?> get props => [
        idCardNumber,
        phoneNumber,
        gender,
        job,
        addressKtp,
        emergencyContactName,
        emergencyContactPhone,
        ktpPhoto,
      ];
}
