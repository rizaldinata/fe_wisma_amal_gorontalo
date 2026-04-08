enum MaintenanceStatus {
  pending('pending'),
  inProgress('in_progress'),
  completed('completed'),
  cancelled('cancelled');

  final String value;
  const MaintenanceStatus(this.value);

  factory MaintenanceStatus.fromValue(String value) {
    return MaintenanceStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => MaintenanceStatus.pending,
    );
  }
}
