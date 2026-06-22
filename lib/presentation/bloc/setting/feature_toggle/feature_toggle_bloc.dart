import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/repository/feature_toggle_repository.dart';
import 'feature_toggle_event.dart';
import 'feature_toggle_state.dart';

class FeatureToggleBloc extends Bloc<FeatureToggleEvent, FeatureToggleState> {
  final FeatureToggleRepository repository;

  FeatureToggleBloc({required this.repository}) : super(FeatureToggleInitial()) {
    on<FetchFeatureToggles>(_onFetchFeatureToggles);
    on<UpdateFeatureToggle>(_onUpdateFeatureToggle);
  }

  Future<void> _onFetchFeatureToggles(
      FetchFeatureToggles event, Emitter<FeatureToggleState> emit) async {
    emit(FeatureToggleLoading());
    try {
      final toggles = await repository.getFeatureToggles();
      emit(FeatureToggleLoaded(toggles: toggles));
    } catch (e) {
      emit(FeatureToggleError(message: e.toString()));
    }
  }

  Future<void> _onUpdateFeatureToggle(
      UpdateFeatureToggle event, Emitter<FeatureToggleState> emit) async {
    final currentState = state;
    if (currentState is FeatureToggleLoaded) {
      // Optimistic update
      final oldToggles = currentState.toggles;
      emit(FeatureToggleUpdating(toggles: oldToggles, updatingKey: event.key));

      try {
        await repository.updateFeatureToggle(event.key, event.isActive);
        // After successful update, fetch the latest to ensure hierarchy state is consistent
        // (e.g. if a module is turned off, its children are effectively off too, though the DB stores true for children)
        final newToggles = await repository.getFeatureToggles();
        emit(FeatureToggleLoaded(toggles: newToggles));
      } catch (e) {
        // Rollback on error
        emit(FeatureToggleError(message: e.toString()));
        emit(FeatureToggleLoaded(toggles: oldToggles));
      }
    }
  }
}
