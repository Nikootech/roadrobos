import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage { en, hi }

class LanguageNotifier extends StateNotifier<AppLanguage> {
  static const String _prefKey = 'app_language';

  LanguageNotifier() : super(AppLanguage.en) {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString(_prefKey);
    if (langCode != null) {
      state = AppLanguage.values.firstWhere(
        (e) => e.name == langCode,
        orElse: () => AppLanguage.en,
      );
    }
  }

  Future<void> setLanguage(AppLanguage lang) async {
    state = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, lang.name);
  }
}

final languageProvider = StateNotifierProvider<LanguageNotifier, AppLanguage>((ref) {
  return LanguageNotifier();
});

class Lo {
  final AppLanguage lang;
  Lo(this.lang);

  static const Map<AppLanguage, Map<String, String>> _localizedValues = {
    AppLanguage.en: {
      'welcome': 'Welcome Back!',
      'good_morning': 'Good Morning,',
      'wallet_balance': 'Wallet Balance',
      'top_up': 'Top Up',
      'quick_actions': 'Quick Actions',
      'active_offers': 'Active Offers',
      'book_now': 'Book Now',
      'settings': 'Settings',
      'language': 'Language',
    },
    AppLanguage.hi: {
      'welcome': 'स्वागत है!',
      'good_morning': 'शुभ प्रभात,',
      'wallet_balance': 'वॉलेट बैलेंस',
      'top_up': 'टॉप अप',
      'quick_actions': 'त्वरित सेवाएँ',
      'active_offers': 'सक्रिय ऑफर्स',
      'book_now': 'अभी बुक करें',
      'settings': 'सेटिंग्स',
      'language': 'भाषा',
    },
  };

  String get(String key) => _localizedValues[lang]?[key] ?? key;
}

final l10nProvider = Provider<Lo>((ref) {
  final lang = ref.watch(languageProvider);
  return Lo(lang);
});
