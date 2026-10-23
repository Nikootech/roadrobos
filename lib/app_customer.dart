import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/providers/theme_provider.dart';
import 'core/services/payment_service.dart';
import 'core/theme/app_theme.dart';
import 'features/profile/user_provider.dart';
import 'features/rentals/rental_providers.dart';
import 'l10n/app_localizations.dart';
import 'navigation/customer_router.dart';
import 'shared/widgets/error_screen.dart';
import 'shared/widgets/rental_completion_dialog.dart';
import 'shared/widgets/role_changed_dialog.dart';

final GlobalKey<ScaffoldMessengerState> customerScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class CustomerApp extends ConsumerWidget {
  const CustomerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(customerRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    // Global listener for rental completion dialog
    ref.listen(activeRentalProvider, (previous, next) {
      if (next?.status == RentalStatus.completed &&
          previous?.status != RentalStatus.completed) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final ctx = customerRootNavigatorKey.currentContext;
          if (ctx != null && ctx.mounted) {
            _showCompletionDialog(ctx, ref, next!.vehicle['name'] ?? 'Vehicle');
          }
        });
      }
    });

    // Global listener for in-app role change notification
    ref.listen<UserState>(userProvider, (previous, next) {
      if (next.showRoleChangedPrompt &&
          (previous == null || !previous.showRoleChangedPrompt) &&
          next.pendingNewRole != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final ctx = customerRootNavigatorKey.currentContext;
          if (ctx != null && ctx.mounted) {
            RoleChangedDialog.show(ctx, next.pendingNewRole!);
          }
        });
      }
    });

    return MaterialApp.router(
      scaffoldMessengerKey: customerScaffoldMessengerKey,
      title: 'RoadRobos',
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

  void _showCompletionDialog(
      BuildContext context, WidgetRef ref, String vehicleName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => RentalCompletionDialog(
        vehicleName: vehicleName,
        onCompletePayment: () async {
          final activeRental = ref.read(activeRentalProvider);
          if (activeRental == null) return;
          final priceStr = activeRental.vehicle['price']?.toString() ?? '150';
          final hourly =
              double.tryParse(priceStr.replaceAll(RegExp(r'[^0-9.]'), '')) ??
                  150.0;
          final totalCost = hourly *
              (activeRental.duration.inHours > 0
                  ? activeRental.duration.inHours
                  : 1);
          final paymentService = ref.read(paymentServiceProvider.notifier);
          try {
            await ref.read(activeRentalProvider.notifier).completePayment(
                  totalCost: totalCost,
                  paymentService: paymentService,
                );
            if (context.mounted) Navigator.pop(context);
          } catch (e) {
            if (kDebugMode) debugPrint('Payment failed: $e');
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(e.toString())),
              );
            }
          }
        },
        onReschedule: () => Navigator.pop(context),
      ),
    );
  }
}
