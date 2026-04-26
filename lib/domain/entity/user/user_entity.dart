import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final int id;
  final String name;
  final String email;
  final String? role;
  final String? createdAt;
  final String? phoneNumber;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.role,
    this.createdAt,
    this.phoneNumber,
  });

  @override
  List<Object?> get props => [id, name, email, role, createdAt, phoneNumber];
}
