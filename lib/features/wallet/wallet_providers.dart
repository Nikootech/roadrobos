import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/repositories/wallet_repository.dart';
import '../../core/models/wallet_model.dart';
import '../profile/user_provider.dart';

class WalletTransactionsState {
  final List<WalletTransaction> transactions;
  final bool hasMore;
  final bool isLoadingMore;
  final bool isInitialLoading;
  final String? error;

  WalletTransactionsState({
    required this.transactions,
    required this.hasMore,
    required this.isLoadingMore,
    required this.isInitialLoading,
    this.error,
  });

  WalletTransactionsState copyWith({
    List<WalletTransaction>? transactions,
    bool? hasMore,
    bool? isLoadingMore,
    bool? isInitialLoading,
    String? error,
  }) {
    return WalletTransactionsState(
      transactions: transactions ?? this.transactions,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      error: error ?? this.error,
    );
  }
}

class WalletTransactionsNotifier extends StateNotifier<WalletTransactionsState> {
  final WalletRepository _repository;
  final String? _userId;

  WalletTransactionsNotifier(this._repository, this._userId)
      : super(WalletTransactionsState(
          transactions: [],
          hasMore: true,
          isLoadingMore: false,
          isInitialLoading: true,
        )) {
    loadInitial();
  }

  Future<void> loadInitial() async {
    final userId = _userId;
    if (userId == null) {
      state = state.copyWith(isInitialLoading: false, hasMore: false);
      return;
    }
    
    // ignore: avoid_redundant_argument_values
    state = state.copyWith(isInitialLoading: true, error: null);
    try {
      final items = await _repository.getPagedTransactionHistory(userId);
      state = WalletTransactionsState(
        transactions: items,
        hasMore: items.length == 20,
        isLoadingMore: false,
        isInitialLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isInitialLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadMore() async {
    final userId = _userId;
    if (state.isLoadingMore || !state.hasMore || userId == null) return;

    state = state.copyWith(isLoadingMore: true);
    try {
      final items = await _repository.getPagedTransactionHistory(
        userId,
        offset: state.transactions.length,
      );
      state = WalletTransactionsState(
        transactions: [...state.transactions, ...items],
        hasMore: items.length == 20,
        isLoadingMore: false,
        isInitialLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }
}

final walletProvider = StreamProvider<Wallet?>((ref) {
  final user = ref.watch(userProvider).user;
  if (user == null) return Stream.value(null);
  
  return ref.watch(walletRepositoryProvider).getWallet(user.id);
});

final walletTransactionsProvider =
    StateNotifierProvider<WalletTransactionsNotifier, WalletTransactionsState>((ref) {
  final user = ref.watch(userProvider).user;
  final repository = ref.watch(walletRepositoryProvider);
  return WalletTransactionsNotifier(repository, user?.id);
});
