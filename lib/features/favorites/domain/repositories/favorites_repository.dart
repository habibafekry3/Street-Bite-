import '../../../home/domain/entities/meal_entity.dart';

abstract class FavoritesRepository {
  Stream<List<MealEntity>> watchFavorites();

  Future<void> addFavorite(MealEntity meal);

  Future<void> removeFavorite(String mealId);
}
