import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../home/domain/entities/meal_entity.dart';
import '../../domain/usecases/toggle_favorite_usecase.dart';
import '../../domain/usecases/watch_favorites_usecase.dart';
import 'favorites_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  final WatchFavoritesUseCase _watchFavorites;
  final ToggleFavoriteUseCase _toggleFavorite;

  StreamSubscription<List<MealEntity>>? _subscription;

  FavoritesCubit({
    required WatchFavoritesUseCase watchFavorites,
    required ToggleFavoriteUseCase toggleFavorite,
  }) : _watchFavorites = watchFavorites,
       _toggleFavorite = toggleFavorite,
       super(const FavoritesInitial());

  void watchFavorites() {
    if (isClosed) return;

    // Avoid duplicate active subscriptions.
    if (_subscription != null) return;

    emit(const FavoritesLoading());

    _subscription = _watchFavorites().listen(
      (meals) {
        if (!isClosed) {
          emit(FavoritesLoaded(meals));
        }
      },
      onError: (Object error) {
        if (isClosed) return;

        // Allow retry after a stream error.
        _subscription = null;

        emit(FavoritesError(error.toString()));
      },
    );
  }

  Future<void> addFavorite(MealEntity meal) async {
    try {
      await _toggleFavorite.add(meal);
    } catch (error) {
      if (!isClosed) {
        emit(FavoritesError(error.toString()));
      }
    }
  }

  Future<void> removeFavorite(String mealId) async {
    try {
      await _toggleFavorite.remove(mealId);
    } catch (error) {
      if (!isClosed) {
        emit(FavoritesError(error.toString()));
      }
    }
  }

  bool isFavorite(String mealId) {
    final currentState = state;

    if (currentState is! FavoritesLoaded) return false;

    return currentState.meals.any((meal) => meal.id == mealId);
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
