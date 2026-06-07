import 'package:flutter/material.dart';
import 'screen_security.dart';

/// Wraps a screen widget to enable FLAG_SECURE on mount and clear it on pop.
/// Use in GoRouter pageBuilder for: wallet, booking-confirmation, profile.
///
/// Example in app_router.dart:
///   pageBuilder: (ctx, state) => CustomTransitionPage(
///     key: state.pageKey,
///     child: const SecuredRoute(child: WalletTopupScreen()),
///     transitionsBuilder: ...,
///   ),
class SecuredRoute extends StatefulWidget {
  final Widget child;
  const SecuredRoute({super.key, required this.child});

  @override
  State<SecuredRoute> createState() => _SecuredRouteState();
}

class _SecuredRouteState extends State<SecuredRoute> {
  @override
  void initState() {
    super.initState();
    ScreenSecurity.secure();
  }

  @override
  void dispose() {
    ScreenSecurity.unsecure();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
