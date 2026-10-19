import '../../domain/entities/meal_entity.dart';

abstract class MealsState {}

class MealsInitial extends MealsState {}

class MealsLoading extends MealsState {}

class MealsLoaded extends MealsState {
  final List<MealEntity> meals;
  MealsLoaded(this.meals);
}

class MealsEmpty extends MealsState {}

class MealsError extends MealsState {
  final String messageKey;
  MealsError(this.messageKey);
}
