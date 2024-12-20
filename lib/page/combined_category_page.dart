import 'package:flutter/material.dart';

import '../model/category_data.dart';
import '../service/database_helper.dart';
import '../ui/app_colors.dart';

class CombinedCategoryPage extends StatefulWidget {
  const CombinedCategoryPage({super.key});

  @override
  State<CombinedCategoryPage> createState() => _CombinedCategoryPageState();
}

class _CombinedCategoryPageState extends State<CombinedCategoryPage> {
  final PageController _pageController = PageController();
  bool showExpenseCategories = false; // Tracks the currently displayed page
  late Future<List<CategoryData>> _incomeCategoriesFuture;
  late Future<List<CategoryData>> _expenseCategoriesFuture;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _categoryNameController = TextEditingController();
  final TextEditingController _editingCategoryNameController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _incomeCategoriesFuture = DatabaseHelper.getAllIncomeCategories();
    _expenseCategoriesFuture = DatabaseHelper.getAllExpenseCategories();
  }

  void _onPageChanged(int page) {
    setState(() {
      showExpenseCategories = (page == 1); // 0 for income, 1 for expense
    });
  }

  Future<void> _addCategory() async {
    if (_formKey.currentState!.validate()) {
      final categoryName = _categoryNameController.text;
      try {
        if (showExpenseCategories) {
          await DatabaseHelper.insertExpenseCategory(categoryName);
        } else {
          await DatabaseHelper.insertIncomeCategory(categoryName);
        }
        // Refresh categories only after a successful addition
        setState(() {
          _incomeCategoriesFuture = DatabaseHelper.getAllIncomeCategories();
          _expenseCategoriesFuture = DatabaseHelper.getAllExpenseCategories();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category added successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error adding category')),
        );
      }
    }
  }

  Future<void> _deleteCategory(CategoryData category) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.blue,
        title: const CircleAvatar(
          backgroundColor: Colors.white,
          child: Icon(Icons.warning, color: Colors.red),
        ),
        content: Text(
          'Are you sure you want to delete the category "${category.name}"?\nAll entries associated with "${category.name}" will also be permanently deleted.',
          style: const TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await DatabaseHelper.deleteCategory(category.id);
                // Refresh categories only after deletion
                setState(() {
                  _incomeCategoriesFuture =
                      DatabaseHelper.getAllIncomeCategories();
                  _expenseCategoriesFuture =
                      DatabaseHelper.getAllExpenseCategories();
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Category deleted successfully')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Error deleting category')),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _editCategory(CategoryData category) async {
    _editingCategoryNameController.text = category.name;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.blue,
          title: const Text('Edit Category',
              style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: _editingCategoryNameController,
            decoration:
                const InputDecoration(filled: true),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel'
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final newCategoryName = _editingCategoryNameController.text;
                if (newCategoryName.isEmpty) return;
                try {
                  await DatabaseHelper.updateCategory(
                      category.id, newCategoryName);
                  // Refresh categories only after updating
                  setState(() {
                    _incomeCategoriesFuture =
                        DatabaseHelper.getAllIncomeCategories();
                    _expenseCategoriesFuture =
                        DatabaseHelper.getAllExpenseCategories();
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Category updated successfully')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Error updating category')),
                  );
                }
              },
              child: const Text(
                'Update',
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategoryList(Future<List<CategoryData>> futureCategories) {
    return FutureBuilder<List<CategoryData>>(
      future: futureCategories,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          final categories = snapshot.data!;
          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return ListTile(
                contentPadding:
                    const EdgeInsets.only(left: 7.0, right: 7.0, bottom: 14.0),
                leading: CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.blue,
                  child: Padding(
                    padding: const EdgeInsets.all(7.0),
                    child: Image.asset(category.picturePath,
                        color: AppColors.darkGreen),
                  ),
                ),
                title: Text(category.name,
                    style: const TextStyle(
                        fontSize: 21, fontWeight: FontWeight.bold)),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'Edit') {
                      _editCategory(category);
                    } else if (value == 'Delete') {
                      _deleteCategory(category);
                    }
                  },
                  icon: const Icon(Icons.more_horiz),
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'Edit', child: Text('Edit')),
                    const PopupMenuItem(value: 'Delete', child: Text('Delete')),
                  ],
                ),
              );
            },
          );
        } else {
          return const Center(child: Text('No categories found.'));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyGreen,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          showExpenseCategories ? 'Expense Categories' : 'Income Categories',
          style: const TextStyle(color: AppColors.blue),
        ),
      ),
      body: Column(
        children: [
          // Toggle button between income and expense
          InkWell(
            onTap: () {
              final targetPage = showExpenseCategories ? 0 : 1;
              _pageController.animateToPage(
                targetPage,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            child: Container(
              height: 35,
              width: 210,
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3.5),
                color: Colors.white,
              ),
              child: Stack(
                children: [
                  const Align(
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text("Income",
                            style: TextStyle(
                                color: AppColors.blue,
                                fontWeight: FontWeight.bold)),
                        Text("Expense",
                            style: TextStyle(
                                color: AppColors.blue,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  AnimatedAlign(
                    duration: const Duration(milliseconds: 280),
                    alignment: showExpenseCategories
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(3.5),
                      child: Container(
                        height: 35,
                        width: 91,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3.5),
                          color: AppColors.blue,
                        ),
                        child: Center(
                          child: Text(
                            showExpenseCategories ? 'Expense' : 'Income',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Divider(color: Colors.black),
          const SizedBox(height: 14),

          // Category List inside a PageView
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              children: [
                _buildCategoryList(_incomeCategoriesFuture),
                _buildCategoryList(_expenseCategoriesFuture),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.blue,
        child: const Icon(Icons.add, color: AppColors.greyGreen, size: 35),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Add Category'),
                content: Form(
                  key: _formKey,
                  child: TextFormField(
                    controller: _categoryNameController,
                    decoration:
                        const InputDecoration(labelText: 'Category Name'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter category name';
                      }
                      return null;
                    },
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      _addCategory();
                      Navigator.pop(context);
                    },
                    child: const Text('Add'),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
