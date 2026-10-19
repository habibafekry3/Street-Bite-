import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:food_app/core/api/api_services.dart';
import 'package:food_app/features/cart/domain/entities/cart_item.dart';
import 'package:food_app/features/cart/domain/repositories/cart_repository.dart';
import 'package:food_app/features/cart/domain/usecaces/save_cart_usecase.dart';
import 'package:food_app/features/cart/domain/usecaces/watch_cart_usecase.dart';
import 'package:food_app/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:food_app/features/home/data/datasources/meal_datasource_factory.dart';
import 'package:food_app/features/home/data/datasources/meal_local_datasource.dart';
import 'package:food_app/features/home/data/datasources/meal_remote_datasource.dart';
import 'package:food_app/features/home/data/models/meal_model.dart';
import 'package:food_app/features/home/data/models/meals_response.dart';
import 'package:food_app/features/home/domain/entities/meal_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── Test fakes ─────────────────────────────────────────────────────────────
// These are only needed by MealDataSourceFactory tests.
// They satisfy constructor types while keeping tests dependency-free.

/// Minimal ApiServices implementation — satisfies MealRemoteDataSource's
/// constructor; its method is never called because getMeals() is overridden.
class _FakeApiServices implements ApiServices {
  @override
  Future<MealsResponse> getMealsByLetter(String letter) async =>
      const MealsResponse();
}

/// Fake remote that always returns a fixed list of models.
class _SucceedingRemote extends MealRemoteDataSource {
  final List<MealModel> _models;

  _SucceedingRemote(this._models) : super(_FakeApiServices());

  @override
  Future<List<MealModel>> getMeals() async => _models;
}

/// Fake remote that always throws, simulating a network failure.
class _FailingRemote extends MealRemoteDataSource {
  _FailingRemote() : super(_FakeApiServices());

  @override
  Future<List<MealModel>> getMeals() =>
      Future.error(Exception('network error'));
}

class FakeCartRepository implements CartRepository {
  @override
  Stream<List<CartItem>> watchCart() {
    return const Stream.empty();
  }

  @override
  Future<void> saveCart(List<CartItem> items) async {}
}

class FakeWatchCartUseCase extends WatchCartUseCase {
  final StreamController<List<CartItem>> controller =
      StreamController<List<CartItem>>.broadcast();

  FakeWatchCartUseCase() : super(FakeCartRepository() as CartRepository);

  @override
  Stream<List<CartItem>> call() {
    return controller.stream;
  }
}

class FakeSaveCartUseCase extends SaveCartUseCase {
  final List<List<CartItem>> savedCarts = [];

  FakeSaveCartUseCase() : super(FakeCartRepository());

  @override
  Future<void> call(List<CartItem> items) async {
    savedCarts.add(List<CartItem>.from(items));
  }
}
// ── Tests ──────────────────────────────────────────────────────────────────

void main() {
  // ── MealModel ──────────────────────────────────────────────────────────────

  group('MealModel.fromJson', () {
    const validJson = <String, dynamic>{
      'idMeal': '52772',
      'strMeal': 'Teriyaki Chicken Casserole',
      'strCategory': 'Chicken',
      'strArea': 'Japanese',
      'strMealThumb': 'https://example.com/thumb.jpg',
    };

    test('maps all fields from a complete JSON object', () {
      final model = MealModel.fromJson(validJson);
      expect(model.id, '52772');
      expect(model.name, 'Teriyaki Chicken Casserole');
      expect(model.category, 'Chicken');
      expect(model.area, 'Japanese');
      expect(model.thumbnailUrl, 'https://example.com/thumb.jpg');
    });

    test('falls back to empty strings when fields are null', () {
      final model = MealModel.fromJson({'idMeal': null, 'strMeal': null});
      expect(model.id, '');
      expect(model.name, '');
      expect(model.category, '');
      expect(model.area, '');
      expect(model.thumbnailUrl, '');
    });

    test('falls back to empty strings when JSON is empty', () {
      final model = MealModel.fromJson({});
      expect(model.id, '');
      expect(model.name, '');
    });
  });

  group('MealModel.toEntity', () {
    test('produces a MealEntity with identical field values', () {
      const json = <String, dynamic>{
        'idMeal': '1',
        'strMeal': 'Pizza',
        'strCategory': 'Italian',
        'strArea': 'Italy',
        'strMealThumb': 'https://example.com/pizza.jpg',
      };
      final model = MealModel.fromJson(json);
      final entity = model.toEntity();
      expect(entity.id, model.id);
      expect(entity.name, model.name);
      expect(entity.category, model.category);
      expect(entity.area, model.area);
      expect(entity.thumbnailUrl, model.thumbnailUrl);
    });
  });

  group('MealModel toJson / fromJson round-trip', () {
    test('restores all fields after serialising and deserialising', () {
      const json = <String, dynamic>{
        'idMeal': '99',
        'strMeal': 'Shawarma',
        'strCategory': 'Lamb',
        'strArea': 'Lebanese',
        'strMealThumb': 'https://example.com/shawarma.jpg',
      };
      final original = MealModel.fromJson(json);
      final restored = MealModel.fromJson(original.toJson());
      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.category, original.category);
      expect(restored.area, original.area);
      expect(restored.thumbnailUrl, original.thumbnailUrl);
    });
  });

  // ── MealsResponse ──────────────────────────────────────────────────────────

  group('MealsResponse.fromJson', () {
    test('parses a list of two valid meals', () {
      final json = {
        'meals': [
          {
            'idMeal': '1',
            'strMeal': 'A',
            'strCategory': 'C',
            'strArea': 'X',
            'strMealThumb': 'https://example.com/a.jpg',
          },
          {
            'idMeal': '2',
            'strMeal': 'B',
            'strCategory': 'C',
            'strArea': 'X',
            'strMealThumb': 'https://example.com/b.jpg',
          },
        ],
      };
      final response = MealsResponse.fromJson(json);
      expect(response.meals, isNotNull);
      expect(response.meals!.length, 2);
      expect(response.meals!.first.id, '1');
      expect(response.meals!.last.id, '2');
    });

    test('returns null meals when the meals field is null', () {
      final response = MealsResponse.fromJson({'meals': null});
      expect(response.meals, isNull);
    });

    test('returns null meals when the meals key is absent', () {
      final response = MealsResponse.fromJson({});
      expect(response.meals, isNull);
    });

    test('skips non-map entries in the meals list', () {
      final json = {
        'meals': ['not a map', 42, null],
      };
      final response = MealsResponse.fromJson(json);
      expect(response.meals, isNotNull);
      expect(response.meals, isEmpty);
    });
  });

  // ── MealLocalDataSource ────────────────────────────────────────────────────

  group('MealLocalDataSource', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    Future<MealLocalDataSource> buildDataSource() async {
      final prefs = await SharedPreferences.getInstance();
      return MealLocalDataSource(prefs);
    }

    const meal1 = MealModel(
      id: '1',
      name: 'Pasta',
      category: 'Italian',
      area: 'Italy',
      thumbnailUrl: 'https://example.com/pasta.jpg',
    );
    const meal2 = MealModel(
      id: '2',
      name: 'Sushi',
      category: 'Japanese',
      area: 'Japan',
      thumbnailUrl: 'https://example.com/sushi.jpg',
    );

    test(
      'getCachedMeals returns empty list when no data has been cached',
      () async {
        final ds = await buildDataSource();
        expect(await ds.getCachedMeals(), isEmpty);
      },
    );

    test('cacheMeals then getCachedMeals returns the same meals', () async {
      final ds = await buildDataSource();
      await ds.cacheMeals([meal1, meal2]);
      final result = await ds.getCachedMeals();
      expect(result.length, 2);
      expect(result[0].id, '1');
      expect(result[0].name, 'Pasta');
      expect(result[1].id, '2');
      expect(result[1].name, 'Sushi');
    });

    test(
      'getCachedMeals returns empty list when stored JSON is malformed',
      () async {
        SharedPreferences.setMockInitialValues({
          'cached_meals': '{not valid json}',
        });
        final ds = await buildDataSource();
        expect(await ds.getCachedMeals(), isEmpty);
      },
    );

    test('cacheMeals overwrites a previous cache entry', () async {
      final ds = await buildDataSource();
      await ds.cacheMeals([meal1, meal2]);
      await ds.cacheMeals([meal2]);
      final result = await ds.getCachedMeals();
      expect(result.length, 1);
      expect(result.first.id, '2');
    });
  });

  // ── MealDataSourceFactory ──────────────────────────────────────────────────

  group('MealDataSourceFactory', () {
    const meal = MealModel(
      id: '10',
      name: 'Falafel',
      category: 'Vegetarian',
      area: 'Middle Eastern',
      thumbnailUrl: 'https://example.com/falafel.jpg',
    );

    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    Future<MealLocalDataSource> buildLocal() async {
      final prefs = await SharedPreferences.getInstance();
      return MealLocalDataSource(prefs);
    }

    test('remote success: returns the remote models', () async {
      final local = await buildLocal();
      final factory = MealDataSourceFactory(
        remote: _SucceedingRemote([meal]),
        local: local,
      );

      final result = await factory.getMeals();

      expect(result.length, 1);
      expect(result.first.id, '10');
      expect(result.first.name, 'Falafel');
    });

    test('remote success: writes returned models to the local cache', () async {
      final local = await buildLocal();
      final factory = MealDataSourceFactory(
        remote: _SucceedingRemote([meal]),
        local: local,
      );

      await factory.getMeals();

      final cached = await local.getCachedMeals();
      expect(cached.length, 1);
      expect(cached.first.id, '10');
    });

    test('remote failure with cached data: returns cached models', () async {
      final local = await buildLocal();
      await local.cacheMeals([
        meal,
      ]); // seed the cache before the factory is used

      final factory = MealDataSourceFactory(
        remote: _FailingRemote(),
        local: local,
      );

      final result = await factory.getMeals();

      expect(result.length, 1);
      expect(result.first.id, '10');
    });

    test(
      'remote failure with empty cache: rethrows the original error',
      () async {
        final local = await buildLocal(); // cache is empty

        final factory = MealDataSourceFactory(
          remote: _FailingRemote(),
          local: local,
        );

        expect(factory.getMeals(), throwsException);
      },
    );
  });

  // ── CartCubit ──────────────────────────────────────────────────────────────
  group('CartCubit', () {
    late CartCubit cubit;
    late FakeWatchCartUseCase watchCart;
    late FakeSaveCartUseCase saveCart;

    const meal1 = MealEntity(
      id: '1',
      name: 'Pizza',
      category: 'Italian',
      area: 'Italy',
      thumbnailUrl: 'pizza.jpg',
    );

    const meal2 = MealEntity(
      id: '2',
      name: 'Burger',
      category: 'Fast Food',
      area: 'USA',
      thumbnailUrl: 'burger.jpg',
    );

    setUp(() {
      watchCart = FakeWatchCartUseCase();
      saveCart = FakeSaveCartUseCase();

      cubit = CartCubit(watchCart: watchCart, saveCart: saveCart);
    });

    tearDown(() async {
      await cubit.close();
      await watchCart.controller.close();
    });

    test('initial state has an empty cart', () {
      expect(cubit.state.items, isEmpty);
      expect(cubit.state.itemCount, 0);
    });

    test('addItem adds a meal to the cart', () {
      cubit.addItem(meal1);

      expect(cubit.state.items.length, 1);
      expect(cubit.state.items.first.meal.id, '1');
      expect(cubit.state.items.first.quantity, 1);
      expect(cubit.state.itemCount, 1);
    });

    test('addItem increments quantity for an existing meal', () {
      cubit.addItem(meal1);
      cubit.addItem(meal1);

      expect(cubit.state.items.length, 1);
      expect(cubit.state.items.first.quantity, 2);
      expect(cubit.state.itemCount, 2);
    });

    test('addItem adds different meals separately', () {
      cubit.addItem(meal1);
      cubit.addItem(meal2);

      expect(cubit.state.items.length, 2);
      expect(cubit.state.itemCount, 2);
    });

    test('removeItem decreases quantity when quantity is greater than one', () {
      cubit.addItem(meal1);
      cubit.addItem(meal1);

      cubit.removeItem('1');

      expect(cubit.state.items.length, 1);
      expect(cubit.state.items.first.quantity, 1);
      expect(cubit.state.itemCount, 1);
    });

    test('removeItem removes a meal when quantity is one', () {
      cubit.addItem(meal1);

      cubit.removeItem('1');

      expect(cubit.state.items, isEmpty);
      expect(cubit.state.itemCount, 0);
    });

    test('removeItem does not affect other meals', () {
      cubit.addItem(meal1);
      cubit.addItem(meal2);

      cubit.removeItem('1');

      expect(cubit.state.items.length, 1);
      expect(cubit.state.items.first.meal.id, '2');
      expect(cubit.state.itemCount, 1);
    });

    test('save use case receives cart changes', () async {
      cubit.addItem(meal1);

      // Allow the asynchronous save operation to finish.
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(saveCart.savedCarts, isNotEmpty);
      expect(saveCart.savedCarts.last.first.meal.id, '1');
    });

    test('watchCart emits items received from the stream', () async {
      cubit.watchCart();

      watchCart.controller.add([const CartItem(meal: meal1, quantity: 2)]);

      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.items.length, 1);
      expect(cubit.state.items.first.meal.id, '1');
      expect(cubit.state.items.first.quantity, 2);
    });
  });
}
