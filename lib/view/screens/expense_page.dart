import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:onfly/controller/expenses_controller.dart';
import 'package:onfly/view/widgets/button.dart';
import '../widgets/alert.dart';
import '../widgets/progress.dart';

class ExpensePage extends ConsumerStatefulWidget {
  final String? expenseId;
  final String title;
  const ExpensePage({this.expenseId, required this.title, super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CreateExpensePageState();
}

class _CreateExpensePageState extends ConsumerState<ExpensePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();
  final Alert alertService = Alert();
  DateTime expenseDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final expenseControllerState = ref.watch(expenseControllerProvider);
    final expenseController = ref.read(expenseControllerProvider.notifier);
    if (widget.expenseId != null) {
      final expense = expenseController.getExpenseById(ref, widget.expenseId!);
      _titleController.text = expense!.description;
      _valueController.text = expense.amount.toStringAsFixed(2);
      expenseDate = expense.expenseDate;
    }

    final size = MediaQuery.sizeOf(context);

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            centerTitle: true,
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
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(labelText: 'Descrição'),
                      validator: (value) {
                        if (value != null && value.isEmpty) return 'Favor inserir descrição';
                        return null;
                      },
                    ),
                  ),
                  InkWell(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Data da Despesa: ",
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    DateFormat('dd/MM/yyyy').format(expenseDate),
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.calendar_today, color: Theme.of(context).colorScheme.primary),
                          ],
                        ),
                      ),
                    ),
                    onTap: () async {
                      final newDate = await expenseController.setDate(context, ref, expenseDate);
                      if (newDate != null) {
                        setState(() {
                          expenseDate = newDate;
                        });
                      }
                    },
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
                      label: "SALVAR",
                      onTap: () async {
                        SystemChannels.textInput.invokeMethod('TextInput.hide');
                        try {
                          if (_formKey.currentState!.validate()) {
                            if (widget.expenseId != null) {
                              await expenseController.updateExpense(ref, widget.expenseId!, _titleController.text, _valueController.text, expenseDate);
                            } else {
                              await expenseController.createExpense(context, ref, _titleController.text, _valueController.text, expenseDate);
                            }
                            Navigator.pop(context);
                          }
                        } catch (e) {
                          await alertService.snack(context, e.toString());
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (expenseControllerState.isLoading) Progress(size, loadingMessage: "Salvando despesa...")
      ],
    );
  }
}
