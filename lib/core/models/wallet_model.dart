import '../extensions/datetime_extensions.dart';

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
      'id': userId,
      'balance': balance,
      'updated_at': lastUpdated.utcIso,
    };
  }

  factory Wallet.fromMap(Map<String, dynamic> map) {
    return Wallet(
      userId: map['id'] ?? map['userId'] ?? '',
      balance: (map['balance'] ?? 0.0).toDouble(),
      lastUpdated: map['updated_at'] != null 
          ? DateTime.parse(map['updated_at']) 
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
      'wallet_id': walletId,
      'amount': amount,
      'type': type.name,
      'description': description,
      'created_at': timestamp.utcIso,
    };
  }

  factory WalletTransaction.fromMap(Map<String, dynamic> map, String docId) {
    return WalletTransaction(
      id: docId,
      walletId: map['wallet_id'] ?? map['walletId'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      type: TransactionType.values.byName(map['type'] ?? 'credit'),
      description: map['description'] ?? '',
      timestamp: map['created_at'] != null 
          ? DateTime.parse(map['created_at']) 
          : DateTime.now(),
    );
  }
}
