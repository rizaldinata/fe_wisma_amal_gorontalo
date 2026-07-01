import 'package:equatable/equatable.dart';
import 'package:frontend/domain/entity/schedule_entity.dart';

abstract class ScheduleListEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchSchedules extends ScheduleListEvent {
  final int page;
  final int perPage;

  FetchSchedules({this.page = 1, this.perPage = 10});

  @override
  List<Object?> get props => [page, perPage];
}
