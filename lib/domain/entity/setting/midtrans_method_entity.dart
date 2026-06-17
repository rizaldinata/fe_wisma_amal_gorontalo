class MidtransMethodEntity {
  final String code;
  final String label;
  final bool enabled;     // admin: aktif di setting
  final bool available;   // user: tidak sedang maintenance
  final bool maintenance; // user: sedang maintenance

  const MidtransMethodEntity({
    required this.code,
    required this.label,
    this.enabled = false,
    this.available = true,
    this.maintenance = false,
  });

  MidtransMethodEntity copyWith({bool? enabled}) => MidtransMethodEntity(
        code: code,
        label: label,
        enabled: enabled ?? this.enabled,
        available: available,
        maintenance: maintenance,
      );
}
