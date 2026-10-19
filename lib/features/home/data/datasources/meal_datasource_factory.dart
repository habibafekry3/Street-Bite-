import '../models/meal_model.dart';
import 'meal_local_datasource.dart';
import 'meal_remote_datasource.dart';

/// Factory Pattern — selects the appropriate meal data source at runtime.
///
/// Decision logic (network-first, cache-fallback):
/// 1. Ask the remote source for fresh meals.
/// 2. On success  → persist to the local cache and return the fresh models.
/// 3. On failure  → return whatever the local cache holds.
/// 4. If the cache is also empty → rethrow so callers can surface an error.
///
/// Returns [List<MealModel>] so that the repository layer stays responsible
/// for the data→domain mapping, keeping [MealRepository] free of Data-layer
/// types.
class MealDataSourceFactory {
  // two data sources
  final MealRemoteDataSource _remote;
  final MealLocalDataSource _local;

  const MealDataSourceFactory({
    required MealRemoteDataSource remote,
    required MealLocalDataSource local,
  }) : _remote = remote,
       _local = local;

  Future<List<MealModel>> getMeals() async {
    try {
      final models = await _remote.getMeals();
      await _local.cacheMeals(models);
      return models;
    } catch (_) {
      final cached = await _local.getCachedMeals();
      if (cached.isNotEmpty) return cached;
      rethrow;
    }
  }
}
