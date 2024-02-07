import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
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
    final expense = expenseController.getExpenseById(ref, expenseId);

    final alertaProvider = Provider<Alert>((ref) => Alert());
    final alerta = ref.read(alertaProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Card(
        child: ExpansionTile(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                  child: Text(
                expense!.description,
                style: TextStyle(fontSize: 16.0, overflow: TextOverflow.ellipsis, color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.bold),
                maxLines: 1,
              )),
              const SizedBox(width: 1),
              Text("Data: \n${DateFormat('dd/MM/yyyy').format(expense.expenseDate)}", style: const TextStyle(fontSize: 14.0)),
            ],
          ),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Valor: R\$ ${expense.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 14.0,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              if (!expense.isSynchronized) const Icon(Icons.wifi_off_sharp, size: 24.0),
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
                        builder: (context) => ExpensePage(expenseId: expenseId, title: "Editar Despesa"),
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
                        Navigator.pop(context);
                        await expenseController.removeExpense(ref, expense);
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
