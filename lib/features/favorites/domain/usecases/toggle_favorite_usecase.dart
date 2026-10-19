import '../repositories/favorites_repository.dart';
import '../../../home/domain/entities/meal_entity.dart';

class ToggleFavoriteUseCase {
  final FavoritesRepository _repository;

  const ToggleFavoriteUseCase(this._repository);

  Future<void> add(MealEntity meal) {
    return _repository.addFavorite(meal);
  }

  Future<void> remove(String mealId) {
    return _repository.removeFavorite(mealId);
  }
}
