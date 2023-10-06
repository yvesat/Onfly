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

    return ExpansionTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(expense!.title, style: const TextStyle(fontSize: 18.0)),
              Text(
                'Value: R\$ ${expense.value.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 14.0),
              ),
            ],
          ),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Date: ',
                style: TextStyle(fontSize: 14.0),
              ),
              Icon(Icons.payment, size: 32.0),
            ],
          ),
        ],
      ),
      trailing: Icon(expenseController.isExpanded(expense.expenseId) ? Icons.expand_less : Icons.expand_more),
      onExpansionChanged: (expanded) {
        expenseController.toggleExpansionState(expense.expenseId);
      },
      initiallyExpanded: expenseController.isExpanded(expense.expenseId),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {},
              child: const Text('Edit'),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('Remove'),
            ),
          ],
        ),
      ],
    );
  }
}
