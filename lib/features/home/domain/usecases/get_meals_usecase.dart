import '../entities/meal_entity.dart';
import '../repositories/meal_repository.dart';

class GetMealsUseCase {
  final MealRepository _repository;
  const GetMealsUseCase(this._repository);

  Future<List<MealEntity>> call() => _repository.getMeals();
}
