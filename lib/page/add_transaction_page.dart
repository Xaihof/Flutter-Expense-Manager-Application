import 'package:f_expence_manager/page/expense_category_page.dart';
import 'package:f_expence_manager/page/income_category_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:math_expressions/math_expressions.dart';

import '../model/transaction_data.dart';
import '../service/database_helper.dart';
import '../ui/app_colors.dart';

class AddExpensePage extends StatefulWidget {
  final VoidCallback? onTransactionAdded;

  const AddExpensePage({required this.onTransactionAdded, super.key});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  // Variables
  Color incomeButtonColor = AppColors.blue;
  Color expenseButtonColor = AppColors.blue;
  Color categoryButtonColor = AppColors.blue;

  String _displayText = '';
  bool _lastWasResult = false; // Track if the last entry was a result

  int? categoryCheck;
  String? selectedCategory;

  TextEditingController _dateController = TextEditingController();
  TextEditingController _notesController = TextEditingController();
  TextEditingController _amountController = TextEditingController();

  // Custom Methods.
  Future<void> _selectDate() async {
    DateTime? _picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100));

    if (_picked != null) {
      final formattedDate = DateFormat('yyyy-MM-dd').format(_picked);

      setState(() {
        _dateController.text = formattedDate;
        print(formattedDate);
      });
    }
  }

  void _navigateToIncomeCategoryScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const IncomeCategoryPage(),
      ),
    );

    if (result != null && result is String) {
      setState(() {
        selectedCategory = result;
      });
    }
  }

  void _navigateToExpenseCategoryScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ExpenseCategoryPage(),
      ),
    );

    if (result != null && result is String) {
      setState(() {
        selectedCategory = result;
      });
    }
  }

  void _clear() {
    setState(() {
      _displayText = '';
      _lastWasResult = false; // Reset the flag
    });
  }

  void _delete() {
    setState(() {
      if (_displayText.isNotEmpty) {
        _displayText = _displayText.substring(0, _displayText.length - 1);
      }
    });
  }

  String _getLastNumber() {
    // Get the last number in the current expression
    List<String> parts = _displayText.split(RegExp(r'[\+\-\*\/]'));
    return parts.isNotEmpty ? parts.last : '';
  }

  void _appendToExpression(String symbol) {
    setState(() {
      if (_lastWasResult) {
        if ('0123456789'.contains(symbol)) {
          // If the user starts with a number after the result, we replace the display
          _displayText = symbol;
        } else {
          // If the user starts with an operator after the result, append it
          _displayText += symbol;
        }
        _lastWasResult = false; // Reset the flag after using the result
      } else {
        // Handle percentage
        if (symbol == '%') {
          // Find the last number in the expression and convert it to a percentage
          String lastNumber = _getLastNumber();
          if (lastNumber.isNotEmpty) {
            double value = double.parse(lastNumber) / 100;
            _displayText = _displayText.substring(
                    0, _displayText.length - lastNumber.length) +
                value.toString();
          }
        } else {
          // Prevent appending multiple operators in a row
          if (_displayText.isNotEmpty) {
            if ('+-*/'.contains(symbol) &&
                '+-*/'.contains(_displayText[_displayText.length - 1])) {
              return; // Don't allow consecutive operators
            }
          }
          // Prevent multiple decimal points in the same number
          if (symbol == '.' && _displayText.isNotEmpty) {
            String lastNumber = _getLastNumber();
            if (lastNumber.contains('.')) {
              return; // Don't allow another decimal point in the same number
            }
          }
          _displayText += symbol;
        }
      }
    });
  }

  void _calculate() {
    try {
      Parser p = Parser();
      Expression exp = p.parse(_displayText);
      ContextModel cm = ContextModel();
      setState(() {
        double result = exp.evaluate(EvaluationType.REAL, cm);
        _displayText = result.toStringAsFixed(2); // Limit to 2 decimal places
        _lastWasResult = true; // Mark that the last action was a result
      });
    } catch (e) {
      setState(() {
        _displayText = 'Error';
        _lastWasResult = false; // Reset on error
      });
    }
  }

  Widget _buildButton(
    String buttonText,
    Color buttonColor,
    VoidCallback onPressed,
  ) {
    return Padding(
      padding: const EdgeInsets.all(1.75),
      child: InkWell(
        child: Container(
          decoration: BoxDecoration(
            color: buttonColor,
            borderRadius: BorderRadius.circular(3.5),
          ),
          child: Center(
              child: Text(
            buttonText,
            style: const TextStyle(
              fontSize: 21,
              color: Colors.white,

            ),
          )),
        ),
        onTap: () {
          onPressed();
        },
      ),
    );
  }

  Widget _buildButtonGrid() {
    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      children: [
        _buildButton("6", AppColors.darkGreen, () => _appendToExpression("6")),
        _buildButton("7", AppColors.darkGreen, () => _appendToExpression("7")),
        _buildButton("8", AppColors.darkGreen, () => _appendToExpression("8")),
        _buildButton("9", AppColors.darkGreen, () => _appendToExpression("9")),
        _buildButton("C", Colors.yellow.shade700, _clear),
        _buildButton("AC", Colors.yellow.shade700, _clear),
        _buildButton("Del", Colors.yellow.shade700, _delete),
        _buildButton("2", AppColors.darkGreen, () => _appendToExpression("2")),
        _buildButton("3", AppColors.darkGreen, () => _appendToExpression("3")),
        _buildButton("4", AppColors.darkGreen, () => _appendToExpression("4")),
        _buildButton("5", AppColors.darkGreen, () => _appendToExpression("5")),
        _buildButton("+", Colors.yellow.shade700, () => _appendToExpression("+")),
        _buildButton("-", Colors.yellow.shade700, () => _appendToExpression("-")),
        _buildButton("x", Colors.yellow.shade700, () => _appendToExpression("*")),
        _buildButton("1", AppColors.darkGreen, () => _appendToExpression("1")),
        _buildButton("0", AppColors.darkGreen, () => _appendToExpression("0")),
        _buildButton("00", AppColors.darkGreen, () => _appendToExpression("00")),
        _buildButton(".", AppColors.darkGreen, () => _appendToExpression(".")),
        _buildButton("/", Colors.yellow.shade700, () => _appendToExpression("/")),
        _buildButton("%", Colors.yellow.shade700, () => _appendToExpression("%")),
        _buildButton("=", Colors.yellow.shade700, _calculate),
      ],
    );
  }

  Widget _buildOutput() {
    return Padding(
      padding: const EdgeInsets.all(3.5),
      child: Container(
        width: double.maxFinite,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(7.0),
        ),
        child: Padding(
          padding: const EdgeInsets.only(right: 7.0),
          child: Text(
            _displayText,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 41.0,
              fontWeight: FontWeight.bold,
              color: AppColors.blue,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyGreen,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          "Expense Manager",
          style: TextStyle(color: AppColors.blue),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            children: [
              // Income & Expense Buttons.
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Income Category Button.
                  Expanded(
                    child: InkWell(
                      child: Container(
                        decoration: BoxDecoration(
                          color: incomeButtonColor,
                          borderRadius: BorderRadius.circular(3.5),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          child: Center(
                              child: Text("Income",
                                  style: TextStyle(color: Colors.white))),
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          expenseButtonColor = AppColors.blue;
                          incomeButtonColor = AppColors.darkGreen;
                          categoryCheck = 0;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 7),
                  // Expense Category Button.
                  Expanded(
                    child: InkWell(
                      child: Container(
                        decoration: BoxDecoration(
                          color: expenseButtonColor,
                          borderRadius: BorderRadius.circular(3.5),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          child: Center(
                              child: Text("Expense",
                                  style: TextStyle(color: Colors.white))),
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          incomeButtonColor = AppColors.blue;
                          expenseButtonColor = AppColors.darkGreen;
                          categoryCheck = 1;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 7),

              // Categories Button.
              InkWell(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: categoryButtonColor,
                    borderRadius: BorderRadius.circular(3.5),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Center(
                      child: Text(
                        selectedCategory ?? 'Categories',
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                onTap: () {
                  setState(
                    () {
                      if (categoryCheck == 0) {
                        _navigateToIncomeCategoryScreen();
                        categoryButtonColor = AppColors.darkGreen;
                      } else if (categoryCheck == 1) {
                        _navigateToExpenseCategoryScreen();
                        categoryButtonColor = AppColors.darkGreen;
                      }
                    },
                  );
                },
              ),
              const SizedBox(height: 7),

              // Date Button.
              TextField(
                controller: _dateController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "Date",
                  hintStyle: TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: AppColors.blue,
                  enabledBorder: InputBorder.none,
                ),
                readOnly: true,
                onTap: () {
                  _selectDate();
                },
              ),
              const SizedBox(height: 7),

              // Add Notes.
              TextFormField(
                controller: _notesController,
                maxLines: 4,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  filled: true,
                  border: OutlineInputBorder(),
                  prefix: Padding(
                    padding: const EdgeInsets.only(right: 7.0),
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 14,
                      child: Padding(
                        padding: const EdgeInsets.all(7.0),
                        child: Image.asset("asset/image/notes.png"),
                      ),
                    ),
                  ),
                  hintText: "Notes",
                  hintStyle: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 7),

              // Calculator
              Container(
                decoration: BoxDecoration(
                  color: AppColors.blue,
                  borderRadius: BorderRadius.circular(7.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(3.5),
                  child: Column(
                    children: [
                      // Output box.
                      _buildOutput(),
                      // Buttons
                      _buildButtonGrid(),
                      const SizedBox(height: 7),
                      // Add Button
                      GestureDetector(
                        onTap: () async {
                          // 1. Get data from form fields
                          final type =
                              categoryCheck == 0 ? 'income' : 'expense';
                          final category = selectedCategory;
                          final date = DateTime.parse(_dateController.text);
                          final amount = double.parse(_displayText);
                          final note = _notesController.text;

                          // 2. Create TransactionData object
                          if (type.isEmpty &&
                              category!.isEmpty &&
                              date == null &&
                              amount == 0.0 &&
                              note.isEmpty) return;

                          final newTransaction = TransactionData(
                            type: type,
                            category: category!,
                            date: date,
                            amount: amount!,
                            note: note,
                          );

                          // 3. Insert transaction into database
                          await DatabaseHelper.insertTransaction(
                              newTransaction);

                          // 4. Close the screen
                          Navigator.pop(context); // Close AddExpensePage

                          if (widget.onTransactionAdded != null) {
                            widget.onTransactionAdded!();
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Transaction added!')),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.yellow.shade700,
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: const Center(
                            child: Text(
                              "Save Transaction",
                              style: TextStyle(
                                color: AppColors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 3.5,)
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
