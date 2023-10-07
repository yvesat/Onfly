import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:onfly/controller/expenses_controller.dart';
import 'package:onfly/view/widgets/button.dart';

class EspensePage extends ConsumerStatefulWidget {
  final String expenseId;
  final String title;
  const EspensePage(this.expenseId, {required this.title, super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CreateExpensePageState();
}

class _CreateExpensePageState extends ConsumerState<EspensePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final expenseController = ref.read(expenseControllerProvider.notifier);
    final expense = expenseController.getExpense(ref, widget.expenseId);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
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
                  decoration: const InputDecoration(labelText: 'Descrição'),
                  validator: (value) {
                    if (value != null && value.isEmpty) return 'Favor inserir descrição';
                    return null;
                  },
                ),
              ),
              Card(
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        readOnly: false,
                        decoration: const InputDecoration(labelText: 'Data da Despesa'),
                        initialValue: DateFormat('dd/MM/yyyy').format(expense!.date),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    IconButton(
                      onPressed: () => expenseController.setDate(context, ref, expense),
                      icon: const Icon(Icons.calendar_today),
                    ),
                  ],
                ),
              ),
              Card(
                child: TextFormField(
                  controller: _valueController,
                  decoration: const InputDecoration(labelText: 'Valor'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value != null && value.isEmpty) return 'Favor inserir valor';
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
