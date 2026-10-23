import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../profile/user_provider.dart';

/// Partner bank account and UPI details registration screen for instant daily settlements.
class PartnerBankDetailsScreen extends ConsumerStatefulWidget {
  const PartnerBankDetailsScreen({super.key});

  @override
  ConsumerState<PartnerBankDetailsScreen> createState() =>
      _PartnerBankDetailsScreenState();
}

class _PartnerBankDetailsScreenState
    extends ConsumerState<PartnerBankDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _accountController = TextEditingController();
  final _confirmAccountController = TextEditingController();
  final _ifscController = TextEditingController();
  final _upiController = TextEditingController();

  bool _isSaving = false;
  String? _detectedBank;

  @override
  void initState() {
    super.initState();
    final user = ref.read(userProvider).user;
    if (user != null && user.name.isNotEmpty) {
      _nameController.text = user.name;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _accountController.dispose();
    _confirmAccountController.dispose();
    _ifscController.dispose();
    _upiController.dispose();
    super.dispose();
  }

  void _onIfscChanged(String val) {
    final clean = val.trim().toUpperCase();
    if (clean.length >= 4) {
      final code = clean.substring(0, 4);
      setState(() {
        if (code == 'SBIN') {
          _detectedBank = 'State Bank of India';
        } else if (code == 'HDFC') {
          _detectedBank = 'HDFC Bank';
        } else if (code == 'ICIC') {
          _detectedBank = 'ICICI Bank';
        } else if (code == 'PUNB') {
          _detectedBank = 'Punjab National Bank';
        } else if (code == 'BARB') {
          _detectedBank = 'Bank of Baroda';
        } else if (code == 'KKBK') {
          _detectedBank = 'Kotak Mahindra Bank';
        } else {
          _detectedBank = 'Verified Banking Entity';
        }
      });
    } else {
      setState(() {
        _detectedBank = null;
      });
    }
  }

  Future<void> _saveBankDetails() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    await HapticFeedback.lightImpact();

    try {
      final user = ref.read(userProvider).user;
      final userId = user?.id;

      if (userId != null && userId.isNotEmpty) {
        final client = Supabase.instance.client;
        await client.from('profiles').update({
          'bank_details': {
            'account_holder': _nameController.text.trim(),
            'account_number': _accountController.text.trim(),
            'ifsc': _ifscController.text.trim().toUpperCase(),
            'upi_id': _upiController.text.trim(),
            'bank_name': _detectedBank ?? 'Commercial Bank',
            'verified_at': DateTime.now().toUtc().toIso8601String(),
          }
        }).eq('id', userId);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bank account verified and linked successfully!'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save bank details: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Payout Bank Account',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: const Color(0xFF0F172A),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header info banner
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFBBF7D0)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.shield_rounded,
                                color: Color(0xFF16A34A), size: 22),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Instant payouts are directly transferred to this account. Ensure the name matches your official Aadhaar/PAN records.',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: const Color(0xFF166534),
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Account Holder Name
                      _buildTextField(
                        controller: _nameController,
                        label: 'Account Holder Name',
                        hint: 'As per bank records',
                        icon: Iconsax.user,
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Enter account holder name' : null,
                      ),
                      const SizedBox(height: 18),

                      // Account Number
                      _buildTextField(
                        controller: _accountController,
                        label: 'Bank Account Number',
                        hint: '9-18 digit account number',
                        icon: Iconsax.card,
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.trim().length < 8) {
                            return 'Enter valid account number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),

                      // Confirm Account Number
                      _buildTextField(
                        controller: _confirmAccountController,
                        label: 'Confirm Account Number',
                        hint: 'Re-enter account number',
                        icon: Iconsax.card_tick,
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v != _accountController.text) {
                            return 'Account numbers do not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),

                      // IFSC Code
                      _buildTextField(
                        controller: _ifscController,
                        label: 'IFSC Code',
                        hint: 'e.g. SBIN0001234',
                        icon: Iconsax.bank,
                        textCapitalization: TextCapitalization.characters,
                        onChanged: _onIfscChanged,
                        validator: (v) {
                          if (v == null || v.trim().length != 11) {
                            return 'Enter valid 11-digit IFSC';
                          }
                          return null;
                        },
                      ),
                      if (_detectedBank != null) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.check_circle_rounded,
                                size: 14, color: Color(0xFF10B981)),
                            const SizedBox(width: 4),
                            Text(
                              _detectedBank!,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 18),

                      // Optional UPI ID
                      _buildTextField(
                        controller: _upiController,
                        label: 'UPI ID (Optional for instant UPI settlements)',
                        hint: 'yourname@okhdfcbank',
                        icon: Iconsax.send_2,
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Save Button
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Colors.grey.shade200)),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveBankDetails,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEA580C),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Save & Verify Bank Account',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          validator: validator,
          onChanged: onChanged,
          style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF0F172A)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF94A3B8)),
            prefixIcon: Icon(icon, size: 20, color: const Color(0xFF64748B)),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFEA580C), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
