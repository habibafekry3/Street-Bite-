import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/services/firestore_services.dart';
import '../../../home/data/models/meal_model.dart';
import '../../../home/domain/entities/meal_entity.dart';

class FavoritesRemoteDataSource {
  final FirestoreService _firestoreService;
  final FirebaseAuth _auth;

  FavoritesRemoteDataSource(this._firestoreService, this._auth);

  CollectionReference<Map<String, dynamic>> _favoritesCollection() {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError('User must be logged in');
    }

    return _firestoreService.userDocument(user.uid).collection('favorites');
  }

  Stream<List<MealEntity>> watchFavorites() {
    return _auth.authStateChanges().asyncExpand((user) {
      // No signed-in user: show an empty favorites list.
      if (user == null) {
        return Stream.value(<MealEntity>[]);
      }

      final collection = _firestoreService
          .userDocument(user.uid)
          .collection('favorites');

      return collection.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();

          return MealModel(
            id: (data['id'] as String?) ?? doc.id,
            name: (data['name'] as String?) ?? '',
            category: (data['category'] as String?) ?? '',
            area: (data['area'] as String?) ?? '',
            thumbnailUrl: (data['thumbnailUrl'] as String?) ?? '',
          ).toEntity();
        }).toList();
      });
    });
  }

  Future<void> addFavorite(MealEntity meal) async {
    await _favoritesCollection().doc(meal.id).set({
      'id': meal.id,
      'name': meal.name,
      'category': meal.category,
      'area': meal.area,
      'thumbnailUrl': meal.thumbnailUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeFavorite(String mealId) async {
    await _favoritesCollection().doc(mealId).delete();
  }
}
