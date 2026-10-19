import '../../../home/domain/entities/meal_entity.dart';

/// Represents a meal in the cart with its accumulated quantity.
class CartItem {
  final MealEntity meal;
  final int quantity;

  const CartItem({required this.meal, required this.quantity});

  CartItem copyWith({int? quantity}) =>
      CartItem(meal: meal, quantity: quantity ?? this.quantity);
}
