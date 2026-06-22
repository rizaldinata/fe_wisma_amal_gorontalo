class MidtransFeeItemEntity {
  final String key;
  final String label;
  final String type; // 'flat' or 'percent'
  final double? amount;
  final double? rate;

  const MidtransFeeItemEntity({
    required this.key,
    required this.label,
    required this.type,
    this.amount,
    this.rate,
  });
}

class MidtransFeeConfigEntity {
  final String bearer; // 'merchant' or 'customer'
  final List<MidtransFeeItemEntity> fees;

  const MidtransFeeConfigEntity({
    required this.bearer,
    required this.fees,
  });

  bool get isCustomerBearer => bearer == 'customer';

  Map<String, dynamic> toUpdatePayload() {
    final feesMap = <String, dynamic>{};
    for (final fee in fees) {
      if (fee.type == 'flat') {
        feesMap[fee.key] = {'type': 'flat', 'amount': fee.amount ?? 0};
      } else {
        feesMap[fee.key] = {'type': 'percent', 'rate': fee.rate ?? 0};
      }
    }
    return {'bearer': bearer, 'fees': feesMap};
  }
}
