import '../../../../core/api/api_services.dart';
import '../models/meal_model.dart';

/// Remote data source for meals using TheMealDB free API.
/// Fetches meals by first letter to get a practical variety of results.
class MealRemoteDataSource {
  final ApiServices _apiServices;

  // Three letters gives ~90 unique meals — enough for a useful Home screen
  // without making an unreasonable number of requests.
  static const _letters = ['a', 'b', 'c'];

  const MealRemoteDataSource(this._apiServices);

  Future<List<MealModel>> getMeals() async {
    final futures = _letters.map((l) async {
      try {
        return await _fetchByLetter(l);
      } catch (_) {
        // A single letter failure is non-fatal; others may succeed.
        return <MealModel>[];
      }
    });

    final results = await Future.wait(futures);
    final seen = <String>{};
    final meals = <MealModel>[];
    for (final batch in results) {
      for (final meal in batch) {
        if (meal.id.isNotEmpty && seen.add(meal.id)) {
          meals.add(meal);
        }
      }
    }
    if (meals.isEmpty) {
      throw Exception('No meals returned from API');
    }
    return meals;
  }

  // Fetch meals by specific letter.
  Future<List<MealModel>> _fetchByLetter(String letter) async {
    final response = await _apiServices.getMealsByLetter(letter);
    return (response.meals ?? [])
        .where((m) => m.id.isNotEmpty && m.thumbnailUrl.isNotEmpty)
        .toList();
  }
}
