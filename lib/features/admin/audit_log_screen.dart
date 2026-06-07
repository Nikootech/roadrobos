import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/extensions/datetime_extensions.dart';


/// Audit Log Screen — paginated list from audit_logs table.
///
/// Columns: timestamp, actor_name, action, entity_type, entity_id
/// Filters: date range picker, action type dropdown
/// Pagination: 20 per page with next/previous controls
class AuditLogScreen extends ConsumerStatefulWidget {
  const AuditLogScreen({super.key});

  @override
  ConsumerState<AuditLogScreen> createState() => _AuditLogScreenState();
}

class _AuditLogScreenState extends ConsumerState<AuditLogScreen> {
  static const int _pageSize = 20;
  int _currentPage = 0;
  bool _isLoading = false;
  List<Map<String, dynamic>> _logs = [];
  int _totalCount = 0;

  // Filters
  String? _selectedActionType;
  DateTimeRange? _selectedDateRange;

  final List<String> _actionTypes = [
    'All',
    'login',
    'logout',
    'create',
    'update',
    'delete',
    'approve',
    'reject',
    'payment',
    'booking',
  ];

  @override
  void initState() {
    super.initState();
    _fetchLogs();
  }

  Future<void> _fetchLogs() async {
    setState(() => _isLoading = true);

    try {
      final supabase = Supabase.instance.client;
      final offset = _currentPage * _pageSize;

      // Build query
      var query = supabase
          .from('audit_logs')
          .select();

      // Apply action type filter
      if (_selectedActionType != null && _selectedActionType != 'All') {
        query = query.eq('action', _selectedActionType!);
      }

      // Apply date range filter
      if (_selectedDateRange != null) {
        query = query
            .gte('created_at', _selectedDateRange!.start.utcIso)
            .lte('created_at', _selectedDateRange!.end
                .add(const Duration(days: 1))
                .utcIso);
      }

      // Apply sorting and pagination
      final data = await query
          .order('created_at', ascending: false)
          .range(offset, offset + _pageSize - 1);

      // Get total count for pagination
      var countQuery = supabase
          .from('audit_logs')
          .select('id');

      if (_selectedActionType != null && _selectedActionType != 'All') {
        countQuery = countQuery.eq('action', _selectedActionType!);
      }

      if (_selectedDateRange != null) {
        countQuery = countQuery
            .gte('created_at', _selectedDateRange!.start.utcIso)
            .lte('created_at', _selectedDateRange!.end
                .add(const Duration(days: 1))
                .utcIso);
      }

      final countResult = await countQuery.count(CountOption.exact);

      if (mounted) {
        setState(() {
          _logs = List<Map<String, dynamic>>.from(data);
          _totalCount = countResult.count;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load audit logs: $e')),
        );
      }
    }
  }

  void _nextPage() {
    final maxPage = (_totalCount / _pageSize).ceil() - 1;
    if (_currentPage < maxPage) {
      setState(() => _currentPage++);
      _fetchLogs();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      setState(() => _currentPage--);
      _fetchLogs();
    }
  }

  void _resetFilters() {
    setState(() {
      _selectedActionType = null;
      _selectedDateRange = null;
      _currentPage = 0;
    });
    _fetchLogs();
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryBlue,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
        _currentPage = 0;
      });
      // ignore: unawaited_futures
      _fetchLogs();
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxPage = _totalCount > 0 ? (_totalCount / _pageSize).ceil() - 1 : 0;
    final startRecord = _currentPage * _pageSize + 1;
    final endRecord = (startRecord + _logs.length - 1).clamp(0, _totalCount);

    return Scaffold(
      backgroundColor: AppColors.bgLightGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.deepNavy.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.history_rounded,
                  color: AppColors.deepNavy, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              'Audit Logs',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        actions: [
          if (_selectedActionType != null || _selectedDateRange != null)
            IconButton(
              icon: const Icon(Icons.filter_alt_off_rounded,
                  color: AppColors.dangerRed),
              onPressed: _resetFilters,
              tooltip: 'Clear Filters',
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter Bar
          _buildFilterBar(),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primaryBlue))
                : _logs.isEmpty
                    ? _buildEmptyState()
                    : _buildLogList(),
          ),

          // Pagination Controls
          if (_totalCount > 0) _buildPaginationBar(maxPage, startRecord, endRecord),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Row(
        children: [
          // Action Type Dropdown
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.bgLightGrey,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedActionType ?? 'All',
                  hint: Text(
                    'Action Type',
                    style: GoogleFonts.inter(
                        fontSize: 13, color: AppColors.textSecondary),
                  ),
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded,
                      size: 20, color: AppColors.textSecondary),
                  items: _actionTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(
                        type == 'All' ? 'All Actions' : type.toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: (_selectedActionType == type)
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedActionType = value == 'All' ? null : value;
                      _currentPage = 0;
                    });
                    _fetchLogs();
                  },
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Date Range Picker Button
          GestureDetector(
            onTap: _pickDateRange,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: _selectedDateRange != null
                    ? AppColors.primaryBlue.withValues(alpha: 0.1)
                    : AppColors.bgLightGrey,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _selectedDateRange != null
                      ? AppColors.primaryBlue
                      : AppColors.border,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.date_range_rounded,
                    size: 18,
                    color: _selectedDateRange != null
                        ? AppColors.primaryBlue
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _selectedDateRange != null
                        ? '${DateFormat('dd/MM').format(_selectedDateRange!.start)} - ${DateFormat('dd/MM').format(_selectedDateRange!.end)}'
                        : 'Date Range',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _selectedDateRange != null
                          ? AppColors.primaryBlue
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.1, end: 0);
  }

  Widget _buildLogList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _logs.length,
      itemBuilder: (context, index) {
        final log = _logs[index];
        return _buildLogCard(log, index);
      },
    );
  }

  Widget _buildLogCard(Map<String, dynamic> log, int index) {
    final timestamp = log['created_at'] != null
        ? DateTime.parse(log['created_at'])
        : DateTime.now();
    final actorName = log['actor_name'] ?? 'Unknown';
    final action = log['action'] ?? 'unknown';
    final entityType = log['entity_type'] ?? '-';
    final entityId = log['entity_id'] ?? '-';

    final actionColor = _getActionColor(action);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Timestamp + Action Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.access_time_rounded,
                      size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('dd MMM yyyy, HH:mm').format(timestamp),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: actionColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  action.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: actionColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Actor Name
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_outline_rounded,
                    size: 18, color: AppColors.primaryBlue),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  actorName,
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Entity Info
          Row(
            children: [
              Expanded(
                child: _buildInfoChip(
                    'Entity', entityType, Icons.category_rounded),
              ),
              const SizedBox(width: 12),
              Expanded(
                child:
                    _buildInfoChip('ID', entityId, Icons.tag_rounded),
              ),
            ],
          ),
        ],
      ),
    ).animate(delay: Duration(milliseconds: 50 * index))
        .fadeIn()
        .slideX(begin: 0.05, end: 0);
  }

  Widget _buildInfoChip(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.bgLightGrey,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationBar(int maxPage, int startRecord, int endRecord) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Showing $startRecord-$endRecord of $_totalCount',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          Row(
            children: [
              _buildPageButton(
                icon: Icons.chevron_left_rounded,
                onTap: _currentPage > 0 ? _previousPage : null,
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_currentPage + 1}',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _buildPageButton(
                icon: Icons.chevron_right_rounded,
                onTap: _currentPage < maxPage ? _nextPage : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPageButton(
      {required IconData icon, VoidCallback? onTap}) {
    final isEnabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isEnabled ? AppColors.bgLightGrey : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isEnabled ? AppColors.border : Colors.transparent,
          ),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isEnabled ? AppColors.textPrimary : AppColors.textMuted,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded,
              size: 80,
              color: AppColors.textMuted.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          Text(
            'No audit logs found',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedActionType != null || _selectedDateRange != null
                ? 'Try adjusting your filters'
                : 'Activity logs will appear here',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ).animate().fadeIn().scale(),
    );
  }

  Color _getActionColor(String action) {
    switch (action.toLowerCase()) {
      case 'create':
      case 'approve':
        return AppColors.successGreen;
      case 'delete':
      case 'reject':
        return AppColors.dangerRed;
      case 'update':
        return AppColors.primaryBlue;
      case 'login':
      case 'logout':
        return AppColors.deepNavy;
      case 'payment':
        return AppColors.accentOrange;
      case 'booking':
        return const Color(0xFF8B5CF6);
      default:
        return AppColors.textSecondary;
    }
  }
}
