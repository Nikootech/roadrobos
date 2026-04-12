class Wallet {
  final String userId;
  final double balance;
  final DateTime lastUpdated;

  Wallet({
    required this.userId,
    required this.balance,
    required this.lastUpdated,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'balance': balance,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory Wallet.fromMap(Map<String, dynamic> map) {
    return Wallet(
      userId: map['userId'] ?? '',
      balance: (map['balance'] ?? 0.0).toDouble(),
      lastUpdated: map['lastUpdated'] != null 
          ? DateTime.parse(map['lastUpdated']) 
          : DateTime.now(),
    );
  }
}

enum TransactionType { credit, debit }

class WalletTransaction {
  final String id;
  final String walletId;
  final double amount;
  final TransactionType type;
  final String description;
  final DateTime timestamp;

  WalletTransaction({
    required this.id,
    required this.walletId,
    required this.amount,
    required this.type,
    required this.description,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'walletId': walletId,
      'amount': amount,
      'type': type.name,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory WalletTransaction.fromMap(Map<String, dynamic> map, String docId) {
    return WalletTransaction(
      id: docId,
      walletId: map['walletId'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      type: TransactionType.values.byName(map['type'] ?? 'credit'),
      description: map['description'] ?? '',
      timestamp: map['timestamp'] != null 
          ? DateTime.parse(map['timestamp']) 
          : DateTime.now(),
    );
  }
}
