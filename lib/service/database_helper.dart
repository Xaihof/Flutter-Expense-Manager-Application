import 'package:f_expence_manager/model/category_data.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import '../model/transaction_data.dart';

class DatabaseHelper {
  // Database
  static const _databaseName = 'transactions_db.db';
  static const _databaseVersion = 1;

  // Transactions Table.
  static const _transactionsTableName = "transactions";
  static const _transactionsIdColumnName = "id";
  static const _transactionsTypeColumnName = "type";
  static const _transactionsCategoryColumnName = "category";
  static const _transactionsDateColumnName = "date";
  static const _transactionsAmountColumnName = "amount";
  static const _transactionsNoteColumnName = "note";

  // Categories Table.
  static const _categoriesTableName = "categories";
  static const _categoriesIdColumnName = "id";
  static const _categoriesNameColumnName = "name";
  static const _categoriesTypeColumnName = "type";
  static const _categoriesPicturePathColumnName = "picturePath";

  // Amounts Table.

  static Future<Database>? _database;

  static Future<Database> get database async {
    try {
      if (_database != null) return _database!;

      _database = openDatabase(
          path.join(await getDatabasesPath(), _databaseName),
          version: _databaseVersion,
          onCreate: _onCreate,
          onOpen: (db) async {
            await db.execute('PRAGMA foreign_keys = ON;');
          }
      );
      return _database!;
    } catch (e) {
      throw Exception("Database initialization failed: $e");
    }
  }

  static void _onCreate(Database db, int version) async {
    // Transactions Table.
    await db.execute('''
      CREATE TABLE $_transactionsTableName(
  $_transactionsIdColumnName INTEGER PRIMARY KEY AUTOINCREMENT,
  $_transactionsTypeColumnName TEXT NOT NULL,
  $_transactionsCategoryColumnName INTEGER NOT NULL,
  $_transactionsDateColumnName TEXT NOT NULL,
  $_transactionsAmountColumnName REAL NOT NULL,
  $_transactionsNoteColumnName TEXT,
  FOREIGN KEY ($_transactionsCategoryColumnName) REFERENCES $_categoriesTableName ($_categoriesIdColumnName)
);
    ''');



    // Categories Table.
    await db.execute('''
      CREATE TABLE $_categoriesTableName(
        $_categoriesIdColumnName INTEGER PRIMARY KEY AUTOINCREMENT,
        $_categoriesNameColumnName TEXT NOT NULL UNIQUE,
        $_categoriesTypeColumnName TEXT NOT NULL,
        $_categoriesPicturePathColumnName TEXT
      )
    ''');

    // Inserting predefined income categories.
    await db.insert(
      _categoriesTableName,
      {
        'name': 'Awards',
        'type': 'income',
        'picturePath': 'asset/image/awards.png'
      },
    );
    await db.insert(
      _categoriesTableName,
      {
        'name': 'Coupons',
        'type': 'income',
        'picturePath': 'asset/image/coupen.png'
      },
    );
    await db.insert(
      _categoriesTableName,
      {
        'name': 'Grants',
        'type': 'income',
        'picturePath': 'asset/image/grants.png'
      },
    );
    await db.insert(
      _categoriesTableName,
      {
        'name': 'Refunds',
        'type': 'income',
        'picturePath': 'asset/image/refunds.png'
      },
    );
    await db.insert(
      _categoriesTableName,
      {
        'name': 'Rental',
        'type': 'income',
        'picturePath': 'asset/image/rental.png'
      },
    );
    await db.insert(
      _categoriesTableName,
      {
        'name': 'Salary',
        'type': 'income',
        'picturePath': 'asset/image/salary.png'
      },
    );
    await db.insert(
      _categoriesTableName,
      {'name': 'Sale', 'type': 'income', 'picturePath': 'asset/image/sale.png'},
    );

    // Inserting predefined expense categories.
    await db.insert(
      _categoriesTableName,
      {
        'name': 'Baby',
        'type': 'expense',
        'picturePath': 'asset/image/baby.png'
      },
    );
    await db.insert(
      _categoriesTableName,
      {
        'name': 'Beauty',
        'type': 'expense',
        'picturePath': 'asset/image/beauty.png'
      },
    );
    await db.insert(
      _categoriesTableName,
      {
        'name': 'Bills',
        'type': 'expense',
        'picturePath': 'asset/image/bills.png'
      },
    );
    await db.insert(
      _categoriesTableName,
      {
        'name': 'Education',
        'type': 'expense',
        'picturePath': 'asset/image/education.png'
      },
    );
    await db.insert(
      _categoriesTableName,
      {'name': 'Car', 'type': 'expense', 'picturePath': 'asset/image/car.png'},
    );
    await db.insert(
      _categoriesTableName,
      {
        'name': 'Clothing',
        'type': 'expense',
        'picturePath': 'asset/image/clothing.png'
      },
    );
    await db.insert(
      _categoriesTableName,
      {
        'name': 'Food',
        'type': 'expense',
        'picturePath': 'asset/image/food.png'
      },
    );
  }

  /* Transactions CRUD. */
  static Future<int> insertTransaction(TransactionData transaction) async {
    final db = await database;
    return await db.insert(_transactionsTableName, transaction.toMap());
  }

  static Future<List<TransactionData>> getAllTransactions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query(_transactionsTableName, orderBy: 'id DESC');

    return List.generate(
        maps.length, (index) => TransactionData.fromMap(maps[index]));
  }

  static Future<List<TransactionData>> getTransactionsByFilter(
      String filter,
      DateTime selectedDate,
      ) async {
    final db = await database;

    switch (filter) {
      case 'daily':
      // For daily, show transactions from the selected date
        final results = await db.query(
          _transactionsTableName,
          orderBy: 'id DESC',
          where: 'date(date) = ?',
          whereArgs: [selectedDate.toIso8601String().substring(0, 10)],
        );
        return results.map((row) => TransactionData.fromMap(row)).toList();

      case 'weekly':
      // Show transactions from today till the last 7 days (including today)
        final endDate = selectedDate;  // Today
        final startDate = selectedDate.subtract(Duration(days: 6));  // Go back 6 days

        final results = await db.query(
          _transactionsTableName,
          orderBy: 'id DESC',
          where: 'date(date) BETWEEN ? AND ?',
          whereArgs: [
            startDate.toIso8601String().substring(0, 10),
            endDate.toIso8601String().substring(0, 10)
          ],
        );
        return results.map((row) => TransactionData.fromMap(row)).toList();

      case 'monthly':
      // Show transactions from the current month
        final startDate = DateTime(selectedDate.year, selectedDate.month, 1);
        final endDate = DateTime(selectedDate.year, selectedDate.month + 1, 1)
            .subtract(Duration(days: 1));  // Last day of the current month

        final results = await db.query(
          _transactionsTableName,
          orderBy: 'id DESC',
          where: 'date(date) BETWEEN ? AND ?',
          whereArgs: [
            startDate.toIso8601String().substring(0, 10),
            endDate.toIso8601String().substring(0, 10),
          ],
        );
        return results.map((row) => TransactionData.fromMap(row)).toList();

      default:
      // Return all transactions if no specific filter is selected
        final results = await db.query(
          _transactionsTableName,
          orderBy: 'id DESC',
        );
        return results.map((row) => TransactionData.fromMap(row)).toList();
    }
  }


  static Future<List<TransactionData>> getTransactionsByCustomFilter(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await database;

    final results = await db.query(
      _transactionsTableName,
      orderBy: 'id DESC',
      where: 'date(date) BETWEEN ? AND ?',
      whereArgs: [
        startDate.toIso8601String().substring(0, 10),
        endDate.toIso8601String().substring(0, 10)
      ],
    );
    return results.map((row) => TransactionData.fromMap(row)).toList();
  }

  /* Category CRUD. */
  // Income Category.
  static Future<int> insertIncomeCategory(String name,
      {String picturePath = 'asset/image/default.png'}) async {
    final db = await database;
    return await db.insert(
      _categoriesTableName,
      {
        _categoriesNameColumnName: name,
        _categoriesTypeColumnName: "income",
        _categoriesPicturePathColumnName: picturePath,
      },
    );
  }

  static Future<int> deleteCategory(int categoryId) async {
    final db = await database;
    return await db.delete(
      _categoriesTableName,
      where: 'id = ?',
      whereArgs: [categoryId],
    );
  }

  static Future<int> updateCategory(
      int categoryId, String newCategoryName) async {
    final db = await database;
    return await db.update(
      _categoriesTableName,
      {
        _categoriesNameColumnName: newCategoryName,
      },
      where: 'id = ?',
      whereArgs: [categoryId],
    );
  }

  static Future<List<CategoryData>> getAllIncomeCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _categoriesTableName,
      where: 'type = ?',
      whereArgs: ['income'],
    );
    return maps.map((map) => CategoryData.fromMap(map)).toList();
  }

  // Expense Category.
  static Future<int> insertExpenseCategory(String name,
      {String picturePath = 'asset/image/default.png'}) async {
    final db = await database;
    return await db.insert(
      _categoriesTableName,
      {
        _categoriesNameColumnName: name,
        _categoriesTypeColumnName: "expense",
        _categoriesPicturePathColumnName: picturePath,
      },
    );
  }

  static Future<List<CategoryData>> getAllExpenseCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _categoriesTableName,
      where: 'type = ?',
      whereArgs: ['expense'],
    );
    return maps.map((map) => CategoryData.fromMap(map)).toList();
  }
}
