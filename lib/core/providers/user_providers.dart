import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/profile/user_provider.dart';
import '../../core/repositories/user_repository.dart';
import '../services/auth_service.dart';

part 'user_providers.g.dart';

@Riverpod(keepAlive: true)
UserNotifier userProfile(UserProfileRef ref) {
  return UserNotifier(
    ref.watch(authServiceProvider),
    ref.watch(userRepositoryProvider),
    ref,
  );
}
