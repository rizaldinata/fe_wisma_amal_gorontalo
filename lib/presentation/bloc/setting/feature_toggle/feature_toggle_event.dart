import 'package:equatable/equatable.dart';

abstract class FeatureToggleEvent extends Equatable {
  const FeatureToggleEvent();

  @override
  List<Object?> get props => [];
}

class FetchFeatureToggles extends FeatureToggleEvent {}

class UpdateFeatureToggle extends FeatureToggleEvent {
  final String key;
  final bool isActive;

  const UpdateFeatureToggle({required this.key, required this.isActive});

  @override
  List<Object?> get props => [key, isActive];
}
