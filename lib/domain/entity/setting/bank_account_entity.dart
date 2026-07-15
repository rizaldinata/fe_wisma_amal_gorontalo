class BankAccountEntity {
  final int id;
  final String bankName;
  final String accountNumber;
  final String accountHolder;
  final String? paymentInstructions;
  final bool isActive;
  final int sortOrder;

  const BankAccountEntity({
    required this.id,
    required this.bankName,
    required this.accountNumber,
    required this.accountHolder,
    this.paymentInstructions,
    required this.isActive,
    required this.sortOrder,
  });
}
