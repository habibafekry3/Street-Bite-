import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/services/firestore_services.dart';

class ProfileRemoteDataSource {
  final FirestoreService _firestoreService;
  final FirebaseAuth _firebaseAuth;

  ProfileRemoteDataSource({
    required FirestoreService firestoreService,
    required FirebaseAuth firebaseAuth,
  }) : _firestoreService = firestoreService,
       _firebaseAuth = firebaseAuth;

  Future<Map<String, dynamic>?> getProfile() async {
    final user = _firebaseAuth.currentUser;

    if (user == null) {
      throw Exception('userNotLoggedIn');
    }

    final document = await _firestoreService.getUser(user.uid);
    final data = document.data();

    return {
      'uid': user.uid,
      'email': user.email,
      'displayName': data?['displayName'] as String? ?? user.displayName,
      'profileImageBase64': data?['profileImageBase64'] as String?,
    };
  }

  Future<void> updateProfileName(String name) async {
    final user = _firebaseAuth.currentUser;

    if (user == null) {
      throw Exception('userNotLoggedIn');
    }

    await user.updateDisplayName(name);

    await _firestoreService.updateUser(user.uid, {'displayName': name});
  }

  Future<void> updateProfileImage(String imageBase64) async {
    final user = _firebaseAuth.currentUser;

    if (user == null) {
      throw Exception('userNotLoggedIn');
    }

    await _firestoreService.updateUser(user.uid, {
      'profileImageBase64': imageBase64,
    });
  }
}
