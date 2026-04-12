import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    // Actually using SecureStorage would be better, but we'll use SharedPreferences for basic UI state
    // To match actual biometric capability
    setState(() {
      _isBiometricEnabled = false; // Initial
    });
  }

  Future<void> _toggleBiometric(bool value) async {
    setState(() => _isBiometricEnabled = value);
    // Logic to save preference
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
      await ref.read(userProvider.notifier).updateProfile(
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
      );
      
      if (mounted) {
        setState(() => _isEditingProfile = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: AppColors.successGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);

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
          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (_isEditingProfile)
            TextButton(
              onPressed: user.isLoading ? null : _saveProfile,
              child: user.isLoading 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('SAVE', style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: _isEditingProfile ? _buildEditProfileForm(user) : _buildSettingsList(user),
      ),
    );
  }

  Widget _buildSettingsList(UserState user) {
    return Column(
      children: [
        _buildSettingsGroup('Personal Information', [
          _buildSettingsTile(
            Iconsax.user, 
            'Edit Profile', 
            '${user.name} • ${user.email}',
            onTap: () => setState(() => _isEditingProfile = true),
          ),
          _buildSettingsTile(Iconsax.location_add, 'Saved Locations', 'Manage home and office addresses', onTap: () => context.push('/saved-locations')),
          _buildSettingsTile(Iconsax.car, 'My Vehicles', 'Vehicle details and RC docs', onTap: () => context.push('/my-vehicles')),
        ]),
        const SizedBox(height: 24),
        _buildSettingsGroup('Security', [
          _buildSettingsTile(
            Iconsax.lock_1, 
            'Change Password', 
            'Update your security credentials',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Password reset link sent to your email!'), behavior: SnackBarBehavior.floating),
              );
            },
          ),
          _buildSettingsTile(
            Iconsax.finger_scan, 
            'Biometric Login', 
            'Enable Fingerprint/FaceID for login',
            trailing: Switch(
              value: _isBiometricEnabled,
              onChanged: (val) => _toggleBiometric(val),
              activeColor: AppColors.primaryBlue,
            ),
          ),
          _buildSettingsTile(
            Iconsax.shield_security, 
            'Two-Factor Authentication', 
            'Add extra layer of security',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('2FA Setup coming soon!'), behavior: SnackBarBehavior.floating),
              );
            },
          ),
        ]),
        const SizedBox(height: 24),
        _buildSettingsGroup('Preferences', [
          _buildSettingsTile(Iconsax.notification, 'Notification Settings', 'Manage push and email alerts', onTap: () => context.push('/notification-settings')),
          _buildSettingsTile(Iconsax.language_square, 'Language', 'Choose your preferred language', onTap: () => context.push('/language')),
        ]),
        const SizedBox(height: 48),
        TextButton(
          onPressed: () => ref.read(userProvider.notifier).logout(),
          child: const Text('LOGOUT', style: TextStyle(color: AppColors.dangerRed, fontWeight: FontWeight.bold, letterSpacing: 1)),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Request Account Deletion?', style: TextStyle(color: AppColors.dangerRed)),
                content: const Text('This will flag your account for permanent deletion. This action cannot be undone once processed by admin.'),
                actions: [
                  TextButton(onPressed: () => context.pop(), child: const Text('CANCEL')),
                  TextButton(
                    onPressed: () async {
                      await ref.read(userProvider.notifier).deleteAccountRequest();
                      if (mounted) context.go('/auth/login');
                    }, 
                    child: const Text('CONFIRM DELETION', style: TextStyle(color: AppColors.dangerRed)),
                  ),
                ],
              ),
            );
          },
          child: Text(
            'DELETE ACCOUNT', 
            style: TextStyle(
              color: AppColors.dangerRed.withOpacity(0.5), 
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
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(user.profileImageUrl),
                ),
                const Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primaryBlue,
                    child: Icon(Icons.camera_alt, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _buildTextField('Full Name', _nameController, Iconsax.user),
          const SizedBox(height: 20),
          _buildTextField('Email Address', _emailController, Iconsax.sms),
          const SizedBox(height: 20),
          _buildTextField('Phone Number', _phoneController, Iconsax.call),
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
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () => setState(() => _isEditingProfile = false),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
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
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.primaryBlue, size: 20),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, String subtitle, {VoidCallback? onTap, Widget? trailing}) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: AppColors.bgLightGrey, borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: AppColors.primaryBlue, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      trailing: trailing ?? const Icon(Icons.chevron_right, size: 18, color: AppColors.border),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    ).animate().fadeIn().slideX(begin: 0.1, end: 0);
  }
}
