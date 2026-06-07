import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/models/approval.dart';
import '../../../core/repositories/approval_repository.dart';

class ApprovalNotifier extends AsyncNotifier<List<ApprovalRequest>> {

  @override
  Future<List<ApprovalRequest>> build() async {
    final supabase = Supabase.instance.client;

    // Subscribe to realtime updates on the 'approvals' table
    final subscription = supabase
        .from('approvals')
        .stream(primaryKey: ['id'])
        .order('created_at')
        .listen((data) {
          state = AsyncValue.data(
            data.map((map) => ApprovalRequest.fromMap(map)).toList(),
          );
        }, onError: (err, stack) {
          state = AsyncValue.error(err, stack);
        });

    ref.onDispose(() {
      unawaited(subscription.cancel());
    });

    // Fetch initial approvals list
    final response = await supabase
        .from('approvals')
        .select()
        .order('created_at', ascending: false);

    return (response as List).map((map) => ApprovalRequest.fromMap(map)).toList();
  }

  Future<void> approve(String id) async {
    final repository = ref.read(approvalRepositoryProvider);
    await repository.updateApprovalStatus(
      id: id,
      status: ApprovalStatus.approved,
    );
  }

  Future<void> reject(String id, String reason) async {
    final repository = ref.read(approvalRepositoryProvider);
    await repository.updateApprovalStatus(
      id: id,
      status: ApprovalStatus.rejected,
      reason: reason,
    );
  }
}

final approvalProvider = AsyncNotifierProvider<ApprovalNotifier, List<ApprovalRequest>>(() {
  return ApprovalNotifier();
});
