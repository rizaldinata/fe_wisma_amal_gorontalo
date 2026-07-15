import 'package:equatable/equatable.dart';
import 'package:frontend/domain/entity/pagination_meta.dart';
import 'package:frontend/domain/entity/schedule_entity.dart';

abstract class ScheduleListState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ScheduleListInitial extends ScheduleListState {}

class ScheduleListLoading extends ScheduleListState {}

class ScheduleListLoaded extends ScheduleListState {
  final List<ScheduleEntity> schedules;
  final PaginationMeta meta;
  
  ScheduleListLoaded({required this.schedules, required this.meta});

  @override
  List<Object?> get props => [schedules, meta];
}

class ScheduleListError extends ScheduleListState {
  final String message;
  ScheduleListError(this.message);

  @override
  List<Object?> get props => [message];
}
