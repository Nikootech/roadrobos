import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences not initialized');
});

class FavoritesNotifier extends StateNotifier<Set<String>> {
  final SharedPreferences _prefs;
  static const _key = 'user_favorites';

  FavoritesNotifier(this._prefs) : super(_prefs.getStringList(_key)?.toSet() ?? {}) {
    _loadFavorites();
  }

  void _loadFavorites() {
    final list = _prefs.getStringList(_key);
    if (list != null) {
      state = list.toSet();
    }
  }

  void toggleFavorite(String itemId) {
    if (state.contains(itemId)) {
      state = {...state}..remove(itemId);
    } else {
      state = {...state}..add(itemId);
    }
    _prefs.setStringList(_key, state.toList());
  }

  bool isFavorite(String itemId) => state.contains(itemId);
}

final favoritesProvider = StateNotifierProvider<FavoritesNotifier, Set<String>>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return FavoritesNotifier(prefs);
});
