import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:onfly/controller/expenses_controller.dart';
import 'package:onfly/view/widgets/button.dart';

class CreateExpensePage extends ConsumerStatefulWidget {
  final String expenseId;
  const CreateExpensePage(this.expenseId, {super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CreateExpensePageState();
}

class _CreateExpensePageState extends ConsumerState<CreateExpensePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final expenseController = ref.read(expenseControllerProvider.notifier);
    final expense = expenseController.getExpense(ref, widget.expenseId);
    //final expense = ref.watch(expenseProvider).last;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Entry'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Card(
                child: TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Despesa'),
                  validator: (value) {
                    if (value != null && value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: <Widget>[
                      const Text('Data:'),
                      const SizedBox(width: 10),
                      Text(DateFormat('dd/MM/yyyy').format(expense!.date)),
                      IconButton(
                        onPressed: () => expenseController.setDate(context, ref, expense),
                        icon: const Icon(Icons.calendar_today),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                child: TextFormField(
                  controller: _valueController,
                  decoration: const InputDecoration(labelText: 'Valor'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value != null && value.isEmpty) {
                      return 'Favor inserir valor';
                    }
                    return null;
                  },
                ),
              ),
              const Spacer(),
              Center(
                child: Button(
                  label: "Salvar",
                  onTap: () {
                    if (_formKey.currentState!.validate()) {
                      expenseController.updateExpense(context, ref, expense, _titleController.text, _valueController.text);
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
