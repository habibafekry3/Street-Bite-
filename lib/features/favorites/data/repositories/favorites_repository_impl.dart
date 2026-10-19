import '../../domain/repositories/favorites_repository.dart';
import '../../../home/domain/entities/meal_entity.dart';
import '../datasources/favorites_remote_datasource.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoritesRemoteDataSource _dataSource;

  FavoritesRepositoryImpl(this._dataSource);

  @override
  Stream<List<MealEntity>> watchFavorites() {
    return _dataSource.watchFavorites();
  }

  @override
  Future<void> addFavorite(MealEntity meal) {
    return _dataSource.addFavorite(meal);
  }

  @override
  Future<void> removeFavorite(String mealId) {
    return _dataSource.removeFavorite(mealId);
  }
}
