import 'package:equatable/equatable.dart';

abstract class ScheduleDetailEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchScheduleDetail extends ScheduleDetailEvent {
  final int id;
  FetchScheduleDetail(this.id);

  @override
  List<Object?> get props => [id];
}
