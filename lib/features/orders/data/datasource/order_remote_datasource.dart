import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../cart/domain/entities/cart_item.dart';
import '../../../home/domain/entities/meal_entity.dart';

import '../../domain/entities/order_entity.dart';

class OrderRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  OrderRemoteDataSource({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  }) : _firestore = firestore,
       _auth = auth;

  Future<String> createOrder(OrderEntity order) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError('User must be logged in to create an order.');
    }

    if (order.userId != user.uid) {
      throw StateError('Cannot create an order for another user.');
    }

    final ordersCollection = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('orders');

    final orderDocument = ordersCollection.doc();

    await orderDocument.set({
      'userId': user.uid,
      'items': order.items.map((item) {
        return {
          'mealId': item.meal.id,
          'name': item.meal.name,
          'category': item.meal.category,
          'area': item.meal.area,
          'thumbnailUrl': item.meal.thumbnailUrl,
          'quantity': item.quantity,
        };
      }).toList(),
      'totalItems': order.totalItems,
      'createdAt': FieldValue.serverTimestamp(),
      'status': order.status,
      'paymentMethod': order.paymentMethod,
    });

    return orderDocument.id;
  }

  Stream<List<OrderEntity>> watchOrders(String userId) {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError('User must be logged in to view orders.');
    }

    if (user.uid != userId) {
      throw StateError('Cannot view another user\'s orders.');
    }

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('orders')
        .snapshots()
        .map((snapshot) {
          final orders = snapshot.docs.map((document) {
            final data = document.data();

            final rawItems = data['items'] as List<dynamic>? ?? [];

            final items = rawItems.map((rawItem) {
              final item = Map<String, dynamic>.from(rawItem as Map);

              final meal = MealEntity(
                id: item['mealId'] as String? ?? '',
                name: item['name'] as String? ?? '',
                category: item['category'] as String? ?? '',
                area: item['area'] as String? ?? '',
                thumbnailUrl: item['thumbnailUrl'] as String? ?? '',
              );

              return CartItem(
                meal: meal,
                quantity: (item['quantity'] as num?)?.toInt() ?? 1,
              );
            }).toList();

            final rawCreatedAt = data['createdAt'];
            final createdAt = rawCreatedAt is Timestamp
                ? rawCreatedAt.toDate()
                : DateTime.fromMillisecondsSinceEpoch(0);

            return OrderEntity(
              id: document.id,
              userId: data['userId'] as String? ?? userId,
              items: items,
              createdAt: createdAt,
              status: data['status'] as String? ?? 'pending',
              paymentMethod: data['paymentMethod'] as String? ?? 'cash',
            );
          }).toList();

          orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          return orders;
        });
  }
}
