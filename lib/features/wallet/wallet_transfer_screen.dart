import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/repositories/wallet_repository.dart';
import '../profile/user_provider.dart';
import 'wallet_providers.dart';
import 'widgets/insufficient_balance_sheet.dart';

class WalletTransferScreen extends ConsumerStatefulWidget {
  const WalletTransferScreen({super.key});

  @override
  ConsumerState<WalletTransferScreen> createState() => _WalletTransferScreenState();
}

class _WalletTransferScreenState extends ConsumerState<WalletTransferScreen> {
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();
  
  bool _isLoading = false;
  bool _isSearching = false;
  Map<String, dynamic>? _resolvedRecipient;
  String? _searchError;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_onPhoneChanged);
  }

  @override
  void dispose() {
    _phoneController.removeListener(_onPhoneChanged);
    _phoneController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _onPhoneChanged() {
    final text = _phoneController.text.trim();
    // Auto-trigger lookup if it looks like a valid 10-digit number
    if (text.length == 10 && _resolvedRecipient == null && !_isSearching) {
      _lookupRecipient(text);
    } else if (text.length != 10 && (_resolvedRecipient != null || _searchError != null)) {
      setState(() {
        _resolvedRecipient = null;
        _searchError = null;
      });
    }
  }

  Future<void> _lookupRecipient(String phone) async {
    setState(() {
      _isSearching = true;
      _resolvedRecipient = null;
      _searchError = null;
    });

    try {
      final result = await ref.read(walletRepositoryProvider).lookupUserByPhone(phone);
      if (!mounted) return;
      
      setState(() {
        if (result != null) {
          _resolvedRecipient = result;
        } else {
          _searchError = 'Recipient not found. Check the number and try again.';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _searchError = 'Error finding user. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  Future<void> _transfer() async {
    final phone = _phoneController.text.trim();
    final amountStr = _amountController.text.trim();
    final amount = double.tryParse(amountStr);

    if (_resolvedRecipient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please verify the recipient first.')),
      );
      return;
    }

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount.')),
      );
      return;
    }

    final user = ref.read(userProvider).user;
    if (user == null) return;

    // Show Confirmation Dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(
            'Confirm Transfer',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Are you sure you want to send money to this recipient?',
                style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.bgLightGrey,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
                      backgroundImage: _resolvedRecipient!['avatar_url'] != null && _resolvedRecipient!['avatar_url'].toString().isNotEmpty
                          ? NetworkImage(_resolvedRecipient!['avatar_url'])
                          : null,
                      child: _resolvedRecipient!['avatar_url'] == null || _resolvedRecipient!['avatar_url'].toString().isEmpty
                          ? Text(
                              _resolvedRecipient!['full_name'] != null && _resolvedRecipient!['full_name'].toString().isNotEmpty
                                  ? _resolvedRecipient!['full_name'][0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _resolvedRecipient!['full_name'] ?? 'Recipient',
                            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            phone,
                            style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Amount to Send',
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
                  ),
                  Text(
                    '₹${amount.toStringAsFixed(2)}',
                    style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.successGreen),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: Text(
                'Confirm',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);
    try {
      final success = await ref.read(walletRepositoryProvider).transferFunds(user.id, phone, amount);
      if (success) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transfer successful!'), backgroundColor: AppColors.successGreen),
        );
        context.pop();
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Insufficient funds'), backgroundColor: AppColors.dangerRed),
        );
      }
    } on InsufficientBalanceException catch (_) {
      if (!mounted) return;
      final currentBalance = ref.read(walletProvider).value?.balance ?? 0.0;
      InsufficientBalanceSheet.show(
        context,
        currentBalance: currentBalance,
        requiredAmount: amount,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppColors.dangerRed),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLightGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Transfer Balance',
          style: GoogleFonts.outfit(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Recipient Phone Number', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: '9876543210 (10 digits)',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      suffixIcon: _isSearching
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: Padding(
                                padding: EdgeInsets.all(12.0),
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : null,
                    ),
                  ),
                ),
                if (_phoneController.text.trim().length >= 10 && _resolvedRecipient == null && !_isSearching)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: ElevatedButton(
                      onPressed: () => _lookupRecipient(_phoneController.text.trim()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      child: const Text('Verify', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),
            
            // Search Results/Error
            if (_resolvedRecipient != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.successGreen.withValues(alpha: 0.3)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
                      backgroundImage: _resolvedRecipient!['avatar_url'] != null && _resolvedRecipient!['avatar_url'].toString().isNotEmpty
                          ? NetworkImage(_resolvedRecipient!['avatar_url'])
                          : null,
                      child: _resolvedRecipient!['avatar_url'] == null || _resolvedRecipient!['avatar_url'].toString().isEmpty
                          ? Text(
                              _resolvedRecipient!['full_name'] != null && _resolvedRecipient!['full_name'].toString().isNotEmpty
                                  ? _resolvedRecipient!['full_name'][0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 16),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                _resolvedRecipient!['full_name'] ?? 'Recipient',
                                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
                              ),
                              const SizedBox(width: 6),
                              const Icon(Icons.verified, color: AppColors.successGreen, size: 16),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Verified Recipient',
                            style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),
            ] else if (_searchError != null) ...[
              const SizedBox(height: 12),
              Text(
                _searchError!,
                style: GoogleFonts.inter(color: AppColors.dangerRed, fontSize: 13, fontWeight: FontWeight.w500),
              ).animate().fadeIn(),
            ],

            const SizedBox(height: 24),
            Text('Amount (₹)', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
              decoration: InputDecoration(
                hintText: '0.00',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _isLoading || _resolvedRecipient == null ? null : _transfer,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text('Send Money', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
