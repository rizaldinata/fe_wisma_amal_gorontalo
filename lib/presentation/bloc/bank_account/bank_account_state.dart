part of 'bank_account_cubit.dart';

abstract class BankAccountState extends Equatable {
  const BankAccountState();
  @override
  List<Object?> get props => [];
}

class BankAccountInitial extends BankAccountState {
  const BankAccountInitial();
}

class BankAccountLoading extends BankAccountState {
  const BankAccountLoading();
}

class BankAccountLoaded extends BankAccountState {
  final List<BankAccountEntity> accounts;
  final String? actionError;

  const BankAccountLoaded(this.accounts, {this.actionError});

  @override
  List<Object?> get props => [accounts, actionError];
}

class BankAccountError extends BankAccountState {
  final String message;
  const BankAccountError(this.message);
  @override
  List<Object?> get props => [message];
}
