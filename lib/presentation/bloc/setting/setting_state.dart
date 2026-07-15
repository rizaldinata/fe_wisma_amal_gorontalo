import '../../../domain/entity/setting/setting_entity.dart';

abstract class SettingState {}

class SettingInitial extends SettingState {}

class SettingLoading extends SettingState {}

class SettingLoaded extends SettingState {
  final SettingEntity entity;
  SettingLoaded(this.entity);
}

class SettingError extends SettingState {
  final String message;
  SettingError(this.message);
}

class SettingUpdateSuccess extends SettingState {
  final SettingEntity entity;
  SettingUpdateSuccess(this.entity);
}
