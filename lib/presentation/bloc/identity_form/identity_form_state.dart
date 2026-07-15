part of 'identity_form_bloc.dart';

class IdentityFormState extends Equatable {
  const IdentityFormState({
    this.loadStatus = FormzSubmissionStatus.initial,
    this.submitStatus = FormzSubmissionStatus.initial,
    this.errorMessage,
    this.successMessage,
    this.profileImageBytes,
    this.name = '',
    this.email = '',
    this.phone = '',
    this.gender,
    this.status,
  });

  final FormzSubmissionStatus loadStatus;
  final FormzSubmissionStatus submitStatus;
  final String? errorMessage;
  final String? successMessage;

  final Uint8List? profileImageBytes;

  final String name;
  final String email;
  final String phone;
  final String? gender;
  final String? status;

  IdentityFormState copyWith({
    FormzSubmissionStatus? loadStatus,
    FormzSubmissionStatus? submitStatus,
    String? errorMessage,
    String? successMessage,
    Uint8List? profileImageBytes,
    String? name,
    String? email,
    String? phone,
    String? gender,
    String? status,
  }) {
    return IdentityFormState(
      loadStatus: loadStatus ?? this.loadStatus,
      submitStatus: submitStatus ?? this.submitStatus,
      errorMessage: errorMessage,
      successMessage: successMessage,
      profileImageBytes: profileImageBytes ?? this.profileImageBytes,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
        loadStatus,
        submitStatus,
        errorMessage,
        successMessage,
        profileImageBytes,
        name,
        email,
        phone,
        gender,
        status,
      ];
}