import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'navigation/app_router.dart';
import 'features/rentals/rental_providers.dart';
import 'shared/widgets/rental_completion_dialog.dart';
import 'core/services/gsheets_api.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GSheetsApi.init();
  runApp(const ProviderScope(child: RoadRobosApp()));
}

class RoadRobosApp extends ConsumerWidget {
  const RoadRobosApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Global listener for rental completion
    ref.listen(activeRentalProvider, (previous, next) {
      if (next?.status == RentalStatus.completed && previous?.status != RentalStatus.completed) {
        _showCompletionDialog(context, ref, next!.vehicle['name'] ?? 'Vehicle');
      }
    });

    return MaterialApp.router(
      title: 'RoAdRoBos',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: AppRouter.router,
    );
  }

  void _showCompletionDialog(BuildContext context, WidgetRef ref, String vehicleName) {
    // Note: We use the root navigator context from the router if possible, 
    // but for simplicity in this mockup, we'll try to show it on the current context.
    // In a real app, you might use a GlobalKey for the navigator.
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => RentalCompletionDialog(
        vehicleName: vehicleName,
        onCompletePayment: () {
          ref.read(activeRentalProvider.notifier).completePayment();
          Navigator.pop(context);
          // Navigate to a payment success or similar
        },
        onReschedule: () {
          // Logic for rescheduling
          Navigator.pop(context);
        },
      ),
    );
  }
}
