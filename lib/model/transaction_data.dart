class TransactionData {
  final int? id; // Optional if using autoincrement in SQLite
  final String type; // 'expense' or 'income'
  final String category;
  final DateTime date;
  final double amount;
  final String? note; // Optional additional note

  TransactionData({
    this.id,
    required this.type,
    required this.category,
    required this.date,
    required this.amount,
    this.note,
  });

  // Method to convert Transaction to a Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'category': category,
      'date': date.toIso8601String(), // Store date as ISO string
      'amount': amount,
      'note': note,
    };
  }

  // Method to create a Transaction from a Map (from SQLite)
  factory TransactionData.fromMap(Map<String, dynamic> map) {
    return TransactionData(
      id: map['id'],
      type: map['type'],
      category: map['category'],
      date: DateTime.parse(map['date']), // Parse date from ISO string
      amount: map['amount'],
      note: map['note'],
    );
  }
}