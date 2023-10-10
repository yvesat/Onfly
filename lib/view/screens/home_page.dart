import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../controller/expenses_controller.dart';
import '../widgets/expense_tile.dart';
import '../widgets/progress.dart';
import 'expense_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  Future<void>? _loadedData;
  @override
  void initState() {
    super.initState();
    Future(() {
      _loadedData = ref.read(expenseControllerProvider.notifier).loadExpenses(ref);
    });
  }

  @override
  Widget build(BuildContext context) {
    final expenseControllerState = ref.watch(expenseControllerProvider);

    final expenseController = ref.read(expenseControllerProvider.notifier);
    final expensesList = expenseController.getExpenseState(ref);

    final size = MediaQuery.sizeOf(context);
    return FutureBuilder(
      future: _loadedData,
      builder: (context, snapshot) => Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: const Text('Onfly'),
            ),
            body: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: expensesList.length,
                    itemBuilder: (context, index) => ExpenseListTile(expensesList[index].expenseId),
                  ),
                ),
                const SizedBox(height: 80)
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ExpensePage(title: "Nova Despesa"))),
              child: const Icon(Icons.add),
            ),
          ),
          if (expenseControllerState.isLoading) Progress(size, loadingMessage: "Carregando dados...")
        ],
      ),
    );
  }
}
