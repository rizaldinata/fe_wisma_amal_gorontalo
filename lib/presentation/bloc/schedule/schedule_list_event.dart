import 'package:equatable/equatable.dart';
import 'package:frontend/domain/entity/schedule_entity.dart';

abstract class ScheduleListEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchSchedules extends ScheduleListEvent {}
