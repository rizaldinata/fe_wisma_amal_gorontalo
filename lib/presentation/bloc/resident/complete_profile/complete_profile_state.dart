import 'package:equatable/equatable.dart';
import 'package:frontend/domain/entity/resident/resident_profile_entity.dart';

abstract class CompleteProfileState extends Equatable {
  const CompleteProfileState();
  
  @override
  List<Object?> get props => [];
}

class CompleteProfileInitial extends CompleteProfileState {}

class CompleteProfileLoading extends CompleteProfileState {}

class CompleteProfileSuccess extends CompleteProfileState {}

class CompleteProfileFailure extends CompleteProfileState {
  final String message;

  const CompleteProfileFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class CompleteProfileLoaded extends CompleteProfileState {
  final ResidentProfileEntity profile;

  const CompleteProfileLoaded(this.profile);

  @override
  List<Object?> get props => [profile];
}
