import '../../../home/domain/entities/meal_entity.dart';

abstract class FavoritesState {
  const FavoritesState();
}

class FavoritesInitial extends FavoritesState {
  const FavoritesInitial();
}

class FavoritesLoading extends FavoritesState {
  const FavoritesLoading();
}

class FavoritesLoaded extends FavoritesState {
  final List<MealEntity> meals;

  const FavoritesLoaded(this.meals);
}

class FavoritesError extends FavoritesState {
  final String message;

  const FavoritesError(this.message);
}
