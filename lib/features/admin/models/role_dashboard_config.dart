import 'package:flutter/material.dart';
import '../../../core/models/user_role.dart';

// ---------------------------------------------------------------------------
// Dashboard Section definitions
// ---------------------------------------------------------------------------

/// Identifies which sections to render in AdminDashboardScreen.
/// Each section corresponds to a widget builder in the screen.
enum DashboardSection {
  /// Real-time SOS emergency alert banner (top of screen).
  emergencyFeed,

  /// System telemetry + fleet health progress bar.
  telemetry,

  /// 2x2 executive KPI stat cards (Revenue, Rides, Services, KYC).
  /// Filtered by role — finance sees only Revenue, etc.
  statCards,

  /// 3-column ops overview (Customers / Drivers / Technicians).
  opsOverview,

  /// Quick access grid (Revenue Hub, Rides Map, Logistics, Permissions...).
  quickActions,

  /// Fleet & Operations control grid (Dispatch, Disputes, Fleet, Radar).
  fleetControl,

  /// Finance-specific section (revenue trend, payouts, refunds).
  financeSection,

  /// Support-specific section (open tickets, resolution time, escalations).
  supportSection,

  /// Marketing-specific section (offers, signups, referrals).
  marketingSection,

  /// Read-only audit feed section (audit trail, compliance items).
  auditSection,
}

// ---------------------------------------------------------------------------
// Role Dashboard Config
// ---------------------------------------------------------------------------

/// Configuration object that drives AdminDashboardScreen layout.
/// One config per role group — the screen renders only the declared sections,
/// respecting read-only constraints and skipping irrelevant Supabase streams.
class RoleDashboardConfig {
  /// Ordered list of sections to render (top -> bottom).
  final List<DashboardSection> sections;

  /// Whether ALL write actions (Dispatch, Approve, etc.) are hidden.
  /// True for auditor and analyst roles.
  final bool isReadOnly;

  /// Whether to subscribe to the emergencyAlertsProvider.
  final bool subscribeEmergencies;

  /// Whether to subscribe to financial/revenue live providers.
  final bool subscribeFinancials;

  /// Whether to subscribe to ops providers (rides, services, KYC).
  final bool subscribeOps;

  /// AppBar badge label (e.g. "OPS COMMAND", "FINANCE CONSOLE").
  final String roleLabel;

  /// Accent colour for role badge.
  final Color accentColor;

  const RoleDashboardConfig({
    required this.sections,
    required this.roleLabel,
    this.isReadOnly = false,
    this.subscribeEmergencies = false,
    this.subscribeFinancials = false,
    this.subscribeOps = false,
    this.accentColor = const Color(0xFF059669),
  });

  // ---- Factory: select config for the logged-in user's role ----------------

  factory RoleDashboardConfig.forRole(UserRole role) {
    return switch (role) {
      UserRole.financeManager => _finance,
      UserRole.supportManager => _support,
      UserRole.marketingAdmin => _marketing,
      UserRole.auditor => _auditor,
      UserRole.analyst => _analyst,
      UserRole.cityManager || UserRole.areaManager => _opsLocal,
      UserRole.opsHead => _opsHead,
      _ => _fullAccess, // superAdmin, founderAdmin, admin
    };
  }

  // ---- Pre-built configs ---------------------------------------------------

  /// Full access: superAdmin, founderAdmin, admin (legacy)
  static const _fullAccess = RoleDashboardConfig(
    roleLabel: 'ADMIN CONSOLE',
    subscribeEmergencies: true,
    subscribeFinancials: true,
    subscribeOps: true,
    sections: [
      DashboardSection.emergencyFeed,
      DashboardSection.telemetry,
      DashboardSection.statCards,
      DashboardSection.opsOverview,
      DashboardSection.quickActions,
      DashboardSection.fleetControl,
    ],
  );

  /// Ops Head: real-time operations command
  static const _opsHead = RoleDashboardConfig(
    roleLabel: 'OPS COMMAND',
    subscribeEmergencies: true,
    subscribeOps: true,
    sections: [
      DashboardSection.emergencyFeed,
      DashboardSection.telemetry,
      DashboardSection.statCards, // Active Rides + Services + KYC only
      DashboardSection.opsOverview,
      DashboardSection.fleetControl,
    ],
  );

  /// City / Area Manager: zone-level ops
  static const _opsLocal = RoleDashboardConfig(
    roleLabel: 'OPS CONSOLE',
    accentColor: Color(0xFF0284C7),
    subscribeEmergencies: true,
    subscribeOps: true,
    sections: [
      DashboardSection.emergencyFeed,
      DashboardSection.telemetry,
      DashboardSection.statCards, // Active Rides + KYC only
      DashboardSection.opsOverview,
      DashboardSection.fleetControl,
    ],
  );

  /// Finance Manager: revenue & payout focus
  static const _finance = RoleDashboardConfig(
    roleLabel: 'FINANCE CONSOLE',
    subscribeFinancials: true,
    sections: [
      DashboardSection.telemetry,
      DashboardSection.statCards, // Revenue card only
      DashboardSection.financeSection,
      DashboardSection.quickActions, // Revenue Hub tile only
    ],
  );

  /// Support Manager: tickets, disputes, feedback
  static const _support = RoleDashboardConfig(
    roleLabel: 'SUPPORT HUB',
    accentColor: Color(0xFFE11D48),
    subscribeEmergencies: true,
    sections: [
      DashboardSection.emergencyFeed,
      DashboardSection.telemetry,
      DashboardSection.supportSection,
      DashboardSection.quickActions, // Disputes + Feedback tiles only
    ],
  );

  /// Marketing Admin: campaigns, offers, acquisition
  static const _marketing = RoleDashboardConfig(
    roleLabel: 'MARKETING HUB',
    accentColor: Color(0xFFF59E0B),
    sections: [
      DashboardSection.telemetry,
      DashboardSection.marketingSection,
      DashboardSection.quickActions, // Offers & Deals tile only
    ],
  );

  /// Auditor: read-only compliance view
  static const _auditor = RoleDashboardConfig(
    roleLabel: 'AUDIT VIEW',
    accentColor: Color(0xFF475569),
    isReadOnly: true,
    subscribeFinancials: true,
    sections: [
      DashboardSection.telemetry,
      DashboardSection.statCards, // Revenue (read-only, no onTap)
      DashboardSection.auditSection,
    ],
  );

  /// Analyst: data, charts, exports — read-only
  static const _analyst = RoleDashboardConfig(
    roleLabel: 'ANALYTICS',
    accentColor: Color(0xFF4F46E5),
    isReadOnly: true,
    subscribeFinancials: true,
    subscribeOps: true,
    sections: [
      DashboardSection.telemetry,
      DashboardSection.statCards, // All KPI cards (read-only)
      DashboardSection.auditSection,
    ],
  );
}
