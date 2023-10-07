import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:onfly/controller/expenses_controller.dart';
import 'package:onfly/model/enums/alert_type.dart';

import '../screens/expense_page.dart';
import 'alert.dart';

class ExpenseListTile extends HookConsumerWidget {
  final String expenseId;

  const ExpenseListTile(this.expenseId, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenseController = ref.watch(expenseControllerProvider.notifier);
    final expense = expenseController.getExpense(ref, expenseId);

    final alertaProvider = Provider<Alert>((ref) => Alert());
    final alerta = ref.read(alertaProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Card(
        child: ExpansionTile(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(expense!.title, style: const TextStyle(fontSize: 18.0)),
              const Text('Data: ', style: TextStyle(fontSize: 14.0)),
            ],
          ),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Valor: R\$ ${expense.value.toStringAsFixed(2)}', style: const TextStyle(fontSize: 14.0)),
              const Icon(Icons.payment, size: 32.0),
            ],
          ),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ExpensePage(
                          expenseId: expenseId,
                          title: "Editar Despesa",
                        ),
                      ),
                    );
                  },
                  child: const Text('Editar'),
                ),
                TextButton(
                  onPressed: () {
                    alerta.dialog(
                      context,
                      alertType: AlertType.warning,
                      message: "Deseja remover despesa?",
                      onPressed: () async {
                        await expenseController.removeExpense(ref, expenseId);
                        Navigator.pop(context);
                      },
                    );
                  },
                  child: const Text('Remover'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
