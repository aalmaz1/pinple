import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinple/features/map/data/group_repository.dart';
import 'package:pinple/features/map/domain/group_model.dart';

final groupRepositoryProvider = Provider<GroupRepository>((ref) {
  return GroupRepository();
});

final activeGroupsProvider = StreamProvider<List<GroupModel>>((ref) {
  return ref.watch(groupRepositoryProvider).getActiveGroups();
});

final groupDetailProvider =
    StreamProvider.family<GroupModel?, String>((ref, groupId) {
  return ref.watch(groupRepositoryProvider).watchGroupById(groupId);
});

// Keep Future variant for one-shot reads (e.g. edit init) without listening
final groupDetailFutureProvider =
    FutureProvider.family<GroupModel?, String>((ref, groupId) {
  return ref.watch(groupRepositoryProvider).getGroupById(groupId);
});

final joinRequestsProvider =
    StreamProvider.family<List<JoinRequestModel>, String>((ref, groupId) {
  return ref.watch(groupRepositoryProvider).getJoinRequestsForGroup(groupId);
});

final myGroupsProvider =
    StreamProvider.family<List<GroupModel>, String>((ref, userId) {
  return ref.watch(groupRepositoryProvider).getMyGroups(userId);
});
