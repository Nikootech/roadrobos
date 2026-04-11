import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:gsheets/gsheets.dart';

class GSheetsApi {
  // These should ideally be moved to an environment configuration file or secure storage
  static const _spreadsheetId = '1FSZoee_nOsmZ_pwv75GyQboNdoS55EC-meLO1l8XX4o'; 
  static const _credentialsPath = 'assets/roadrobos-service-account-key.json';

  static GSheets? _gsheets;
  static Spreadsheet? _spreadsheet;
  
  // Tab names from the Master Schema
  static const _tabCustomer = 'CUSTOMER_LIVE';
  static const _tabFleet = 'FLEET_DRIVER';
  static const _tabTech = 'TECH_OPERATIONS';
  static const _tabAdmin = 'ADMIN_CONTROL';

  /// Initializes the GSheets connection.
  static Future<void> init() async {
    try {
      final credentials = await rootBundle.loadString(_credentialsPath);
      _gsheets = GSheets(credentials);
      _spreadsheet = await _gsheets?.spreadsheet(_spreadsheetId);
      
      debugPrint('Connected to Universal Spreadsheet ID: $_spreadsheetId');
      
      // Ensure essential tabs exist (minimal set for boot)
      await _ensureWorksheet(_tabCustomer);
      await _ensureWorksheet(_tabFleet);
      await _ensureWorksheet(_tabTech);
      await _ensureWorksheet(_tabAdmin);
      
      debugPrint('Universal GSheets System Ready.');
    } catch (e) {
      debugPrint('GSheets Initialization Error: $e');
    }
  }

  static Future<Worksheet?> _ensureWorksheet(String title) async {
    final sheet = _spreadsheet?.worksheetByTitle(title);
    if (sheet == null) {
      debugPrint('Creating missing tab: $title');
      return await _spreadsheet?.addWorksheet(title);
    }
    return sheet;
  }

  /// Unified insertion method for any tab
  static Future<bool> logToTab(String tabName, List<dynamic> row) async {
    try {
      _spreadsheet ??= await _gsheets?.spreadsheet(_spreadsheetId);
      final sheet = _spreadsheet?.worksheetByTitle(tabName);
      if (sheet == null) {
        debugPrint('GSheets Error: Tab "$tabName" not found.');
        return false;
      }
      
      // Add timestamp to every row at position 0 if not present
      final timestamp = DateTime.now().toString().split('.').first; // yyyy-MM-dd HH:mm:ss
      final finalRow = [timestamp, ...row];
      
      return await sheet.values.appendRows([finalRow]);
    } catch (e) {
      debugPrint('GSheets Sync Error ($tabName): $e');
      return false;
    }
  }

  // --- Specialized Logging Methods ---

  static Future<void> logCustomerActivity(String event, {String? vehicle, String? price, String? details}) async {
    await logToTab(_tabCustomer, [
      event,
      'DEVICE_USER', // Placeholder until auth is linked
      vehicle ?? 'N/A',
      price ?? 'N/A',
      'ACTIVE',
      details ?? ''
    ]);
  }

  static Future<void> logFleetActivity(String driverId, String action, {String? impact, String? status, String? details}) async {
    await logToTab(_tabFleet, [
      driverId,
      'Driver Name', // Placeholder
      action,
      impact ?? '0',
      '0 km', // Placeholder
      status ?? 'ONLINE',
      details ?? ''
    ]);
  }

  /// Registers a new driver onboarding application with full details.
  static Future<bool> registerNewDriver({
    required String name,
    required String phone,
    required String vehicleModel,
    required String chassisNumber,
    required String licenseNumber,
  }) async {
    final appId = 'APP_${DateTime.now().year}_${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    return await logToTab(_tabFleet, [
      appId,
      name,
      phone,
      vehicleModel,
      chassisNumber,
      licenseNumber,
      'PENDING', // Initial Onboarding Status
      '', // Bank Info Placeholder
      'assets/drivers/profile_$appId.jpg', // Logical path
    ]);
  }

  static Future<void> logTechWork(String jobId, String plate, String tech, {String? status, String? task, String? price, String? details}) async {
    await logToTab(_tabTech, [
      jobId,
      plate,
      tech,
      '0 km',
      task ?? 'Maintenance',
      price ?? '₹0',
      details ?? 'TBD',
      status ?? 'PENDING'
    ]);
  }

  static Future<void> logAdminAction(String adminId, String decision, String targetId, String remarks, {String? module}) async {
    await logToTab(_tabAdmin, [
      adminId,
      decision,
      targetId,
      remarks,
      module ?? 'GENERAL'
    ]);
  }
}
