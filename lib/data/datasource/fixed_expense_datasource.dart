import '../../core/services/network/dio_client.dart';
import '../model/finance/fixed_expense_entry_model.dart';
import '../model/finance/fixed_expense_status_model.dart';

abstract class FixedExpenseRemoteDatasource {
  Future<List<FixedExpenseEntryModel>> getFixedExpenses({String? jenis, int? bulan, int? tahun});
  Future<FixedExpenseEntryModel> updateFixedExpense(int id, Map<String, dynamic> data);
  Future<FixedExpenseStatusModel> getFixedExpenseStatus({int? bulan, int? tahun});
  Future<int> generateBulanIni({int? bulan, int? tahun});
}

class FixedExpenseRemoteDatasourceImpl implements FixedExpenseRemoteDatasource {
  final DioClient _dioClient;
  FixedExpenseRemoteDatasourceImpl(this._dioClient);

  @override
  Future<List<FixedExpenseEntryModel>> getFixedExpenses({String? jenis, int? bulan, int? tahun}) async {
    final params = <String, dynamic>{'per_page': 100};
    if (jenis != null) params['jenis'] = jenis;
    if (bulan != null) params['bulan'] = bulan;
    if (tahun != null) params['tahun'] = tahun;

    final response = await _dioClient.get('/finance/fixed-expenses', queryParams: params);
    final data = response.data['data'] as List<dynamic>;
    return data.map((e) => FixedExpenseEntryModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<FixedExpenseEntryModel> updateFixedExpense(int id, Map<String, dynamic> data) async {
    final response = await _dioClient.put('/finance/fixed-expenses/$id', data: data);
    return FixedExpenseEntryModel.fromJson(response.data['data']);
  }

  @override
  Future<FixedExpenseStatusModel> getFixedExpenseStatus({int? bulan, int? tahun}) async {
    final params = <String, dynamic>{};
    if (bulan != null) params['bulan'] = bulan;
    if (tahun != null) params['tahun'] = tahun;
    final response = await _dioClient.get('/finance/fixed-expenses/status', queryParams: params);
    return FixedExpenseStatusModel.fromJson(response.data['data']);
  }

  @override
  Future<int> generateBulanIni({int? bulan, int? tahun}) async {
    final params = <String, dynamic>{};
    if (bulan != null) params['bulan'] = bulan;
    if (tahun != null) params['tahun'] = tahun;
    final response = await _dioClient.post('/finance/fixed-expenses/generate-bulan-ini', queryParams: params);
    return (response.data['data']['jumlah_dibuat'] as num?)?.toInt() ?? 0;
  }
}
