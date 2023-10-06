import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:onfly/controller/expenses_controller.dart';

class CreateExpensePage extends ConsumerStatefulWidget {
  const CreateExpensePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CreateExpensePageState();
}

class _CreateExpensePageState extends ConsumerState<CreateExpensePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  double _value = 0.0;

  //TODO: MOVER
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final expenseController = ref.read(expenseControllerProvider.notifier);

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
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value != null && value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // Row(
              //   children: <Widget>[
              //     const Text('Date:'),
              //     const SizedBox(width: 10),
              //     Text(
              //       "${_selectedDate.toLocal()}".split(' ')[0],
              //       style: const TextStyle(fontSize: 55, fontWeight: FontWeight.bold),
              //     ),
              //     IconButton(
              //       onPressed: () => _selectDate(context),
              //       icon: const Icon(
              //         Icons.calendar_today,
              //         size: 40,
              //       ),
              //     ),
              //   ],
              // ),
              // const SizedBox(height: 20),
              // TextFormField(
              //   decoration: const InputDecoration(labelText: 'Value'),
              //   keyboardType: TextInputType.number,
              //   validator: (value) {
              //     if (value != null && value.isEmpty) {
              //       return 'Please enter a value';
              //     }
              //     try {
              //       double.parse(value!);
              //     } catch (e) {
              //       return 'Invalid value';
              //     }
              //     return null;
              //   },
              //   onSaved: (value) {
              //     _value = double.parse(value!);
              //   },
              // ),
              const Spacer(),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      expenseController.addExpense(ref, _titleController.text, DateTime.now(), 120.00); //TODO: informar data e valor
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
