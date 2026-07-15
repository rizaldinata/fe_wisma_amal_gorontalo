import 'package:auto_route/auto_route.dart';
import 'package:frontend/core/dependency_injection/dependency_injection.dart';
import 'package:frontend/core/navigation/auto_route.gr.dart';
import 'package:frontend/data/model/setting/feature_toggle_model.dart';
import 'package:frontend/presentation/bloc/setting/feature_toggle/feature_toggle_bloc.dart';
import 'package:frontend/presentation/bloc/setting/feature_toggle/feature_toggle_state.dart';

/// Route guard yang memblokir navigasi ke halaman fitur yang di-disable.
///
/// Jika fitur disabled → redirect ke Dashboard.
/// Jika toggles belum di-load → izinkan akses (optimistic, karena
/// FetchFeatureToggles sudah di-dispatch saat app startup).
class FeatureToggleGuard extends AutoRouteGuard {
  final String featureKey;

  FeatureToggleGuard(this.featureKey);

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    final bloc = serviceLocator<FeatureToggleBloc>();
    final state = bloc.state;

    if (state is FeatureToggleLoaded) {
      final isEnabled = _checkRecursive(state.toggles, featureKey);
      if (isEnabled ?? true) {
        resolver.next();
      } else {
        router.navigate(const DashboardRoute());
      }
    } else {
      // Toggles belum di-load, izinkan akses (optimistic)
      resolver.next();
    }
  }

  /// Recursive search untuk menemukan toggle key di hierarki parent-children.
  bool? _checkRecursive(
    List<FeatureToggleModel> toggles,
    String searchKey,
  ) {
    for (final toggle in toggles) {
      if (toggle.key == searchKey) return toggle.isActive;
      if (toggle.children.isNotEmpty) {
        final result = _checkRecursive(toggle.children, searchKey);
        if (result != null) return result;
      }
    }
    return null;
  }
}
