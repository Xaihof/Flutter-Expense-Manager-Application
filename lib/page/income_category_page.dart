import 'package:flutter/material.dart';
import '../model/category_data.dart';
import '../service/database_helper.dart';
import '../ui/app_colors.dart';

class IncomeCategoryPage extends StatefulWidget {
  const IncomeCategoryPage({super.key});

  @override
  State<IncomeCategoryPage> createState() => _IncomeCategoryPageState();
}

class _IncomeCategoryPageState extends State<IncomeCategoryPage> {
  late Future<List<CategoryData>> _incomeCategoriesFuture;

  String? selectedCategory;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _categoryNameController = TextEditingController();
  final _editingCategoryNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refreshIncomeCategories();
  }

  void _refreshIncomeCategories() {
    setState(() {
      _incomeCategoriesFuture = DatabaseHelper.getAllIncomeCategories();
    });
  }

  Future<void> _addIncomeCategory() async {
    if (_formKey.currentState!.validate()) {
      final categoryName = _categoryNameController.text;

      try {
        await DatabaseHelper.insertIncomeCategory(categoryName);
        _refreshIncomeCategories(); // Refresh the list of categories
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
    // Show confirmation dialog before deleting
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.blue,
        title: const CircleAvatar(
          backgroundColor: Colors.white,
          child: Center(
            child: Icon(
              Icons.warning,
              color: Colors.red,
            ),
          ),
        ),
        content: Text(
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
            'Are you sure you want to delete the category "${category.name}"?\nAll entries associated to "${category.name}" will also be permanently deleted.'),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            // Close dialog without deleting
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Delete category on confirmation
              try {
                await DatabaseHelper.deleteCategory(category.id);
                _refreshIncomeCategories();
                Navigator.pop(context); // Close dialog after delete
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

    // Show a dialog for editing the category name.
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.blue,
          title: const Center(
            child: Text(
              'Update Category',
              style: TextStyle(color: Colors.white),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _editingCategoryNameController,
                decoration: const InputDecoration(
                  filled: true,
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newCategoryName = _editingCategoryNameController.text;
                if (newCategoryName.isEmpty) return;
                try {
                  await DatabaseHelper.updateCategory(
                      category.id, newCategoryName);
                  _refreshIncomeCategories();
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
              child: const Text('Update'),
            ),
          ],
        );
      },
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page Name.
          const Padding(
            padding: EdgeInsets.only(
              top: 7.0,
              left: 14,
            ),
            child: Text(
              "Income Categories",
              style: TextStyle(
                  fontSize: 21,
                  color: AppColors.blue,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(color: Colors.black),
          const SizedBox(height: 14),

          // Categories.
          Expanded(
            child: FutureBuilder<List<CategoryData>>(
              future: _incomeCategoriesFuture,
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
                        contentPadding: const EdgeInsets.only(
                          left: 7.0,
                          right: 7.0,
                          bottom: 14.0,
                        ),
                        leading: CircleAvatar(
                          radius: 28,
                          backgroundColor: AppColors.blue,
                          child: Padding(
                            padding: const EdgeInsets.all(7.0),
                            child: Image.asset(category.picturePath),
                          ),
                        ),
                        title: Text(
                          category.name,
                          style: const TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            // Handle selected option
                            if (value == 'Edit') {
                              _editCategory(category);
                            } else if (value == 'Delete') {
                              _deleteCategory(category);
                            }
                          },
                          icon: const Icon(Icons.more_horiz),
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'Edit',
                              child: Text('Edit'),
                            ),
                            const PopupMenuItem(
                              value: 'Delete',
                              child: Text('Delete'),
                            ),
                          ],
                        ),
                        onTap: () {
                          setState(() {
                            selectedCategory = category.name;
                          });
                          Navigator.pop(context, selectedCategory);
                        },
                      );
                    },
                  );
                } else {
                  return const Center(child: Text('No categories found.'));
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.blue,
        child: const Icon(
          Icons.add,
          color: AppColors.greyGreen,
          size: 35,
        ),
        onPressed: () {
          setState(() {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Add Category'),
                  content: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: _categoryNameController,
                          decoration: const InputDecoration(
                            labelText: 'Category Name',
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter category name';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        _addIncomeCategory();
                        Navigator.pop(context);
                      },
                      child: const Text('Add'),
                    ),
                  ],
                );
              },
            );
          });
        },
      ),
    );
  }
}
