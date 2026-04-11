import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/domain/entity/inventory_entity.dart';
import 'package:frontend/domain/usecase/inventory/get_inventories_usecase.dart';

// Events
abstract class InventoryListEvent extends Equatable {
  const InventoryListEvent();

  @override
  List<Object?> get props => [];
}

class FetchInventories extends InventoryListEvent {}

// States
abstract class InventoryListState extends Equatable {
  const InventoryListState();

  @override
  List<Object?> get props => [];
}

class InventoryListInitial extends InventoryListState {}

class InventoryListLoading extends InventoryListState {}

class InventoryListLoaded extends InventoryListState {
  final List<InventoryEntity> inventories;

  const InventoryListLoaded(this.inventories);

  @override
  List<Object?> get props => [inventories];
}

class InventoryListError extends InventoryListState {
  final String message;

  const InventoryListError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class InventoryListBloc extends Bloc<InventoryListEvent, InventoryListState> {
  final GetInventoriesUseCase getInventoriesUseCase;

  InventoryListBloc({required this.getInventoriesUseCase})
      : super(InventoryListInitial()) {
    on<FetchInventories>(_onFetchInventories);
  }

  Future<void> _onFetchInventories(
      FetchInventories event, Emitter<InventoryListState> emit) async {
    emit(InventoryListLoading());
    try {
      final inventories = await getInventoriesUseCase.call();
      emit(InventoryListLoaded(inventories));
    } catch (e) {
      emit(InventoryListError(e.toString()));
    }
  }
}
