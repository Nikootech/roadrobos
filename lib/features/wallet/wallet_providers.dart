import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/repositories/wallet_repository.dart';
import '../../core/models/wallet_model.dart';
import '../profile/user_provider.dart';

final walletProvider = StreamProvider<Wallet?>((ref) {
  final user = ref.watch(userProvider).user;
  if (user == null) return Stream.value(null);
  
  return ref.watch(walletRepositoryProvider).getWallet(user.id);
});

final walletTransactionsProvider = FutureProvider<List<WalletTransaction>>((ref) {
  final user = ref.watch(userProvider).user;
  if (user == null) return Future.value([]);
  
  return ref.watch(walletRepositoryProvider).getPagedTransactionHistory(user.id, limit: 50);
});
