import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

/// Instant On-Demand Payout / Fast Cashout Modal Sheet for Drivers & Technicians.
class InstantCashoutSheet extends StatefulWidget {
  final double availableBalance;
  final String defaultUpiId;
  final VoidCallback? onCashoutSuccess;

  const InstantCashoutSheet({
    super.key,
    required this.availableBalance,
    this.defaultUpiId = 'driver.partner@oksbi',
    this.onCashoutSuccess,
  });

  static void show(
    BuildContext context, {
    required double availableBalance,
    String defaultUpiId = 'partner@oksbi',
    VoidCallback? onCashoutSuccess,
  }) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => InstantCashoutSheet(
        availableBalance: availableBalance,
        defaultUpiId: defaultUpiId,
        onCashoutSuccess: onCashoutSuccess,
      ),
    );
  }

  @override
  State<InstantCashoutSheet> createState() => _InstantCashoutSheetState();
}

class _InstantCashoutSheetState extends State<InstantCashoutSheet> {
  late TextEditingController _amountCtrl;
  bool _isProcessing = false;
  final double _flatFee = 5.0; // ₹5 flat instant convenience fee

  @override
  void initState() {
    super.initState();
    final defaultAmount = widget.availableBalance.clamp(100.0, 2000.0);
    _amountCtrl = TextEditingController(text: defaultAmount.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  double get _enteredAmount => double.tryParse(_amountCtrl.text) ?? 0.0;
  double get _netReceived => (_enteredAmount - _flatFee).clamp(0.0, 999999.0);

  Future<void> _processInstantCashout() async {
    if (_enteredAmount < 50.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Minimum instant cashout amount is ₹50.')),
      );
      return;
    }
    if (_enteredAmount > widget.availableBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Entered amount exceeds available wallet balance.')),
      );
      return;
    }

    setState(() => _isProcessing = true);
    await HapticFeedback.mediumImpact();

    await Future.delayed(const Duration(milliseconds: 1200));

    if (mounted) {
      setState(() => _isProcessing = false);
      Navigator.pop(context);
      widget.onCashoutSuccess?.call();

      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFF28C76F),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded,
                    color: Colors.white, size: 36),
              ),
              const SizedBox(height: 18),
              Text(
                '₹${_netReceived.toStringAsFixed(0)} Transferred!',
                style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary),
              ),
              const SizedBox(height: 6),
              Text(
                'Instant payout dispatched via UPI to ${widget.defaultUpiId}.\nReference: IMPS${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF28C76F),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Done',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        18,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(3)),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Instant 24/7 Fast Cashout',
                    style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary),
                  ),
                  const Text('Direct transfer to your verified UPI ID',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF28C76F).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.bolt_rounded,
                        size: 14, color: Color(0xFF28C76F)),
                    SizedBox(width: 2),
                    Text('Instant IMPS',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF28C76F))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          // Available Balance Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Available Balance:',
                    style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600)),
                Text('₹${widget.availableBalance.toStringAsFixed(0)}',
                    style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Amount Input
          TextField(
            controller: _amountCtrl,
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
            style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary),
            decoration: InputDecoration(
              prefixText: '₹ ',
              prefixStyle: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.brandGreen),
              labelText: 'Withdrawal Amount',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              suffixIcon: TextButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _amountCtrl.text =
                        widget.availableBalance.toStringAsFixed(0);
                  });
                },
                child: const Text('MAX',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.brandGreen)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Fee & Net breakdown
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Destination Account',
                        style: TextStyle(
                            fontSize: 11, color: AppColors.textSecondary)),
                    Text(widget.defaultUpiId,
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                  ],
                ),
                const SizedBox(height: 6),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Instant Transfer Fee (Flat)',
                        style: TextStyle(
                            fontSize: 11, color: AppColors.textSecondary)),
                    Text('₹5.00',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary)),
                  ],
                ),
                const Divider(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('You Will Receive',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary)),
                    Text('₹${_netReceived.toStringAsFixed(0)}',
                        style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF28C76F))),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isProcessing ? null : _processInstantCashout,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF28C76F),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: _isProcessing
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5))
                  : const Text('Cash Out Instantly Now',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }
}
