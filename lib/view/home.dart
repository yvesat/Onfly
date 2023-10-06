import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:onfly/controller/expenses_controller.dart';

import 'create_expense.dart';
import 'widgets/expense_tile.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  Widget build(BuildContext context) {
    final expensesController = ref.read(expenseControllerProvider.notifier);
    final expensesList = expensesController.getExpensesList(ref);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Onfly'),
      ),
      body: ListView.builder(
        itemCount: expensesList.length,
        itemBuilder: (context, index) {
          return ExpenseListTile(expensesList[index].expenseId);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the CreateExpense page when the FAB is pressed
          Navigator.push(context, MaterialPageRoute(builder: (context) => CreateExpensePage()));
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
