import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage { en, hi, kn, ta, te }

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

final languageProvider =
    StateNotifierProvider<LanguageNotifier, AppLanguage>((ref) {
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
    AppLanguage.kn: {
      'welcome': 'ಮತ್ತೆ ಸ್ವಾಗತ!',
      'good_morning': 'ಶುಭೋದಯ,',
      'wallet_balance': 'ವಾಲೆಟ್ ಬ್ಯಾಲೆನ್ಸ್',
      'top_up': 'ಟಾಪ್ ಅಪ್',
      'quick_actions': 'ತ್ವರಿತ ಕ್ರಿಯೆಗಳು',
      'active_offers': 'ಸಕ್ರಿಯ ಕೊಡುಗೆಗಳು',
      'book_now': 'ಈಗ ಬುಕ್ ಮಾಡಿ',
      'settings': 'ಸೆಟ್ಟಿಂಗ್‌ಗಳು',
      'language': 'ಭಾಷೆ',
    },
    AppLanguage.ta: {
      'welcome': 'மீண்டும் நல்வரவு!',
      'good_morning': 'காலை வணக்கம்,',
      'wallet_balance': 'வாலட் இருப்பு',
      'top_up': 'டாப் அப்',
      'quick_actions': 'விரைவான செயல்கள்',
      'active_offers': 'சலுகைகள்',
      'book_now': 'இப்போதே பதிவு செய்',
      'settings': 'அமைப்புகள்',
      'language': 'மொழி',
    },
    AppLanguage.te: {
      'welcome': 'మరలా స్వాగతం!',
      'good_morning': 'శుభోదయం,',
      'wallet_balance': 'వాలెట్ బ్యాలెన్స్',
      'top_up': 'టాప్ అప్',
      'quick_actions': 'త్వరిత చర్యలు',
      'active_offers': 'సక్రియ ఆఫర్‌లు',
      'book_now': 'ఇప్పుడే బుక్ చేయండి',
      'settings': 'సెట్టింగ్‌లు',
      'language': 'భాష',
    },
  };

  String get(String key) => _localizedValues[lang]?[key] ?? key;
}

final l10nProvider = Provider<Lo>((ref) {
  final lang = ref.watch(languageProvider);
  return Lo(lang);
});
