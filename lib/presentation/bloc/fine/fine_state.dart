import 'package:equatable/equatable.dart';
import '../../../domain/entity/finance/fine_entity.dart';

abstract class FineState extends Equatable {
  const FineState();
  @override
  List<Object?> get props => [];
}

class FineInitial extends FineState {}

class FineLoading extends FineState {}

class FineLoaded extends FineState {
  final List<FineEntity> fines;
  const FineLoaded(this.fines);
  @override
  List<Object?> get props => [fines];
}

class FineOperationSuccess extends FineState {
  final String message;
  final List<FineEntity> fines;
  const FineOperationSuccess(this.message, this.fines);
  @override
  List<Object?> get props => [message, fines];
}

class FineError extends FineState {
  final String message;
  const FineError(this.message);
  @override
  List<Object?> get props => [message];
}
