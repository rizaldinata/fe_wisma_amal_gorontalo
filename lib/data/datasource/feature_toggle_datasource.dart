import 'package:dio/dio.dart';
import 'package:frontend/core/services/network/dio_client.dart';
import '../model/setting/feature_toggle_model.dart';

class FeatureToggleRemoteDataSource {
  final DioClient _dioClient;

  FeatureToggleRemoteDataSource(this._dioClient);

  Future<List<FeatureToggleModel>> getFeatureToggles() async {
    try {
      final response = await _dioClient.get('/settings/feature-toggles');

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => FeatureToggleModel.fromJson(json)).toList();
      } else {
        throw Exception(
          response.data['message'] ?? 'Failed to load feature toggles',
        );
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? e.message ?? 'Unknown error occurred',
      );
    }
  }

  Future<void> updateFeatureToggle(String key, bool isActive) async {
    try {
      final response = await _dioClient.patch(
        '/settings/feature-toggles/$key',
        data: {'is_active': isActive},
      );

      if (response.data['success'] != true) {
        throw Exception(
          response.data['message'] ?? 'Failed to update feature toggle',
        );
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? e.message ?? 'Unknown error occurred',
      );
    }
  }
}
