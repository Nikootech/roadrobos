import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/providers/theme_provider.dart';
import 'core/theme/app_theme.dart';
import 'features/profile/user_provider.dart';
import 'l10n/app_localizations.dart';
import 'navigation/partner_router.dart';
import 'shared/widgets/error_screen.dart';
import 'shared/widgets/role_changed_dialog.dart';

final GlobalKey<ScaffoldMessengerState> partnerScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class PartnerApp extends ConsumerWidget {
  const PartnerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(partnerRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    // Global listener for in-app role change notification (e.g. driver to tech or admin approval)
    ref.listen<UserState>(userProvider, (previous, next) {
      if (next.showRoleChangedPrompt &&
          (previous == null || !previous.showRoleChangedPrompt) &&
          next.pendingNewRole != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final ctx = partnerRootNavigatorKey.currentContext;
          if (ctx != null && ctx.mounted) {
            RoleChangedDialog.show(ctx, next.pendingNewRole!);
          }
        });
      }
    });

    return MaterialApp.router(
      scaffoldMessengerKey: partnerScaffoldMessengerKey,
      title: 'RoadRobos Partner',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      builder: (context, child) {
        ErrorWidget.builder = (FlutterErrorDetails details) =>
            GlobalErrorScreen(errorDetails: details);
        return child!;
      },
    );
  }
}
