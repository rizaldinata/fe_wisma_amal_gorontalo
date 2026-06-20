import '../../../domain/entity/setting/midtrans_fee_config_entity.dart';

class MidtransFeeConfigModel {
  final String bearer;
  final List<MidtransFeeItemModel> fees;

  const MidtransFeeConfigModel({required this.bearer, required this.fees});

  factory MidtransFeeConfigModel.fromJson(Map<String, dynamic> json) {
    final rawFees = json['fees'] as List<dynamic>? ?? [];
    return MidtransFeeConfigModel(
      bearer: json['bearer'] as String? ?? 'merchant',
      fees: rawFees.map((e) => MidtransFeeItemModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  MidtransFeeConfigEntity toEntity() => MidtransFeeConfigEntity(
        bearer: bearer,
        fees: fees.map((f) => f.toEntity()).toList(),
      );
}

class MidtransFeeItemModel {
  final String key;
  final String label;
  final String type;
  final double? amount;
  final double? rate;

  const MidtransFeeItemModel({
    required this.key,
    required this.label,
    required this.type,
    this.amount,
    this.rate,
  });

  factory MidtransFeeItemModel.fromJson(Map<String, dynamic> json) {
    return MidtransFeeItemModel(
      key:    json['key']   as String? ?? '',
      label:  json['label'] as String? ?? '',
      type:   json['type']  as String? ?? 'flat',
      amount: (json['amount'] as num?)?.toDouble(),
      rate:   (json['rate']   as num?)?.toDouble(),
    );
  }

  MidtransFeeItemEntity toEntity() => MidtransFeeItemEntity(
        key: key, label: label, type: type, amount: amount, rate: rate,
      );
}
