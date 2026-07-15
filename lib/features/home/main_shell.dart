import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/widgets/bottom_nav_bar.dart';
import '../../shared/widgets/offline_banner.dart';
import '../../core/theme/app_colors.dart';

class MainShell extends StatefulWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  // Instance field (NOT static) so it resets on every fresh Flutter app
  // initialization. On Flutter Web, Google OAuth causes a full app restart,
  // which would reset a static field too — but we now rely on the DB check
  // as the authoritative source of truth instead of this flag alone.
  bool _promptedThisSession = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndPromptPassword();
    });
  }

  Future<void> _checkAndPromptPassword() async {
    if (_promptedThisSession) return;

    // Wait briefly for page rendering
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    final supabase = Supabase.instance.client;
    final currentUser = supabase.auth.currentUser;
    if (currentUser == null) return;

    final identities = currentUser.identities ?? [];
    final hasGoogle = identities.any((id) => id.provider == 'google');
    final hasEmail = identities.any((id) => id.provider == 'email');

    // Not a Google-only account — no prompt needed.
    if (!hasGoogle || hasEmail) {
      _promptedThisSession = true;
      return;
    }

    // ── Source of truth: Supabase DB column `has_password_set` ──────────────
    // SharedPreferences is device-local; it is lost on fresh browsers/devices.
    // The DB column persists across all devices and browsers permanently.
    bool serverSuppressed = false;
    try {
      final row = await supabase
          .from('profiles')
          .select('has_password_set')
          .eq('id', currentUser.id)
          .maybeSingle();
      serverSuppressed = (row?['has_password_set'] as bool?) ?? false;
    } catch (_) {
      // If DB check fails, fall through to local cache below.
    }

    // Local cache fallback (covers offline / first-party devices)
    final prefs = await SharedPreferences.getInstance();
    final localHasPassword =
        prefs.getBool('has_password_${currentUser.id}') ?? false;
    final localSkipped =
        prefs.getBool('skipped_password_${currentUser.id}') ?? false;
    final metadataSet =
        currentUser.userMetadata?['has_password'] == true;

    final alreadyHandled =
        serverSuppressed || localHasPassword || localSkipped || metadataSet;

    debugPrint(
        'DEBUG AUTH: localHasPassword = $localHasPassword, localSkipped = $localSkipped, '
        'hasGoogle = $hasGoogle, hasEmail = $hasEmail, '
        'serverSuppressed = $serverSuppressed, alreadyHandled = $alreadyHandled');

    // Mark as checked for this session to avoid double-showing
    _promptedThisSession = true;

    if (!alreadyHandled) {
      if (!mounted) return;
      _showSetPasswordPrompt(context, supabase);
    }
  }

  /// Writes `has_password_set = true` to both local prefs and the DB.
  /// Called on both "Set Password" and "Skip" so the dialog never reappears
  /// on ANY device or browser for this user.
  Future<void> _persistPasswordHandled(
      SupabaseClient supabase, String userId, SharedPreferences prefs,
      {required bool skipped}) async {
    // Local cache — instant
    if (skipped) {
      await prefs.setBool('skipped_password_$userId', true);
    } else {
      await prefs.setBool('has_password_$userId', true);
    }
    // DB — persists across all devices/browsers
    try {
      await supabase
          .from('profiles')
          .update({'has_password_set': true}).eq('id', userId);
    } catch (e) {
      debugPrint('MainShell: failed to persist has_password_set: $e');
    }
  }

  void _showSetPasswordPrompt(BuildContext context, SupabaseClient supabase) {
    final currentUser = supabase.auth.currentUser;
    if (currentUser == null) return;

    final formKey = GlobalKey<FormState>();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.brandGreen.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.lock_outline_rounded,
                        color: AppColors.brandGreen, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Text('Create Password',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'You currently log in via Google. Would you like to create a password so you can also log in directly using your email address in the future?',
                      style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Enter a strong password',
                        prefixIcon: const Icon(Icons.lock_outline_rounded,
                            size: 20),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password is required';
                        }
                        if (value.length < 6) {
                          return 'Minimum 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: confirmPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        hintText: 'Re-enter your password',
                        prefixIcon: const Icon(Icons.lock_outline_rounded,
                            size: 20),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          final prefs = await SharedPreferences.getInstance();
                          // Persist skip permanently to DB + local so it never
                          // shows again on any device/browser.
                          await _persistPasswordHandled(
                              supabase, currentUser.id, prefs,
                              skipped: true);
                          if (dialogContext.mounted) {
                            Navigator.of(dialogContext).pop();
                          }
                        },
                  child: const Text('Skip / Ask Later',
                      style: TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.bold)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                  ),
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (formKey.currentState?.validate() ?? false) {
                            setState(() => isSaving = true);
                            try {
                              // 1. Set password + metadata in Supabase Auth
                              await supabase.auth.updateUser(
                                UserAttributes(
                                  password:
                                      passwordController.text.trim(),
                                  data: const {'has_password': true},
                                ),
                              );

                              // 2. Persist to DB + local so it never shows
                              // again on any device/browser.
                              final prefs =
                                  await SharedPreferences.getInstance();
                              await _persistPasswordHandled(
                                  supabase, currentUser.id, prefs,
                                  skipped: false);

                              // 3. Refresh session so local user picks up
                              // new metadata immediately.
                              await supabase.auth.refreshSession();

                              if (context.mounted) {
                                Navigator.of(dialogContext).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Password created successfully! You can now log in using email and password.'),
                                    backgroundColor: AppColors.brandGreen,
                                  ),
                                );
                              }
                            } catch (e) {
                              setState(() => isSaving = false);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        Text('Failed to set password: $e'),
                                    backgroundColor: AppColors.dangerRed,
                                  ),
                                );
                              }
                            }
                          }
                        },
                  child: isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Set Password',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  static const _tabs = [
    '/main/home',
    '/main/bookings',
    '/main/explore',
    '/main/profile',
  ];

  static const List<NavItemData> _customerNavItems = [
    NavItemData(
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        label: 'Home'),
    NavItemData(
        icon: Icons.calendar_today_outlined,
        activeIcon: Icons.calendar_today_rounded,
        label: 'Bookings'),
    NavItemData(
        icon: Icons.explore_outlined,
        activeIcon: Icons.explore_rounded,
        label: 'Explore'),
    NavItemData(
        icon: Icons.person_outline_rounded,
        activeIcon: Icons.person_rounded,
        label: 'Profile'),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    try {
      final location = GoRouterState.of(context).uri.toString();
      final index = _tabs.indexWhere((tab) => location.startsWith(tab));
      if (index != -1 && index != _currentIndex) {
        setState(() => _currentIndex = index);
      }
    } catch (_) {}
  }

  void _onTabTapped(int index) {
    if (index != _currentIndex) {
      setState(() => _currentIndex = index);
      context.go(_tabs[index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          body: widget.child,
          bottomNavigationBar: CustomBottomNavBar(
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
            items: _customerNavItems,
          ),
        ),
        const OfflineBanner(),
      ],
    );
  }
}
