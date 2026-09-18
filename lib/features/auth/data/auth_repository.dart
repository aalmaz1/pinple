import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:pinple/core/constants/campus_constants.dart';
import 'package:pinple/core/utils/validators.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Stream<User?> get authStateChanges => _auth.userChanges();

  Future<void> signUp({
    required String email,
    required String password,
    required String nickname,
  }) async {
    if (!isValidKongjuEmail(email)) {
      throw Exception('학번@${CampusConstants.emailDomain} 형식만 사용 가능합니다');
    }

    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user!;

    try {
      await _firestore.collection('users').doc(user.uid).set({
        'email': email,
        'displayName': nickname,
        'createdAt': FieldValue.serverTimestamp(),
      });
      await updateFcmToken(user.uid);
    } catch (e) {
      await user.delete();
      rethrow;
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (credential.user != null) {
      await updateFcmToken(credential.user!.uid);
    }
  }

  Future<void> updateFcmToken(String uid) async {
    try {
      final token = await _fcm.getToken();
      if (token != null) {
        await _firestore.collection('users').doc(uid).update({
          'fcmToken': token,
          'lastActive': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      // Silent error for FCM
    }
  }

  Future<void> signOut() async {
    // Optionally remove FCM token on sign out
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'fcmToken': FieldValue.delete(),
      });
    }
    await _auth.signOut();
  }

  Future<Map<String, dynamic>?> getUserData(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data();
  }

  Future<String> uploadProfileImage(String uid, File imageFile) async {
    final ref = _storage.ref().child('profile_images').child('$uid.jpg');

    // Add metadata for better handling
    final metadata = SettableMetadata(contentType: 'image/jpeg');

    await ref.putFile(imageFile, metadata);
    final url = await ref.getDownloadURL();

    await _firestore.collection('users').doc(uid).update({'photoUrl': url});

    return url;
  }
}
