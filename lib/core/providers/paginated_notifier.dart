import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─── Paginated state ──────────────────────────────────────────────────────────

class PaginatedState<T> {
  final List<T> items;
  final bool hasMore;
  final bool isLoadingMore;
  final Object? error;

  const PaginatedState({
    this.items = const [],
    this.hasMore = true,
    this.isLoadingMore = false,
    this.error,
  });

  PaginatedState<T> copyWith({
    List<T>? items,
    bool? hasMore,
    bool? isLoadingMore,
    Object? error,
  }) =>
      PaginatedState<T>(
        items: items ?? this.items,
        hasMore: hasMore ?? this.hasMore,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        error: error,
      );
}

// ─── Base paginated notifier ──────────────────────────────────────────────────

/// Extend this for any list screen. Provides cursor-based pagination with
/// Supabase's `.range(offset, offset + pageSize - 1)`.
///
/// Usage:
///   @riverpod
///   class MyListNotifier extends _$MyListNotifier
///       implements PaginatedNotifier<MyModel> {
///     @override
///     Future<List<MyModel>> fetchPage(int offset, int limit) async {
///       final rows = await Supabase.instance.client
///           .from('my_table')
///           .select()
///           .range(offset, offset + limit - 1);
///       return rows.map(MyModel.fromMap).toList();
///     }
///   }
abstract class PaginatedNotifier<T>
    extends AutoDisposeAsyncNotifier<PaginatedState<T>> {
  static const int defaultPageSize = 20;

  int _offset = 0;

  /// Override to supply one page of results from your data source.
  Future<List<T>> fetchPage(int offset, int limit);

  @override
  Future<PaginatedState<T>> build() async {
    _offset = 0;
    final items = await fetchPage(0, defaultPageSize);
    _offset = items.length;
    return PaginatedState<T>(
      items: items,
      hasMore: items.length == defaultPageSize,
    );
  }

  /// Call from UI's scroll listener when nearing the end of the list.
  Future<void> fetchNextPage() async {
    final current = state.valueOrNull;
    if (current == null || current.isLoadingMore || !current.hasMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));

    try {
      final next = await fetchPage(_offset, defaultPageSize);
      _offset += next.length;
      state = AsyncData(current.copyWith(
        items: [...current.items, ...next],
        hasMore: next.length == defaultPageSize,
        isLoadingMore: false,
      ));
    } catch (e) {
      state = AsyncData(current.copyWith(
        isLoadingMore: false,
        error: e,
      ));
    }
  }

  /// Hard refresh — resets offset and re-fetches page 0.
  Future<void> refresh() async {
    state = const AsyncLoading();
    _offset = 0;
    state = await AsyncValue.guard(() async {
      final items = await fetchPage(0, defaultPageSize);
      _offset = items.length;
      return PaginatedState<T>(
        items: items,
        hasMore: items.length == defaultPageSize,
      );
    });
  }
}

// ─── Scroll trigger mixin for UI ──────────────────────────────────────────────

/// Call [attachScrollListener] in initState.
/// Calls [onNearEnd] when the user scrolls within [threshold] pixels of bottom.
mixin PaginationScrollMixin<T extends StatefulWidget> on State<T> {
  late final ScrollController paginationScrollController;
  static const double _threshold = 200;

  void attachScrollListener(VoidCallback onNearEnd) {
    paginationScrollController = ScrollController();
    paginationScrollController.addListener(() {
      final pos = paginationScrollController.position;
      if (pos.extentAfter < _threshold) onNearEnd();
    });
  }

  @override
  void dispose() {
    paginationScrollController.dispose();
    super.dispose();
  }
}
