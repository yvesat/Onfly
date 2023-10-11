import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:onfly/model/expense_model.dart';
import 'package:onfly/view/widgets/expense_tile.dart';

void main() {
  testWidgets('Teste de Widget ExpenseListTile', (WidgetTester tester) async {
    // Dados simulados da despesa
    final expense = Expense(
      expenseId: 'expense_123',
      description: 'Despesa de Teste',
      amount: 100.0,
      expenseDate: DateTime.now(),
      apiId: 'api_123',
      isSynchronized: true,
      latitude: '12.345',
      longitude: '67.890',
    );

    // Criar um contêiner para fornecer as dependências
    final ref = ProviderContainer();
    final expenseNotifier = ref.read(expenseProvider.notifier);

    // Carregar a despesa simulada no ExpenseNotifier
    expenseNotifier.loadExpense(expense);

    // Construir a árvore de widgets do aplicativo
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          expenseProvider.overrideWith((ref) => expenseNotifier),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: ExpenseListTile('expense_123'),
          ),
        ),
      ),
    );

    // Verificar se o widget exibe as informações da despesa corretamente
    expect(find.text(expense.description), findsOneWidget);
    expect(find.text("Data: \n${DateFormat('dd/MM/yyyy').format(expense.expenseDate)}"), findsOneWidget);
    expect(find.text('Valor: R\$ ${expense.amount.toStringAsFixed(2)}'), findsOneWidget);
    expect(find.byIcon(Icons.wifi_off_sharp), findsNothing); // Supondo que isSynchronized seja verdadeiro

    // Interagir com o ícone de expansão
    final icon = find.byIcon(Icons.expand_more);
    expect(icon, findsOneWidget);
    await tester.tap(icon);
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Interagir com o botão "Remover" e o diálogo de confirmação
    await tester.tap(find.text('Remover'));
    await tester.pumpAndSettle(const Duration(seconds: 4));
    await tester.tap(find.text('CANCELAR'));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Interagir com o botão "Editar"
    await tester.tap(find.text('Editar'));
    await tester.pumpAndSettle();
  });
}
