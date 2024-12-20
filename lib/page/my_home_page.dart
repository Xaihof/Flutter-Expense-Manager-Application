import 'package:f_expence_manager/page/add_transaction_page.dart';
import 'package:f_expence_manager/page/combined_category_page.dart';
import 'package:f_expence_manager/ui/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/transaction_data.dart';
import '../service/database_helper.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<TransactionData> transactions = [];
  DateTime? _selectedDate = DateTime.now();
  DateTime? _selectedStartDate; // For custom filter
  DateTime? _selectedEndDate;
  String _selectedFilter = 'weekly'; // Default filter is 'weekly'
  double _totalIncome = 0;
  double _totalExpense = 0;
  double _totalBalance = 0;

  @override
  void initState() {
    super.initState();
    _loadTransactions(); // Fetch initially;
  }

  Future<void> _loadTransactions() async {
    if (_selectedFilter == 'custom') {
      final transactions = await DatabaseHelper.getTransactionsByCustomFilter(
          _selectedStartDate!, _selectedEndDate!);
      setState(() {
        this.transactions = transactions;
        _calculateTotals();
      });
    } else {
      if (_selectedFilter == 'monthly') {
        // Set to the first day of the current month
        _selectedDate = DateTime(_selectedDate!.year, _selectedDate!.month, 1);
      } else if (_selectedFilter == 'daily') {
        // Set to today if daily is selected
        _selectedDate = DateTime.now();
      }

      // Fetch transactions based on filter
      final transaction = await DatabaseHelper.getTransactionsByFilter(
          _selectedFilter, _selectedDate!);
      setState(() {
        transactions = transaction;
        _calculateTotals();
      });
    }
  }

  // Utility function to calculate totals
  void _calculateTotals() {
    _totalIncome = 0;
    _totalExpense = 0;
    for (var transaction in transactions) {
      if (transaction.type == 'income') {
        _totalIncome += transaction.amount;
      } else if (transaction.type == 'expense') {
        _totalExpense += transaction.amount;
      }
    }
    _totalBalance = _totalIncome - _totalExpense;
  }

  void _previousRecord() {
    if (_selectedFilter == 'daily') {
      setState(() {
        _selectedDate = _selectedDate?.subtract(const Duration(days: 1));
      });
      _loadTransactions();
    } else if (_selectedFilter == 'weekly') {
      setState(() {
        _selectedDate = _selectedDate?.subtract(const Duration(days: 7));
      });
      _loadTransactions();
    } else if (_selectedFilter == 'monthly') {
      setState(() {
        // Set the date to the first day of the previous month
        final previousMonthStart = DateTime(
            _selectedDate!.year, _selectedDate!.month - 1, 1);
        _selectedDate = previousMonthStart;
      });
      _loadTransactions();
    }
  }

  void _nextRecord() {
    if (_selectedFilter == 'daily') {
      setState(() {
        _selectedDate = _selectedDate?.add(const Duration(days: 1));
        _loadTransactions();
      });
    } else if (_selectedFilter == 'weekly') {
      setState(() {
        _selectedDate = _selectedDate?.add(const Duration(days: 7));
        _loadTransactions();
      });
    } else if (_selectedFilter == 'monthly') {
      setState(() {
        // Move to the next month
        var nextMonthStart = DateTime(
            _selectedDate!.year, _selectedDate!.month + 1, 1);
        _selectedDate = nextMonthStart;
        _loadTransactions();
      });
    }
  }

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        _loadTransactions();
      });
    }
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Filter'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Today',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _selectedFilter == 'daily'
                            ? AppColors.blue
                            : Colors.black)),
                selected: _selectedFilter == 'daily',
                onTap: () {
                  setState(() {
                    _selectedFilter = 'daily';
                  });
                  _loadTransactions();
                  Navigator.pop(context); // Close the dialog
                },
              ),
              ListTile(
                title: Text('Weekly',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _selectedFilter == 'weekly'
                            ? AppColors.blue
                            : Colors.black)),
                selected: _selectedFilter == 'weekly',
                onTap: () {
                  setState(() {
                    _selectedFilter = 'weekly';
                  });
                  _loadTransactions();
                  Navigator.pop(context); // Close the dialog
                },
              ),
              ListTile(
                title: Text('This Month',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _selectedFilter == 'monthly'
                            ? AppColors.blue
                            : Colors.black)),
                selected: _selectedFilter == 'monthly',
                onTap: () {
                  setState(() {
                    _selectedFilter = 'monthly';
                  });
                  _loadTransactions();
                  Navigator.pop(context); // Close the dialog
                },
              ),
              ListTile(
                title: Text('Custom',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _selectedFilter == 'custom'
                            ? AppColors.blue
                            : Colors.black)),
                selected: _selectedFilter == 'custom',
                onTap: () {
                  Navigator.pop(context); // Close the filter dialog first
                  _showCustomFilterAlertDialog(); // Then open custom filter dialog
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCustomFilterAlertDialog() async {
    DateTime? startDate;
    DateTime? endDate;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Range:'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              StatefulBuilder(
                builder: (BuildContext context,
                    void Function(void Function()) setState) {
                  return ElevatedButton.icon(
                    onPressed: () async {
                      final DateTime? selectedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (selectedDate != null) {
                        setState(() {
                          startDate = selectedDate;
                        });
                      }
                    },
                    icon: const Icon(Icons.calendar_today),
                    label: Text(startDate?.toIso8601String().split('T')[0] ??
                        'Start Date'),
                  );
                },
              ),
              const SizedBox(height: 7),
              StatefulBuilder(
                builder: (BuildContext context,
                    void Function(void Function()) setState) {
                  return ElevatedButton.icon(
                    onPressed: () async {
                      final DateTime? selectedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (selectedDate != null) {
                        setState(() {
                          endDate = selectedDate;
                        });
                      }
                    },
                    icon: const Icon(Icons.calendar_today),
                    label: Text(endDate?.toIso8601String().split('T')[0] ??
                        'End Date'),
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (startDate != null && endDate != null) {
                  _selectedStartDate = startDate;
                  _selectedEndDate = endDate;
                  setState(() {
                    _selectedFilter = 'custom'; // Set the filter to 'custom'
                  });
                  _loadTransactions();
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Set'),
            ),
          ],
        );
      },
    );
  }


  Text _displayFilteredDate() {
    switch (_selectedFilter) {
      case 'daily':
        return Text(
          DateFormat('yyyy-MM-dd').format(_selectedDate!),
          // Format to show date properly
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        );
      // Get only date
      case 'weekly':
        final startOfWeek =
            _selectedDate!.subtract(const Duration(days: 6)); // 6 days ago
        final endOfWeek = _selectedDate!; // Today
        return Text(
          "${startOfWeek.toString().split(' ')[0]} - ${endOfWeek.toString().split(' ')[0]}",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        );
      case 'monthly':
        return Text(
          DateFormat('MMMM, yyyy').format(_selectedDate!),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        );
      case 'custom':
        return Text(
          "${_selectedStartDate.toString().split(' ')[0]} - ${_selectedEndDate.toString().split(' ')[0]}",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        );
      default:
        return Text(_selectedDate.toString().split(' ')[0],
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold)); // Get only date
    }
  }

  void handleTransactionAdded() {
    // Reload transactions to reflect the new addition
    _loadTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyGreen,
      appBar: AppBar(
        backgroundColor: AppColors.blue,
        title: const Text(
          "Expense Manager",
          style: TextStyle(color: AppColors.darkGreen),
        ),
        iconTheme: const IconThemeData(color: AppColors.darkGreen),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Container Expense Details.
          Container(
            height: 154,
            decoration: const BoxDecoration(
              color: AppColors.blue,
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(35),
                bottomLeft: Radius.circular(35),
              ),
            ),
            child: Column(
              children: [
                // Date Changer
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Previous date arrow
                    IconButton(
                      onPressed: () {
                        _previousRecord();
                      },
                      icon:
                          const Icon(Icons.arrow_back_ios, color: Colors.white),
                    ),

                    // Date
                    InkWell(
                      child: _displayFilteredDate(),
                      onTap: () {
                        if (_selectedFilter == 'daily') {
                          _selectDate();
                        }
                      },
                    ),

                    // Next date arrow
                    IconButton(
                      onPressed: () {
                        _nextRecord();
                      },
                      icon: const Icon(Icons.arrow_forward_ios,
                          color: Colors.white),
                    ),

                    // Filter
                    IconButton(
                      onPressed: () {
                        _showFilterDialog(context);
                      },
                      icon: const Icon(Icons.filter_list_outlined,
                          color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 21),

                // Balance
                Text("Balance: ${_totalBalance.toStringAsFixed(2)}",
                    style: const TextStyle(color: Colors.white, fontSize: 21)),
                const SizedBox(height: 21),
                // Income & Expense.
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // income
                    Text("Income: ${_totalIncome.toStringAsFixed(2)}",
                        style: const TextStyle(color: Colors.white)),
                    // expense.
                    Text("Expense: ${_totalExpense.toStringAsFixed(2)}",
                        style: const TextStyle(color: Colors.white)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 35),

          // Transactions.
          Expanded(
            child: ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                Color amountTextColor =
                    transaction.type == 'income' ? AppColors.blue : Colors.red;
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Date Container.
                              Padding(
                                padding: const EdgeInsets.only(left: 35),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.blue,
                                    borderRadius: BorderRadius.circular(3.5),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(3.5),
                                    child: Text(
                                        transaction.date
                                            .toString()
                                            .split(" ")[0],
                                        style: const TextStyle(
                                            color: Colors.white)),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 7),
                              // Category.
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 35),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(transaction.category.toString(),
                                        style: const TextStyle(
                                            color: Colors.black, fontSize: 21)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 7),
                              // Note.
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 35),
                                child: Text(transaction.note.toString()),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Column(
                            children: [
                              Text(
                                  transaction.amount
                                      .toStringAsFixed(2)
                                      .toString(),
                                  style: TextStyle(
                                    color: amountTextColor,
                                    fontSize: 21,
                                    fontWeight: FontWeight.bold,
                                  )),
                            ],
                          ),
                        )
                      ],
                    ),
                    const Divider(color: Colors.black),
                  ],
                );
              },
            ),
          ),

          // Bottom Round Add Button.
          const SizedBox(height: 35),
          Stack(
            children: [
              Container(
                  padding: const EdgeInsets.only(top: 28),
                  child: const Divider(color: AppColors.blue, thickness: 3.5)),
              InkWell(
                child: const Center(
                  child: CircleAvatar(
                    backgroundColor: AppColors.blue,
                    radius: 35,
                    child: Icon(
                      Icons.add,
                      color: AppColors.darkGreen,
                      size: 35,
                    ),
                  ),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AddExpensePage(
                        onTransactionAdded: handleTransactionAdded,
                      ),
                    ),
                  );
                },
              )
            ],
          ),

          // Bottom Navigation Bar.
          const SizedBox(height: 35),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Home
              Column(
                children: [
                  Container(
                    height: 48,
                    width: 48,
                    padding: const EdgeInsets.all(7.0),
                    decoration: BoxDecoration(
                      color: AppColors.blue,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Image.asset("asset/image/home.png"),
                  ),
                  const Text("Home")
                ],
              ),
              Column(
                children: [
                  Container(
                    height: 48,
                    width: 48,
                    padding: const EdgeInsets.all(7.0),
                    decoration: BoxDecoration(
                      color: AppColors.blue,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Image.asset("asset/image/stats.png"),
                  ),
                  const Text("Stats")
                ],
              ),
              Column(
                children: [
                  Container(
                    height: 48,
                    width: 48,
                    padding: const EdgeInsets.all(7.0),
                    decoration: BoxDecoration(
                      color: AppColors.blue,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Image.asset("asset/image/budget.png"),
                  ),
                  const Text("Budget")
                ],
              ),
              InkWell(
                  child: Column(
                    children: [
                      Container(
                        height: 48,
                        width: 48,
                        padding: const EdgeInsets.all(7.0),
                        decoration: BoxDecoration(
                          color: AppColors.blue,
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Image.asset("asset/image/categories.png"),
                      ),
                      const Text("Categories")
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CombinedCategoryPage()),
                    );
                  }),
            ],
          )
        ],
      ),
    );
  }
}
