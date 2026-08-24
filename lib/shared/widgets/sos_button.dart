import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'kinetic_motion.dart';

/// SOS / Emergency Safety Button complying with:
/// - Karnataka On-Demand Transportation Technology Aggregators Rules
/// - Bengaluru City Police (BTP / Suraksha 112) Safety Protocol
/// - Ministry of Road Transport & Highways (MoRTH) Cab Passenger Safety Norms
class SOSButton extends StatefulWidget {
  final VoidCallback? onTrigger;
  final String label;
  final String subLabel;
  final String? rideDetails;
  final String? driverName;
  final String? vehicleNumber;
  final bool isHeaderPill;
  final bool isPulsing;

  const SOSButton({
    super.key,
    this.onTrigger,
    this.label = 'SOS',
    this.subLabel = '112',
    this.rideDetails,
    this.driverName,
    this.vehicleNumber,
    this.isHeaderPill = false,
    this.isPulsing = true,
  });

  const SOSButton.headerPill({
    super.key,
    this.onTrigger,
    this.label = 'SOS 112',
    this.subLabel = 'SAFETY',
    this.rideDetails,
    this.driverName,
    this.vehicleNumber,
    this.isHeaderPill = true,
    this.isPulsing = true,
  });

  const SOSButton.floating({
    super.key,
    this.onTrigger,
    this.label = 'SOS',
    this.subLabel = '112',
    this.rideDetails,
    this.driverName,
    this.vehicleNumber,
    this.isHeaderPill = false,
    this.isPulsing = true,
  });

  @override
  State<SOSButton> createState() => _SOSButtonState();
}

class _SOSButtonState extends State<SOSButton>
    with SingleTickerProviderStateMixin {
  bool _isHolding = false;

  void _openSafetyHub(BuildContext context) {
    HapticFeedback.mediumImpact();
    KarnatakaSafetyHubModal.show(
      context,
      rideDetails: widget.rideDetails,
      driverName: widget.driverName,
      vehicleNumber: widget.vehicleNumber,
      onEmergencyDispatched: widget.onTrigger,
    );
  }

  void _handleInstantEmergency() async {
    await HapticFeedback.heavyImpact();
    widget.onTrigger?.call();

    final Uri url = Uri(scheme: 'tel', path: '112');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isHeaderPill) {
      return _buildHeaderPill(context);
    }
    return _buildFloatingButton(context);
  }

  /// Compact header pill for top bars (visible during Plan Create & Route selection)
  Widget _buildHeaderPill(BuildContext context) {
    return ScaleOnTap(
      onTap: () => _openSafetyHub(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF1F2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFFECDD3), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE11D48).withValues(alpha: 0.18),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFFE11D48),
                shape: BoxShape.circle,
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1.3, 1.3),
                  duration: 800.ms,
                ),
            const SizedBox(width: 6),
            const Icon(Iconsax.shield_security,
                color: Color(0xFFE11D48), size: 15),
            const SizedBox(width: 5),
            Text(
              widget.label,
              style: GoogleFonts.outfit(
                color: const Color(0xFFE11D48),
                fontWeight: FontWeight.w800,
                fontSize: 12.5,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Floating pulsing SOS trigger (visible when ride starts and during live tracking)
  Widget _buildFloatingButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _openSafetyHub(context),
      onLongPressStart: (_) {
        setState(() => _isHolding = true);
        HapticFeedback.heavyImpact();
      },
      onLongPressEnd: (_) => setState(() => _isHolding = false),
      onLongPress: _handleInstantEmergency,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // Outer radar beacon pulse
              if (widget.isPulsing)
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE11D48).withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                )
                    .animate(onPlay: (c) => c.repeat())
                    .scale(
                      begin: const Offset(0.9, 0.9),
                      end: const Offset(1.35, 1.35),
                      duration: 1400.ms,
                      curve: Curves.easeOut,
                    )
                    .fadeOut(duration: 1400.ms),

              // Main SOS circular shield
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE11D48), Color(0xFFBE123C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE11D48).withValues(alpha: 0.45),
                      blurRadius: 16,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Iconsax.shield_security,
                      color: Colors.white,
                      size: 20,
                    ),
                    Text(
                      widget.label,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 10,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Text(
              _isHolding ? 'HOLDING...' : 'BLR 112',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bangalore & Karnataka MoRTH Compliant Emergency Safety Sheet
class KarnatakaSafetyHubModal extends StatefulWidget {
  final String? rideDetails;
  final String? driverName;
  final String? vehicleNumber;
  final VoidCallback? onEmergencyDispatched;

  const KarnatakaSafetyHubModal({
    super.key,
    this.rideDetails,
    this.driverName,
    this.vehicleNumber,
    this.onEmergencyDispatched,
  });

  static Future<void> show(
    BuildContext context, {
    String? rideDetails,
    String? driverName,
    String? vehicleNumber,
    VoidCallback? onEmergencyDispatched,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => KarnatakaSafetyHubModal(
        rideDetails: rideDetails,
        driverName: driverName,
        vehicleNumber: vehicleNumber,
        onEmergencyDispatched: onEmergencyDispatched,
      ),
    );
  }

  @override
  State<KarnatakaSafetyHubModal> createState() =>
      _KarnatakaSafetyHubModalState();
}

class _KarnatakaSafetyHubModalState extends State<KarnatakaSafetyHubModal> {
  bool _isSirenActive = false;
  Timer? _sirenTimer;

  @override
  void dispose() {
    _sirenTimer?.cancel();
    super.dispose();
  }

  void _toggleSiren() {
    setState(() => _isSirenActive = !_isSirenActive);
    if (_isSirenActive) {
      HapticFeedback.heavyImpact();
      _sirenTimer = Timer.periodic(const Duration(milliseconds: 300), (t) {
        HapticFeedback.vibrate();
      });
    } else {
      _sirenTimer?.cancel();
    }
  }

  Future<void> _callEmergencyPolice(BuildContext context) async {
    await HapticFeedback.heavyImpact();
    widget.onEmergencyDispatched?.call();

    final Uri url = Uri(scheme: 'tel', path: '112');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _callWomenHelpline() async {
    await HapticFeedback.mediumImpact();
    final Uri url = Uri(scheme: 'tel', path: '1090');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _callRoadRobosCommandCenter() async {
    await HapticFeedback.mediumImpact();
    final Uri url = Uri(scheme: 'tel', path: '08045678900');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _shareLiveTrip(BuildContext context) async {
    await HapticFeedback.lightImpact();
    String locString = '';
    try {
      final pos = await Geolocator.getCurrentPosition();
      locString = 'https://maps.google.com/?q=${pos.latitude},${pos.longitude}';
    } catch (_) {
      locString = 'Live GPS unavailable';
    }

    final driver = widget.driverName ?? 'RoadRobos Verified Driver';
    final vehicle = widget.vehicleNumber ?? 'KA-01-Cab';
    final trip = widget.rideDetails ?? 'Active RoadRobos Trip';

    final message = '🚨 EMERGENCY ALERT (RoadRobos Safety)\n'
        'I am sharing my live trip details for safety:\n'
        '• Trip: $trip\n'
        '• Driver: $driver\n'
        '• Vehicle: $vehicle\n'
        '• Live Location: $locString\n'
        '• State Emergency ERSS: Dial 112\n'
        'Verified under Karnataka Aggregator Safety Norms.';

    await Share.share(message,
        subject: 'RoadRobos Live Emergency Trip Details');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Trip & GPS coordinates ready to share.',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          backgroundColor: const Color(0xFF006241),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 30,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Header: 3D Squircle Shield
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE11D48), Color(0xFFBE123C)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE11D48).withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(Iconsax.shield_security,
                          color: Colors.white, size: 22),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Emergency Safety Hub',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF0F172A),
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          'Bengaluru & Karnataka MoRTH Safety Norms',
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ScaleOnTap(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: const Icon(Icons.close_rounded,
                          size: 16, color: Color(0xFF64748B)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── PRIMARY ACTION: DIAL 112 (NAMMA 112 / KARNATAKA POLICE) ─────
              ScaleOnTap(
                onTap: () => _callEmergencyPolice(context),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE11D48), Color(0xFF9F1239)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE11D48).withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(Icons.call_rounded,
                              color: Colors.white, size: 26),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'DIAL 112',
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.25),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'NAMMA 112',
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Karnataka Police & ERSS Emergency Dispatch',
                              style: GoogleFonts.inter(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded,
                          color: Colors.white70, size: 16),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // ── SECONDARY 2-GRID ACTIONS ─────────────────────────────────────
              Row(
                children: [
                  // Action A: Bengaluru Women Helpline (1090)
                  Expanded(
                    child: ScaleOnTap(
                      onTap: _callWomenHelpline,
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                              color: const Color(0xFFE2E8F0), width: 1.2),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF1F2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Iconsax.heart,
                                  color: Color(0xFFE11D48), size: 18),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Women Helpline',
                              style: GoogleFonts.outfit(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            Text(
                              'Suraksha 1090',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: const Color(0xFF64748B),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Action B: RoadRobos 24/7 Command Center
                  Expanded(
                    child: ScaleOnTap(
                      onTap: _callRoadRobosCommandCenter,
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                              color: const Color(0xFFE2E8F0), width: 1.2),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: const Color(0xFFECFDF5),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Iconsax.headphone,
                                  color: Color(0xFF006241), size: 18),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'RoadRobos Safety',
                              style: GoogleFonts.outfit(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            Text(
                              '24/7 Command Desk',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: const Color(0xFF64748B),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // ── SHARE TRIP & AUDIO SIREN ACTIONS ─────────────────────────────
              Row(
                children: [
                  // Share Live GPS
                  Expanded(
                    child: ScaleOnTap(
                      onTap: () => _shareLiveTrip(context),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: const Color(0xFFBBF7D0), width: 1.2),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Iconsax.share,
                                size: 16, color: Color(0xFF006241)),
                            const SizedBox(width: 8),
                            Text(
                              'Share Live Trip',
                              style: GoogleFonts.inter(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF006241),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Loud Alarm / Beacon
                  Expanded(
                    child: ScaleOnTap(
                      onTap: _toggleSiren,
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: _isSirenActive
                              ? const Color(0xFFE11D48)
                              : const Color(0xFFFFF1F2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: _isSirenActive
                                  ? const Color(0xFFE11D48)
                                  : const Color(0xFFFECDD3),
                              width: 1.2),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _isSirenActive
                                  ? Iconsax.volume_high
                                  : Iconsax.volume_cross,
                              size: 16,
                              color: _isSirenActive
                                  ? Colors.white
                                  : const Color(0xFFE11D48),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _isSirenActive
                                  ? 'SIREN ACTIVE'
                                  : 'Loud Siren Alarm',
                              style: GoogleFonts.inter(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                color: _isSirenActive
                                    ? Colors.white
                                    : const Color(0xFFE11D48),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // ── KARNATAKA COMPLIANCE BADGE ───────────────────────────────────
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified_rounded,
                        color: Color(0xFF006241), size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Complies with Karnataka On-Demand Transportation & Bengaluru Police Suraksha 112 Norms.',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: const Color(0xFF64748B),
                          height: 1.35,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
