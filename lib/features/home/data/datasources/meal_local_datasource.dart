import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/meal_model.dart';

/// Local cache for meals stored in SharedPreferences as JSON.
class MealLocalDataSource {
  final SharedPreferences _prefs;
  static const _cacheKey = 'cached_meals';

  const MealLocalDataSource(this._prefs);

  Future<List<MealModel>> getCachedMeals() async {
    final jsonStr = _prefs.getString(_cacheKey);
    if (jsonStr == null) return [];
    try {
      final list =
          json.decode(jsonStr) as List<dynamic>; // convert the JSON into a list
      return list
          .whereType<Map<String, dynamic>>() // filter
          .map(MealModel.fromJson)
          .toList(); //List<MealModel>
    } catch (_) {
      // Malformed or outdated JSON — treat as empty cache.
      return [];
    }
  }

  Future<void> cacheMeals(List<MealModel> meals) async {
    final jsonStr = json.encode(meals.map((m) => m.toJson()).toList());
    await _prefs.setString(_cacheKey, jsonStr);
  }
}

/*
                [
              {"id": "1", "name": "Pizza"},                   Map
              {"id": "2", "name": "Burger"},                  Map
              "Hello",                                        Strings
               123                                            Numbers
               ]
*/
