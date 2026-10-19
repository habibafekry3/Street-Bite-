abstract final class ApiEndpoints {
  // ── TheMealDB (free dev key = 1) ─────────────────────────────────────────
  static const String mealDbBaseUrl = 'https://www.themealdb.com/api/json/v1/1';
  static const String searchMealsByLetter = '/search.php'; // ?f=a
  static const String mealDetails = '/lookup.php'; // ?i={mealId}
}
