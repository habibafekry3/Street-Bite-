import '../repositories/favorites_repository.dart';
import '../../../home/domain/entities/meal_entity.dart';

class WatchFavoritesUseCase {
  final FavoritesRepository _repository;

  const WatchFavoritesUseCase(this._repository);

  Stream<List<MealEntity>> call() => _repository.watchFavorites();
}
