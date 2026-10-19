import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../features/home/data/models/meals_response.dart';
import 'api_endpoints.dart';

part 'api_services.g.dart';

@RestApi()
abstract class ApiServices {
  factory ApiServices(Dio dio, {String baseUrl}) = _ApiServices;

  @GET(ApiEndpoints.searchMealsByLetter)
  Future<MealsResponse> getMealsByLetter(@Query('f') String letter);
}
