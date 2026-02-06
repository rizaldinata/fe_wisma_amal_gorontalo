import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:frontend/domain/entity/permission_entity.dart';

class PermissionState extends Equatable {
  final FormzSubmissionStatus status;
  final List<PermissionEntity> permissions;
  final String? errorMessage;
  final String? successMessage;

  const PermissionState({
    this.status = FormzSubmissionStatus.initial,
    this.permissions = const [],
    this.errorMessage,
    this.successMessage,
  });

  PermissionState copyWith({
    FormzSubmissionStatus? status,
    List<PermissionEntity>? permissions,
    String? errorMessage,
    String? successMessage,
  }) {
    return PermissionState(
      status: status ?? this.status,
      permissions: permissions ?? this.permissions,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    permissions,
    errorMessage,
    successMessage,
  ];
}
