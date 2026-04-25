import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/domain/repository/resident_repository.dart';
import 'complete_profile_event.dart';
import 'complete_profile_state.dart';

class CompleteProfileBloc extends Bloc<CompleteProfileEvent, CompleteProfileState> {
  final ResidentRepository repository;

  CompleteProfileBloc({required this.repository}) : super(CompleteProfileInitial()) {
    on<LoadProfileEvent>((event, emit) async {
      emit(CompleteProfileLoading());
      try {
        final profile = await repository.getProfile();
        emit(CompleteProfileLoaded(profile));
      } catch (e) {
        emit(CompleteProfileFailure(e.toString()));
      }
    });

    on<SubmitProfileEvent>((event, emit) async {
      emit(CompleteProfileLoading());
      try {
        await repository.completeProfile(
          idCardNumber: event.idCardNumber,
          phoneNumber: event.phoneNumber,
          gender: event.gender,
          job: event.job,
          addressKtp: event.addressKtp,
          emergencyContactName: event.emergencyContactName,
          emergencyContactPhone: event.emergencyContactPhone,
          ktpPhoto: event.ktpPhoto,
        );
        emit(CompleteProfileSuccess());
      } catch (e) {
        emit(CompleteProfileFailure(e.toString()));
      }
    });
  }
}
