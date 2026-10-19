import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_meals_usecase.dart';
import 'meals_state.dart';

class MealsCubit extends Cubit<MealsState> {
  final GetMealsUseCase _getMealsUseCase;

  MealsCubit(this._getMealsUseCase) : super(MealsInitial());

  /// Called on screen entry — skips the network if data is already loaded.
  Future<void> loadMeals() async {
    if (state is MealsLoaded) return;
    await _fetchMeals();
  }

  /// Called on pull-to-refresh — always hits the network.
  Future<void> refreshMeals() => _fetchMeals();

  Future<void> _fetchMeals() async {
    emit(MealsLoading());
    try {
      final meals = await _getMealsUseCase();
      if (meals.isEmpty) {
        emit(MealsEmpty());
      } else {
        emit(MealsLoaded(meals));
      }
    } catch (_) {
      emit(MealsError('mealsError'));
    }
  }
}
