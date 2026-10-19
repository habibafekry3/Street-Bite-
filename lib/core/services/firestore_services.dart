import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  FirestoreService._internal();

  static final FirestoreService instance = FirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get users =>
      _firestore.collection('users');

  DocumentReference<Map<String, dynamic>> userDocument(String userId) {
    return users.doc(userId);
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUser(String userId) {
    return userDocument(userId).get();
  }

  Future<void> updateUser(String userId, Map<String, dynamic> data) {
    return userDocument(userId).update(data);
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchUser(String userId) {
    return userDocument(userId).snapshots();
  }
}
