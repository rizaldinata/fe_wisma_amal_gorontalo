import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/domain/entity/inventory_entity.dart';
import 'package:frontend/domain/usecase/inventory/inventory_action_usecases.dart';

// Events
abstract class InventoryActionEvent extends Equatable {
  const InventoryActionEvent();

  @override
  List<Object?> get props => [];
}

class CreateInventoryEvent extends InventoryActionEvent {
  final InventoryEntity data;
  const CreateInventoryEvent(this.data);

  @override
  List<Object?> get props => [data];
}

class UpdateInventoryEvent extends InventoryActionEvent {
  final int id;
  final InventoryEntity data;
  const UpdateInventoryEvent(this.id, this.data);

  @override
  List<Object?> get props => [id, data];
}

class DeleteInventoryEvent extends InventoryActionEvent {
  final int id;
  const DeleteInventoryEvent(this.id);

  @override
  List<Object?> get props => [id];
}

// States
abstract class InventoryActionState extends Equatable {
  const InventoryActionState();

  @override
  List<Object?> get props => [];
}

class InventoryActionInitial extends InventoryActionState {}

class InventoryActionLoading extends InventoryActionState {}

class InventoryActionSuccess extends InventoryActionState {
  final String message;
  const InventoryActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class InventoryActionError extends InventoryActionState {
  final String message;

  const InventoryActionError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class InventoryActionBloc
    extends Bloc<InventoryActionEvent, InventoryActionState> {
  final CreateInventoryUseCase createInventoryUseCase;
  final UpdateInventoryUseCase updateInventoryUseCase;
  final DeleteInventoryUseCase deleteInventoryUseCase;

  InventoryActionBloc({
    required this.createInventoryUseCase,
    required this.updateInventoryUseCase,
    required this.deleteInventoryUseCase,
  }) : super(InventoryActionInitial()) {
    on<CreateInventoryEvent>(_onCreateInventory);
    on<UpdateInventoryEvent>(_onUpdateInventory);
    on<DeleteInventoryEvent>(_onDeleteInventory);
  }

  Future<void> _onCreateInventory(
      CreateInventoryEvent event, Emitter<InventoryActionState> emit) async {
    emit(InventoryActionLoading());
    try {
      await createInventoryUseCase.call(event.data);
      emit(const InventoryActionSuccess("Inventaris berhasil ditambahkan"));
    } catch (e) {
      emit(InventoryActionError(e.toString()));
    }
  }

  Future<void> _onUpdateInventory(
      UpdateInventoryEvent event, Emitter<InventoryActionState> emit) async {
    emit(InventoryActionLoading());
    try {
      await updateInventoryUseCase.call(event.id, event.data);
      emit(const InventoryActionSuccess("Inventaris berhasil diperbarui"));
    } catch (e) {
      emit(InventoryActionError(e.toString()));
    }
  }

  Future<void> _onDeleteInventory(
      DeleteInventoryEvent event, Emitter<InventoryActionState> emit) async {
    emit(InventoryActionLoading());
    try {
      await deleteInventoryUseCase.call(event.id);
      emit(const InventoryActionSuccess("Inventaris berhasil dihapus"));
    } catch (e) {
      emit(InventoryActionError(e.toString()));
    }
  }
}
