import '../entities/meal_entity.dart';

abstract class MealRepository {
  /// Fetches meals using the appropriate data source (remote or cached).
  Future<List<MealEntity>> getMeals();
}
