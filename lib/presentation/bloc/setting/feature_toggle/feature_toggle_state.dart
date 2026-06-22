import 'package:equatable/equatable.dart';
import '../../../../data/model/setting/feature_toggle_model.dart';

abstract class FeatureToggleState extends Equatable {
  const FeatureToggleState();

  @override
  List<Object?> get props => [];
}

class FeatureToggleInitial extends FeatureToggleState {}

class FeatureToggleLoading extends FeatureToggleState {}

class FeatureToggleLoaded extends FeatureToggleState {
  final List<FeatureToggleModel> toggles;

  const FeatureToggleLoaded({required this.toggles});

  @override
  List<Object?> get props => [toggles];
}

class FeatureToggleError extends FeatureToggleState {
  final String message;

  const FeatureToggleError({required this.message});

  @override
  List<Object?> get props => [message];
}

// State ketika sedang melakukan update
class FeatureToggleUpdating extends FeatureToggleLoaded {
  final String updatingKey;

  const FeatureToggleUpdating({required super.toggles, required this.updatingKey});

  @override
  List<Object?> get props => [toggles, updatingKey];
}
