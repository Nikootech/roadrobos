import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final quickActionRepositoryProvider = Provider((ref) => QuickActionRepository());

class QuickAction {
  final String id;
  final String label;
  final String icon;
  final String color;
  final String route;

  QuickAction({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
    required this.route,
  });

  factory QuickAction.fromMap(Map<String, dynamic> map, String id) {
    return QuickAction(
      id: id,
      label: map['label'] ?? '',
      icon: map['icon'] ?? '',
      color: map['color'] ?? '#000000',
      route: map['route'] ?? '',
    );
  }
}

class QuickActionRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<QuickAction>> getQuickActions() async {
    try {
      final response = await _supabase
          .from('quick_actions')
          .select()
          .eq('is_active', true)
          .order('display_order');
      
      return response.map((map) => QuickAction.fromMap(map, map['id'].toString())).toList();
    } catch (e) {
      throw Exception('Failed to fetch quick actions: $e');
    }
  }
}
