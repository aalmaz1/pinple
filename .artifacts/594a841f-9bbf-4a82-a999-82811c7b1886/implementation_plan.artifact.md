# Implementation Plan: Add "Leave Group" Functionality

This plan addresses the missing "Leave Group" (참여 포기) functionality. Currently, users can join a group but cannot leave it from the group detail screen.

## User Review Required

> [!NOTE]
> The "Leave Group" action will remove the user from the `memberIds` list in Firestore. The group owner cannot leave their own group (they must delete it instead, which is already implemented).

## Proposed Changes

### Data Layer

#### [MODIFY] [group_repository.dart](file:///home/almaz/AndroidStudioProjects/pinple/lib/features/map/data/group_repository.dart)
- Add `leaveGroup(String groupId, String userId)` method to remove a user from the group's `memberIds` list using `FieldValue.arrayRemove`.

### Presentation Layer

#### [MODIFY] [group_detail_screen.dart](file:///home/almaz/AndroidStudioProjects/pinple/lib/features/map/presentation/group_detail_screen.dart)
- Update `_buildActionButton` to show a "Leave Group" (참여 포기) button when the user is already a member (`isMember == true`).
- Implement `_confirmLeave` method to show a confirmation dialog before leaving.
- Use localized strings from `l10nProvider` for "Join", "Joined", and "Leave" related text to ensure consistency across languages.

## Verification Plan

### Manual Verification
1. Log in as a regular user (not the group owner).
2. Navigate to a group detail screen where the user is not a member.
3. Click "참여 신청" (Join Request).
4. (As Owner) Accept the request.
5. (As regular user) Observe the button change to "참여 중" (Joined) with a "참여 포기" (Leave Group) option.
6. Click "참여 포기", confirm in the dialog.
7. Verify the user is removed from the group and the button reverts to "참여 신청".
