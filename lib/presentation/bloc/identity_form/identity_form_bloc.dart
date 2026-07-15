import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:formz/formz.dart';

part 'identity_form_event.dart';
part 'identity_form_state.dart';

class IdentityFormBloc extends Bloc<IdentityFormEvent, IdentityFormState> {
  IdentityFormBloc() : super(const IdentityFormState()) {
    on<LoadIdentityFormEvent>(_onLoad);
    on<PickProfileImageEvent>(_onPickImage);
    on<SubmitIdentityFormEvent>(_onSubmit);
  }

  Future<void> _onLoad(
    LoadIdentityFormEvent event,
    Emitter<IdentityFormState> emit,
  ) async {
    try {
      emit(state.copyWith(loadStatus: FormzSubmissionStatus.inProgress));

      // TODO: ambil data dari API (future)
      // sekarang dummy saja

      emit(state.copyWith(
        loadStatus: FormzSubmissionStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(
        loadStatus: FormzSubmissionStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onPickImage(
    PickProfileImageEvent event,
    Emitter<IdentityFormState> emit,
  ) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        emit(state.copyWith(
          profileImageBytes: result.files.single.bytes,
        ));
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onSubmit(
    SubmitIdentityFormEvent event,
    Emitter<IdentityFormState> emit,
  ) async {
    try {
      emit(state.copyWith(submitStatus: FormzSubmissionStatus.inProgress));

      // DEBUG
      print('Submit Identity:');
      print(event.name);
      print(event.email);
      print(event.phone);
      print(event.gender);
      print(event.status);

      // TODO: kirim ke backend

      emit(state.copyWith(
        submitStatus: FormzSubmissionStatus.success,
        successMessage: 'Berhasil menyimpan data',
      ));
    } catch (e) {
      emit(state.copyWith(
        submitStatus: FormzSubmissionStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}