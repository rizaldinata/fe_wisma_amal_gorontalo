import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entity/setting/bank_account_entity.dart';
import '../../../domain/usecase/setting/create_bank_account_usecase.dart';
import '../../../domain/usecase/setting/delete_bank_account_usecase.dart';
import '../../../domain/usecase/setting/get_bank_accounts_usecase.dart';
import '../../../domain/usecase/setting/update_bank_account_usecase.dart';

part 'bank_account_state.dart';

class BankAccountCubit extends Cubit<BankAccountState> {
  final GetBankAccountsUseCase _getAccounts;
  final CreateBankAccountUseCase _createAccount;
  final UpdateBankAccountUseCase _updateAccount;
  final DeleteBankAccountUseCase _deleteAccount;

  BankAccountCubit({
    required GetBankAccountsUseCase getAccounts,
    required CreateBankAccountUseCase createAccount,
    required UpdateBankAccountUseCase updateAccount,
    required DeleteBankAccountUseCase deleteAccount,
  })  : _getAccounts = getAccounts,
        _createAccount = createAccount,
        _updateAccount = updateAccount,
        _deleteAccount = deleteAccount,
        super(const BankAccountInitial());

  Future<void> load() async {
    emit(const BankAccountLoading());
    try {
      final accounts = await _getAccounts.execute();
      emit(BankAccountLoaded(accounts));
    } catch (e) {
      emit(BankAccountError(e.toString()));
    }
  }

  Future<void> create(Map<String, dynamic> data) async {
    final current = _currentAccounts();
    emit(const BankAccountLoading());
    try {
      await _createAccount.execute(data);
      final accounts = await _getAccounts.execute();
      emit(BankAccountLoaded(accounts));
    } catch (e) {
      emit(BankAccountLoaded(current, actionError: e.toString()));
    }
  }

  Future<void> update(int id, Map<String, dynamic> data) async {
    final current = _currentAccounts();
    emit(const BankAccountLoading());
    try {
      await _updateAccount.execute(id, data);
      final accounts = await _getAccounts.execute();
      emit(BankAccountLoaded(accounts));
    } catch (e) {
      emit(BankAccountLoaded(current, actionError: e.toString()));
    }
  }

  Future<void> delete(int id) async {
    final current = _currentAccounts();
    emit(const BankAccountLoading());
    try {
      await _deleteAccount.execute(id);
      final accounts = await _getAccounts.execute();
      emit(BankAccountLoaded(accounts));
    } catch (e) {
      emit(BankAccountLoaded(current, actionError: e.toString()));
    }
  }

  List<BankAccountEntity> _currentAccounts() {
    final s = state;
    if (s is BankAccountLoaded) return s.accounts;
    return [];
  }
}
