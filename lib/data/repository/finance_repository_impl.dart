import 'package:frontend/domain/entity/finance/kpi_entity.dart';
import 'package:frontend/domain/entity/finance/revenue_entity.dart';

import '../../domain/entity/finance/invoice_entity.dart';
import '../../domain/entity/finance/payment_entity.dart';
import '../../domain/entity/finance/expense_entity.dart';
import '../../domain/repository/finance_repository.dart';
import '../datasource/finance_datasource.dart';
import '../model/finance/expense_model.dart';

class FinanceRepositoryImpl implements FinanceRepository {
  final FinanceRemoteDatasource remoteDatasource;

  FinanceRepositoryImpl({required this.remoteDatasource});

  @override
  Future<List<InvoiceEntity>> getDueInvoices() async {
    try {
      final models = await remoteDatasource.getDueInvoices();
      return models;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<PaymentEntity>> getPendingPayments() async {
    try {
      final models = await remoteDatasource.getPendingPayments();
      return models;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<KpiEntity> getKpiSummary() async {
    return await remoteDatasource.getKpiSummary();
  }

  @override
  Future<List<RevenueEntity>> getRevenueChart() async {
    return await remoteDatasource.getRevenueChart();
  }

  @override
  Future<List<ExpenseEntity>> getExpenses() async {
    return await remoteDatasource.getExpenses();
  }

  @override
  Future<ExpenseEntity> createExpense(ExpenseEntity expense) async {
    final model = ExpenseModel(
      id: expense.id,
      title: expense.title,
      amount: expense.amount,
      date: expense.date,
      category: expense.category,
      notes: expense.notes,
    );
    return await remoteDatasource.createExpense(model);
  }

  @override
  Future<ExpenseEntity> updateExpense(ExpenseEntity expense) async {
    final model = ExpenseModel(
      id: expense.id,
      title: expense.title,
      amount: expense.amount,
      date: expense.date,
      category: expense.category,
      notes: expense.notes,
    );
    return await remoteDatasource.updateExpense(model);
  }

  @override
  Future<void> deleteExpense(int id) async {
    return await remoteDatasource.deleteExpense(id);
  }
}
