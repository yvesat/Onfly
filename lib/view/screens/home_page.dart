import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:onfly/controller/expenses_controller.dart';

import 'expense_page.dart';
import '../widgets/expense_tile.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  Widget build(BuildContext context) {
    final expenseController = ref.read(expenseControllerProvider.notifier);
    final expensesList = expenseController.getExpensesList(ref);

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
          final expenseId = expenseController.createExpense(ref);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ExpensePage(
                expenseId,
                title: "Nova Despesa",
              ),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}