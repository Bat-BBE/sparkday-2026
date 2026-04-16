class FinanceAccount {
  final String id;
  final String name;
  final String type;
  final String currency;
  final int balance;

  const FinanceAccount({
    required this.id,
    required this.name,
    required this.type,
    required this.currency,
    required this.balance,
  });

  factory FinanceAccount.fromJson(Map<String, dynamic> json) => FinanceAccount(
        id: (json['id'] ?? '') as String,
        name: (json['name'] ?? '') as String,
        type: (json['type'] ?? 'BANK') as String,
        currency: (json['currency'] ?? 'MNT') as String,
        balance: (json['balance'] ?? 0) as int,
      );
}

class FinanceTransaction {
  final String id;
  final String accountId;
  final String accountName;
  final String type;
  final int amount;
  final String? category;
  final String? note;
  final DateTime occurredAt;

  const FinanceTransaction({
    required this.id,
    required this.accountId,
    required this.accountName,
    required this.type,
    required this.amount,
    required this.category,
    required this.note,
    required this.occurredAt,
  });

  factory FinanceTransaction.fromJson(Map<String, dynamic> json) {
    final account = (json['account'] ?? const <String, dynamic>{}) as Map<String, dynamic>;
    return FinanceTransaction(
      id: (json['id'] ?? '') as String,
      accountId: (json['accountId'] ?? '') as String,
      accountName: (account['name'] ?? '') as String,
      type: (json['type'] ?? 'EXPENSE') as String,
      amount: (json['amount'] ?? 0) as int,
      category: json['category'] as String?,
      note: json['note'] as String?,
      occurredAt: DateTime.tryParse((json['occurredAt'] ?? '').toString()) ?? DateTime.now(),
    );
  }
}

class FinanceDebt {
  final String id;
  final String kind;
  final String status;
  final String counterparty;
  final int amount;
  final DateTime? dueDate;
  final String? note;

  const FinanceDebt({
    required this.id,
    required this.kind,
    required this.status,
    required this.counterparty,
    required this.amount,
    required this.dueDate,
    required this.note,
  });

  factory FinanceDebt.fromJson(Map<String, dynamic> json) => FinanceDebt(
        id: (json['id'] ?? '') as String,
        kind: (json['kind'] ?? 'LOAN') as String,
        status: (json['status'] ?? 'OPEN') as String,
        counterparty: (json['counterparty'] ?? '') as String,
        amount: (json['amount'] ?? 0) as int,
        dueDate: json['dueDate'] == null ? null : DateTime.tryParse(json['dueDate'].toString()),
        note: json['note'] as String?,
      );
}

class FinanceSnapshot {
  final List<FinanceAccount> accounts;
  final List<FinanceTransaction> transactions;
  final List<FinanceDebt> debts;

  const FinanceSnapshot({
    required this.accounts,
    required this.transactions,
    required this.debts,
  });

  int get totalBalance => accounts.fold(0, (s, a) => s + a.balance);
  int get totalIncome =>
      transactions.where((t) => t.type == 'INCOME').fold(0, (s, t) => s + t.amount);
  int get totalExpense =>
      transactions.where((t) => t.type == 'EXPENSE').fold(0, (s, t) => s + t.amount);
  bool get isEmpty => accounts.isEmpty && transactions.isEmpty && debts.isEmpty;
}

