import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/services/firestore_services.dart';
import '../../domain/entities/user_entity.dart';
import '../models/user_model.dart';
import '../models/user_model_builder.dart';

class FirebaseAuthDataSource {
  final FirebaseAuth _auth;
  final FirestoreService _firestoreService;

  const FirebaseAuthDataSource(this._auth, this._firestoreService);

  Future<UserEntity> login({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user!;

    final doc = await _firestoreService.getUser(user.uid);

    if (doc.exists && doc.data() != null) {
      return UserModel.fromJson(doc.data()!);
    }

    return UserModelBuilder()
        .setId(user.uid)
        .setEmail(user.email!)
        .setDisplayName(user.displayName)
        .build();
  }

  Future<UserEntity> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user!;

    await user.updateDisplayName(name);

    final userModel = UserModelBuilder()
        .setId(user.uid)
        .setEmail(user.email!)
        .setDisplayName(name)
        .build();

    await _firestoreService.userDocument(user.uid).set({
      ...userModel.toJson(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    return userModel;
  }

  Future<void> logout() => _auth.signOut();
}
