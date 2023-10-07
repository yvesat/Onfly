import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:onfly/controller/expenses_controller.dart';

class ExpenseListTile extends HookConsumerWidget {
  final String expenseId;

  const ExpenseListTile(this.expenseId, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenseController = ref.watch(expenseControllerProvider.notifier);
    final expense = expenseController.getExpense(ref, expenseId);

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
                  onPressed: () {},
                  child: const Text('Editar'),
                ),
                TextButton(
                  onPressed: () {},
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
