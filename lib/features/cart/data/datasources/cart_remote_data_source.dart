import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:food_app/core/services/firestore_services.dart';

import '../../domain/entities/cart_item.dart';
import '../../../home/domain/entities/meal_entity.dart';

class CartRemoteDataSource {
  final FirestoreService _firestoreService;
  final FirebaseAuth _auth;

  CartRemoteDataSource(this._firestoreService, this._auth);

  CollectionReference<Map<String, dynamic>> _cartCollection() {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError('User must be logged in');
    }

    return _firestoreService.userDocument(user.uid).collection('cart');
  }

  Stream<List<CartItem>> watchCart() {
    return _auth.authStateChanges().asyncExpand((user) {
      // No signed-in user: return an empty cart.
      if (user == null) {
        return Stream.value(<CartItem>[]);
      }

      final collection = _firestoreService
          .userDocument(user.uid)
          .collection('cart');

      return collection.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();

          final meal = MealEntity(
            id: (data['id'] as String?) ?? doc.id,
            name: (data['name'] as String?) ?? '',
            category: (data['category'] as String?) ?? '',
            area: (data['area'] as String?) ?? '',
            thumbnailUrl: (data['thumbnailUrl'] as String?) ?? '',
          );

          return CartItem(
            meal: meal,
            quantity: ((data['quantity'] as num?) ?? 1).toInt(),
          );
        }).toList();
      });
    });
  }

  Future<void> saveCart(List<CartItem> items) async {
    final collection = _cartCollection();
    final existing = await collection.get();
    final batch = FirebaseFirestore.instance.batch();

    // Remove the previous cart contents.
    for (final doc in existing.docs) {
      batch.delete(doc.reference);
    }

    // Save the updated cart.
    for (final item in items) {
      batch.set(collection.doc(item.meal.id), {
        'id': item.meal.id,
        'name': item.meal.name,
        'category': item.meal.category,
        'area': item.meal.area,
        'thumbnailUrl': item.meal.thumbnailUrl,
        'quantity': item.quantity,
      });
    }

    await batch.commit();
  }
}
