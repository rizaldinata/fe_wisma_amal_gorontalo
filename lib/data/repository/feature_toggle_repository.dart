import '../model/setting/feature_toggle_model.dart';
import '../datasource/feature_toggle_datasource.dart';

class FeatureToggleRepository {
  final FeatureToggleRemoteDataSource _remoteDataSource;

  FeatureToggleRepository(this._remoteDataSource);

  Future<List<FeatureToggleModel>> getFeatureToggles() async {
    return await _remoteDataSource.getFeatureToggles();
  }

  Future<void> updateFeatureToggle(String key, bool isActive) async {
    await _remoteDataSource.updateFeatureToggle(key, isActive);
  }
}
