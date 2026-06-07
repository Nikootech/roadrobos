import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import 'user_provider.dart';

class AccountSettingsScreen extends ConsumerStatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  ConsumerState<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends ConsumerState<AccountSettingsScreen> {
  bool _isEditingProfile = false;
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  bool _isBiometricEnabled = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(userProvider);
    _nameController = TextEditingController(text: user.name);
    _emailController = TextEditingController(text: user.email);
    _phoneController = TextEditingController(text: user.phone);
    _loadBiometricSettings();
  }

  Future<void> _loadBiometricSettings() async {
    setState(() {
      _isBiometricEnabled = false; // Initial
    });
  }

  Future<void> _toggleBiometric(bool value) async {
    setState(() => _isBiometricEnabled = value);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final messenger = ScaffoldMessenger.of(context);
      
      await ref.read(userProvider.notifier).updateProfile(
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
      );
      
      final userState = ref.read(userProvider);
      if (userState.error != null) {
        // Failure State
        messenger.showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: ${userState.error}'),
            backgroundColor: AppColors.dangerRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        // Success State
        setState(() => _isEditingProfile = false);
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: AppColors.successGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _updateProfilePhoto() async {
    // ignore: unawaited_futures
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Change Profile Photo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.deepNavy)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPickerOption(
                  Icons.camera_alt_rounded, 
                  'Camera', 
                  () async {
                    Navigator.pop(context);
                    await ref.read(userProvider.notifier).pickAndUploadProfilePicture(ImageSource.camera);
                  }
                ),
                _buildPickerOption(
                  Icons.photo_library_rounded, 
                  'Gallery', 
                  () async {
                    Navigator.pop(context);
                    await ref.read(userProvider.notifier).pickAndUploadProfilePicture();
                  }
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerOption(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.primaryBlue.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: AppColors.primaryBlue, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: AppColors.bgLightGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          _isEditingProfile ? 'Edit Profile' : 'Account Settings',
          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w900, fontSize: 18),
        ),
        actions: [
          if (_isEditingProfile)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: TextButton(
                onPressed: userState.isLoading ? null : _saveProfile,
                child: userState.isLoading 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('SAVE', style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.w900, fontSize: 14)),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: _isEditingProfile ? _buildEditProfileForm(userState) : _buildSettingsList(userState),
      ),
    );
  }

  Widget _buildSettingsList(UserState user) {
    return Column(
      children: [
        _buildSettingsGroup('Personal Information', [
          _buildSettingsTile(
            Icons.person_outline_rounded, 
            'Edit Profile', 
            '${user.name} • ${user.email}',
            onTap: () => setState(() => _isEditingProfile = true),
          ),
          _buildSettingsTile(Icons.add_location_alt_outlined, 'Saved Locations', 'Manage home and office addresses', onTap: () => context.push('/saved-locations')),
          _buildSettingsTile(Icons.directions_car_filled_rounded, 'My Vehicles', 'Vehicle details and RC docs', onTap: () => context.push('/my-vehicles')),
        ]),
        const SizedBox(height: 24),
        _buildSettingsGroup('Security', [
          _buildSettingsTile(
            Icons.lock_outline_rounded, 
            'Change Password', 
            'Update your security credentials',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Password reset link sent to your email!'), behavior: SnackBarBehavior.floating),
              );
            },
          ),
          _buildSettingsTile(
            Icons.fingerprint_rounded, 
            'Biometric Login', 
            'Enable Fingerprint/FaceID for login',
            trailing: Switch(
              value: _isBiometricEnabled,
              onChanged: (val) => _toggleBiometric(val),
              activeThumbColor: AppColors.primaryBlue,
            ),
          ),
          _buildSettingsTile(
            Icons.verified_user_outlined, 
            'Two-Factor Authentication', 
            'Add extra layer of security',
            onTap: () {
              showDialog(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  title: const Text('Two-Factor Authentication', style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.w900)),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.security, size: 48, color: AppColors.primaryBlue),
                      const SizedBox(height: 16),
                      const Text('Scan this QR code with your Authenticator app to enable 2FA.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary)),
                      const SizedBox(height: 16),
                      Container(
                        height: 150,
                        width: 150,
                        color: Colors.grey[200],
                        child: const Center(child: Icon(Icons.qr_code, size: 100, color: Colors.grey)),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('CANCEL', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.bold))),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('2FA Enabled Successfully!'), backgroundColor: AppColors.successGreen),
                        );
                      }, 
                      child: const Text('ENABLE 2FA', style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.w900)),
                    ),
                  ],
                ),
              );
            },
          ),
        ]),
        const SizedBox(height: 24),
        _buildSettingsGroup('Preferences', [
          _buildSettingsTile(Icons.notifications_none_rounded, 'Notification Settings', 'Manage push and email alerts', onTap: () => context.push('/notification-settings')),
          _buildSettingsTile(Icons.language_rounded, 'Language', 'Choose your preferred language', onTap: () => context.push('/language')),
        ]),
        const SizedBox(height: 24),
        _buildSettingsGroup('Legal', [
          _buildSettingsTile(
            Icons.privacy_tip_outlined,
            'Privacy Policy',
            'How we collect, use, and protect your data',
            onTap: () => launchUrl(
              Uri.parse('https://roadrobos.com/privacy'),
              mode: LaunchMode.externalApplication,
            ),
          ),
          _buildSettingsTile(
            Icons.description_outlined,
            'Terms of Service',
            'Read our terms and conditions',
            onTap: () => launchUrl(
              Uri.parse('https://roadrobos.com/terms'),
              mode: LaunchMode.externalApplication,
            ),
          ),
        ]),
        const SizedBox(height: 48),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () => ref.read(userProvider.notifier).logout(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              backgroundColor: AppColors.dangerRed.withValues(alpha: 0.08),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('LOGOUT', style: TextStyle(color: AppColors.dangerRed, fontWeight: FontWeight.w900, letterSpacing: 1)),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (dialogContext) => AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                title: const Text('Request Account Deletion?', style: TextStyle(color: AppColors.dangerRed, fontWeight: FontWeight.w900)),
                content: const Text('This will flag your account for permanent deletion. This action cannot be undone once processed by admin.', style: TextStyle(color: AppColors.textSecondary)),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('CANCEL', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.bold))),
                  TextButton(
                    onPressed: () async {
                      final router = GoRouter.of(context);
                      await ref.read(userProvider.notifier).deleteAccountRequest();
                      router.go('/auth/login');
                    }, 
                    child: const Text('CONFIRM DELETION', style: TextStyle(color: AppColors.dangerRed, fontWeight: FontWeight.w900)),
                  ),
                ],
              ),
            );
          },
          child: Text(
            'DELETE ACCOUNT', 
            style: TextStyle(
              color: AppColors.dangerRed.withValues(alpha: 0.5), 
              fontSize: 12, 
              fontWeight: FontWeight.bold, 
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditProfileForm(UserState user) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Stack(
              children: [
                Container(
                   padding: const EdgeInsets.all(4),
                   decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.2), width: 2)),
                   child: Hero(
                     tag: 'profile_pic',
                     child: CircleAvatar(
                      radius: 54,
                      backgroundColor: AppColors.bgLightGrey,
                      backgroundImage: user.profileImageUrl.isNotEmpty ? NetworkImage(user.profileImageUrl) : null,
                      child: user.isLoading 
                        ? Container(
                            decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.3), shape: BoxShape.circle),
                            child: const Center(child: CircularProgressIndicator(color: Colors.white)),
                          )
                        : (user.profileImageUrl.isEmpty ? const Icon(Icons.person, size: 54, color: AppColors.textMuted) : null),
                    ),
                   ),
                ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: InkWell(
                    onTap: user.isLoading ? null : _updateProfilePhoto,
                    child: const CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.primaryBlue,
                      child: Icon(Icons.camera_alt_rounded, color: Colors.white, size: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _buildTextField('Full Name', _nameController, Icons.person_outline_rounded),
          const SizedBox(height: 20),
          _buildTextField('Email Address', _emailController, Icons.mail_outline_rounded),
          const SizedBox(height: 20),
          _buildTextField('Phone Number', _phoneController, Icons.phone_outlined),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: user.isLoading ? null : _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: user.isLoading 
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    'SAVE CHANGES',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 0.5),
                  ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () => setState(() => _isEditingProfile = false),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.primaryBlue, size: 20),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            hintText: 'Enter $label',
            hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14, fontWeight: FontWeight.normal),
          ),
          validator: (value) => value == null || value.isEmpty ? 'This field is required' : null,
        ),
      ],
    );
  }

  Widget _buildSettingsGroup(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0),
          child: Text(title.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textSecondary, letterSpacing: 1.2)),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white, 
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black12.withValues(alpha: 0.03), blurRadius: 15, offset: const Offset(0, 5))],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, String subtitle, {VoidCallback? onTap, Widget? trailing}) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: AppColors.bgLightGrey, borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: AppColors.primaryBlue, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ).animate().fadeIn().slideX(begin: 0.05, end: 0);
  }
}
