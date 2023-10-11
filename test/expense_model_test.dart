import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:onfly/model/expense_model.dart';

void main() {
  group('Expense Model', () {
    test('Create Expense', () {
      // Arrange
      const expenseId = '12345';
      const description = 'Test Expense';
      const amount = 50.0;
      final expenseDate = DateTime(2023, 10, 20);
      const apiId = 'api123';
      const isSynchronized = true;
      const latitude = '12.345';
      const longitude = '67.890';

      // Act
      final expense = Expense(
        expenseId: expenseId,
        description: description,
        amount: amount,
        expenseDate: expenseDate,
        apiId: apiId,
        isSynchronized: isSynchronized,
        latitude: latitude,
        longitude: longitude,
      );

      // Assert
      expect(expense.expenseId, expenseId);
      expect(expense.description, description);
      expect(expense.amount, amount);
      expect(expense.expenseDate, expenseDate);
      expect(expense.apiId, apiId);
      expect(expense.isSynchronized, isSynchronized);
      expect(expense.latitude, latitude);
      expect(expense.longitude, longitude);
    });

    test('Copy Expense', () {
      // Arrange
      final originalExpense = Expense(
        expenseId: '12345',
        description: 'Original Expense',
        amount: 75.0,
        expenseDate: DateTime(2023, 10, 20),
        apiId: 'api123',
        isSynchronized: true,
        latitude: '12.345',
        longitude: '67.890',
      );

      // Act
      final copiedExpense = originalExpense.copyWith(
        description: 'Copied Expense',
        amount: 100.0,
      );

      // Assert
      expect(copiedExpense.expenseId, originalExpense.expenseId);
      expect(copiedExpense.description, 'Copied Expense');
      expect(copiedExpense.amount, 100.0);
      expect(copiedExpense.expenseDate, originalExpense.expenseDate);
      expect(copiedExpense.apiId, originalExpense.apiId);
      expect(copiedExpense.isSynchronized, originalExpense.isSynchronized);
      expect(copiedExpense.latitude, originalExpense.latitude);
      expect(copiedExpense.longitude, originalExpense.longitude);
    });

    test('Load Expense', () {
      // Arrange
      final ref = ProviderContainer();
      final notifier = ref.read(expenseProvider.notifier);
      final expense = Expense(
        expenseId: '12345',
        description: 'Loaded Expense',
        amount: 50.0,
        expenseDate: DateTime(2023, 10, 20),
        apiId: 'api123',
        isSynchronized: true,
        latitude: '12.345',
        longitude: '67.890',
      );

      // Act
      notifier.loadExpense(expense);

      // Assert
      final loadedExpense = notifier.getExpenseById(expense.expenseId);
      expect(loadedExpense, expense);
    });

    test('Edit Expense', () {
      // Arrange
      final ref = ProviderContainer();
      final notifier = ref.read(expenseProvider.notifier);
      final originalExpense = Expense(
        expenseId: '12345',
        description: 'Original Expense',
        amount: 75.0,
        expenseDate: DateTime(2023, 10, 20),
        apiId: null,
        isSynchronized: true,
        latitude: '12.345',
        longitude: '67.890',
      );
      notifier.loadExpense(originalExpense);

      // Act
      final editedExpense = notifier.editExpense(
        originalExpense.expenseId,
        newDescription: 'Edited Expense',
        newAmount: 100.0,
        isSynchronized: false,
        apiId: 'api123',
      );

      // Assert
      expect(editedExpense.description, 'Edited Expense');
      expect(editedExpense.amount, 100.0);
      expect(editedExpense.isSynchronized, false);
      expect(editedExpense.apiId, 'api123');
    });

    test('Remove Expense', () {
      // Arrange
      final ref = ProviderContainer();
      final notifier = ref.read(expenseProvider.notifier);
      final expenseToRemove = Expense(
        expenseId: '12345',
        description: 'Expense to Remove',
        amount: 50.0,
        expenseDate: DateTime(2023, 10, 20),
        apiId: 'api123',
        isSynchronized: true,
        latitude: '12.345',
        longitude: '67.890',
      );
      notifier.loadExpense(expenseToRemove);

      // Act
      notifier.removeExpense(expenseToRemove);

      // Assert
      expect(notifier.expensesList.contains(expenseToRemove), isFalse);
    });

    test('Clear Expenses', () {
      // Arrange
      final ref = ProviderContainer();
      final notifier = ref.read(expenseProvider.notifier);
      final expense = Expense(
        expenseId: '12345',
        description: 'Test Expense',
        amount: 50.0,
        expenseDate: DateTime(2023, 10, 20),
        apiId: 'api123',
        isSynchronized: true,
        latitude: '12.345',
        longitude: '67.890',
      );
      notifier.loadExpense(expense);

      // Act
      notifier.clearExpenses();

      // Assert
      expect(notifier.expensesList.isEmpty, isTrue);
    });
  });
}
