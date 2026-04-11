import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../navigation/nav_helpers.dart';
import 'sos_provider.dart';

class SosSetupScreen extends ConsumerStatefulWidget {
  const SosSetupScreen({super.key});

  @override
  ConsumerState<SosSetupScreen> createState() => _SosSetupScreenState();
}

class _SosSetupScreenState extends ConsumerState<SosSetupScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _showAddContactDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Trusted Contact'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: _phoneController, decoration: const InputDecoration(labelText: 'Phone'), keyboardType: TextInputType.phone),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          TextButton(
            onPressed: () {
              if (_nameController.text.isNotEmpty && _phoneController.text.isNotEmpty) {
                ref.read(sosProvider.notifier).addContact(
                  SosContact(name: _nameController.text, phone: _phoneController.text)
                );
                _nameController.clear();
                _phoneController.clear();
                Navigator.pop(context);
                HapticFeedback.lightImpact();
              }
            },
            child: const Text('ADD'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final contacts = ref.watch(sosProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text('Emergency SOS', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
             // SOS illustration placeholder
             Container(
               padding: const EdgeInsets.all(32),
               decoration: BoxDecoration(color: AppColors.dangerRed.withOpacity(0.05), shape: BoxShape.circle),
               child: const Icon(Iconsax.shield_slash, size: 80, color: AppColors.dangerRed),
             ).animate().shake(),
             
             const SizedBox(height: 32),
             const Text('Stay Safe on Every Trip', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
             const SizedBox(height: 12),
             const Text('Add trusted contacts who can be notified instantly in case of an emergency.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary, height: 1.5)),
             
             const SizedBox(height: 40),
             if (contacts.isEmpty)
               Container(
                 padding: const EdgeInsets.all(32),
                 child: const Text('No contacts added yet', style: TextStyle(color: AppColors.textMuted)),
               )
             else
               Container(
                 padding: const EdgeInsets.all(16),
                 decoration: BoxDecoration(color: AppColors.bgLightGrey, borderRadius: BorderRadius.circular(20)),
                 child: ListView.separated(
                   shrinkWrap: true,
                   physics: const NeverScrollableScrollPhysics(),
                   itemCount: contacts.length,
                   separatorBuilder: (_, __) => const Divider(height: 32),
                   itemBuilder: (context, index) => _buildContactTile(contacts[index], context),
                 ),
               ),
             
             const SizedBox(height: 32),
             ElevatedButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _showAddContactDialog();
                },
               icon: const Icon(Iconsax.user_add, size: 20),
               label: const Text('ADD TRUSTED CONTACT'),
               style: ElevatedButton.styleFrom(
                 backgroundColor: AppColors.primaryBlue,
                 foregroundColor: Colors.white,
                 minimumSize: const Size(double.infinity, 54),
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
               ),
             ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactTile(SosContact contact, BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.person, color: AppColors.textSecondary, size: 20)),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(contact.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text(contact.phone, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.remove_circle_outline, color: AppColors.dangerRed, size: 20),
          onPressed: () {
            HapticFeedback.selectionClick();
            NavHelpers.showConfirmDialog(
              context,
              title: 'Remove Contact',
              message: 'Are you sure you want to remove ${contact.name} from your SOS list?',
              onConfirm: () {
                ref.read(sosProvider.notifier).removeContact(contact.phone);
                NavHelpers.showSuccess(context, '${contact.name} removed.');
              },
            );
          },
        ),
      ],
    );
  }
}

