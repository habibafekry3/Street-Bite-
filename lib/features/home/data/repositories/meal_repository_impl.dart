import '../../domain/entities/meal_entity.dart';
import '../../domain/repositories/meal_repository.dart';
import '../datasources/meal_datasource_factory.dart';

/// Delegates source selection to [MealDataSourceFactory] and maps the
/// returned Data-layer models to Domain-layer entities.
///
/// Single responsibility: data → domain mapping.
/// Source selection is fully encapsulated in the factory.
class MealRepositoryImpl implements MealRepository {
  final MealDataSourceFactory _factory;

  const MealRepositoryImpl(this._factory);

  @override
  Future<List<MealEntity>> getMeals() async {
    final models = await _factory.getMeals();
    return models.map((m) => m.toEntity()).toList();
  }
}

/*
models = [
  MealModel(name: 'Pizza'),
  MealModel(name: 'Burger'),
];


//models.map((m) => m.toEntity())//
MealEntity(name: 'Pizza'),
MealEntity(name: 'Burger'),



//.toList()
return [
  MealEntity(name: 'Pizza'),
  MealEntity(name: 'Burger'),
];

 */
