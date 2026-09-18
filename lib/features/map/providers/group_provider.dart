import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinple/core/utils/distance.dart';
import 'package:pinple/features/location_gate/providers/location_provider.dart';
import 'package:pinple/features/map/data/group_repository.dart';
import 'package:pinple/features/map/domain/group_model.dart';

final groupRepositoryProvider = Provider<GroupRepository>((ref) {
  return GroupRepository();
});

final activeGroupsProvider = StreamProvider<List<GroupModel>>((ref) {
  return ref.watch(groupRepositoryProvider).getActiveGroups();
});

final groupDetailProvider = FutureProvider.family<GroupModel?, String>((
  ref,
  groupId,
) {
  return ref.watch(groupRepositoryProvider).getGroupById(groupId);
});

final joinRequestsProvider =
    StreamProvider.family<List<JoinRequestModel>, String>((ref, groupId) {
      return ref
          .watch(groupRepositoryProvider)
          .getJoinRequestsForGroup(groupId);
    });

final myGroupsProvider = StreamProvider.family<List<GroupModel>, String>((
  ref,
  userId,
) {
  return ref.watch(groupRepositoryProvider).getMyGroups(userId);
});

// Current active deep link group ID
class PendingLinkNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void set(String? id) => state = id;
  void clear() => state = null;
}

final pendingDeepLinkProvider = NotifierProvider<PendingLinkNotifier, String?>(
  PendingLinkNotifier.new,
);

// Optimized: Pre-sorted groups by distance to current user
final sortedGroupsProvider = Provider<AsyncValue<List<GroupModel>>>((ref) {
  final groupsAsync = ref.watch(activeGroupsProvider);
  final positionAsync = ref.watch(currentPositionProvider);

  return groupsAsync.whenData((groups) {
    final myLat = positionAsync.value?.latitude;
    final myLng = positionAsync.value?.longitude;

    if (myLat == null || myLng == null) return groups;

    final sorted = List<GroupModel>.from(groups);
    sorted.sort((a, b) {
      final dA = distanceMeters(
        fromLat: myLat,
        fromLng: myLng,
        toLat: a.latitude,
        toLng: a.longitude,
      );
      final dB = distanceMeters(
        fromLat: myLat,
        fromLng: myLng,
        toLat: b.latitude,
        toLng: b.longitude,
      );
      return dA.compareTo(dB);
    });
    return sorted;
  });
});
