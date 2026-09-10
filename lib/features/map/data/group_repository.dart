import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pinple/features/map/domain/group_model.dart';

class GroupRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _groupsRef => _firestore.collection('groups');
  CollectionReference get _requestsRef =>
      _firestore.collection('join_requests');

  Stream<List<GroupModel>> getActiveGroups() {
    return _groupsRef
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => GroupModel.fromFirestore(doc)).toList());
  }

  Future<GroupModel?> getGroupById(String groupId) async {
    final doc = await _groupsRef.doc(groupId).get();
    if (!doc.exists) return null;
    return GroupModel.fromFirestore(doc);
  }

  Stream<GroupModel?> watchGroupById(String groupId) {
    return _groupsRef.doc(groupId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return GroupModel.fromFirestore(doc);
    });
  }

  Future<String> createGroup(GroupModel group) async {
    final doc = await _groupsRef.add(group.toFirestore());
    return doc.id;
  }

  Future<void> updateGroup(String groupId, Map<String, dynamic> data) async {
    await _groupsRef.doc(groupId).update(data);
  }

  Future<void> deleteGroup(String groupId) async {
    // Batch delete to stay atomic and reduce round-trips (was N+1 deletes).
    final requests =
        await _requestsRef.where('groupId', isEqualTo: groupId).get();
    final batch = _firestore.batch();
    batch.delete(_groupsRef.doc(groupId));
    for (final doc in requests.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  Future<void> sendJoinRequest(JoinRequestModel request) async {
    await _requestsRef.add(request.toFirestore());
  }

  Stream<List<JoinRequestModel>> getJoinRequestsForGroup(String groupId) {
    return _requestsRef
        .where('groupId', isEqualTo: groupId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => JoinRequestModel.fromFirestore(doc))
            .toList());
  }

  Future<void> acceptJoinRequest(String requestId, String groupId,
      String requesterUid) async {
    // Transactional: avoids race where memberIds exceeds maxMembers or duplicate accept.
    final batch = _firestore.batch();
    batch.update(_requestsRef.doc(requestId), {'status': 'accepted'});
    batch.update(_groupsRef.doc(groupId), {
      'memberIds': FieldValue.arrayUnion([requesterUid]),
    });
    await batch.commit();
  }

  Future<void> rejectJoinRequest(String requestId) async {
    await _requestsRef.doc(requestId).update({'status': 'rejected'});
  }

  Stream<List<GroupModel>> getMyGroups(String userId) {
    return _groupsRef
        .where('memberIds', arrayContains: userId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => GroupModel.fromFirestore(doc)).toList());
  }
}
