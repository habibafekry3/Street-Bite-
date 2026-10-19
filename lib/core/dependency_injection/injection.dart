import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/cart/data/datasources/cart_remote_data_source.dart';
import '../../features/cart/domain/usecaces/save_cart_usecase.dart';
import '../../features/cart/domain/usecaces/watch_cart_usecase.dart';
import '../../features/cart/presentation/cubit/cart_cubit.dart';
import '../../features/orders/data/datasource/order_remote_datasource.dart';
import '../../features/orders/data/repositories/order_repository_impl.dart';
import '../../features/orders/domain/repositories/order_repository.dart';
import '../../features/orders/domain/usecases/create_order_usecase.dart';
import '../../features/orders/domain/usecases/watch_orders_usecase.dart';
import '../../features/orders/presentation/cubit/order_cubit.dart';
import '../../features/orders/presentation/cubit/orders_cubit.dart';
import '../../features/profile/data/datasources/profile_remote_data_source.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/get_profile_usecase.dart';
import '../../features/profile/domain/usecases/update_profile_image_usecase.dart';
import '../../features/profile/domain/usecases/update_profile_name_usecase.dart';
import '../../features/profile/presentation/cubit/profile_cubit.dart';
import '../../features/vendors/data/datasources/vendor_local_datasource.dart';
import '../../features/vendors/data/repositories/vendor_repository_impl.dart';
import '../../features/vendors/domain/repositories/vendor_repository.dart';
import '../../features/vendors/domain/usecases/get_vendors.dart';
import '../../features/vendors/presentation/cubits/vendors_state.dart';
import '../api/api_endpoints.dart';
import '../api/api_services.dart';
import '../api/dio_factory.dart';
import '../preferences/app_preferences.dart';
import '../../features/auth/data/datasources/firebase_auth_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/sign_up_usecase.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/home/data/datasources/meal_datasource_factory.dart';
import '../../features/home/data/datasources/meal_local_datasource.dart';
import '../../features/home/data/datasources/meal_remote_datasource.dart';
import '../../features/home/data/repositories/meal_repository_impl.dart';
import '../../features/home/domain/repositories/meal_repository.dart';
import '../../features/home/domain/usecases/get_meals_usecase.dart';
import '../../features/home/presentation/cubit/meals_cubit.dart';
import '../../features/splash/presentation/cubit/splash_cubit.dart';
import '../services/firestore_services.dart';
import '../../features/favorites/data/datasources/favorites_remote_datasource.dart';
import '../../features/favorites/data/repositories/favorites_repository_impl.dart';
import '../../features/favorites/domain/repositories/favorites_repository.dart';
import '../../features/favorites/domain/usecases/toggle_favorite_usecase.dart';
import '../../features/favorites/domain/usecases/watch_favorites_usecase.dart';
import '../../features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:food_app/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:food_app/features/cart/domain/repositories/cart_repository.dart';

import '../theming/cubit/theme_cubit.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // ── Core ──────────────────────────────────────────────────────────────────
  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);
  getIt.registerLazySingleton<AppPreferences>(() => AppPreferences(getIt()));

  // ── Settings cubits ───────────────────────────────────────────────────────
  getIt.registerFactory<ThemeCubit>(() => ThemeCubit(getIt()));

  // ── firestore ──────────────────────────────────────────────────────────────────
  getIt.registerSingleton<FirestoreService>(FirestoreService.instance);

  // ── Profile ──────────────────────────────────────────────────────────────

  getIt.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSource(
      firestoreService: getIt<FirestoreService>(),
      firebaseAuth: FirebaseAuth.instance,
    ),
  );

  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
      remoteDataSource: getIt<ProfileRemoteDataSource>(),
    ),
  );

  getIt.registerFactory<GetProfileUseCase>(
    () => GetProfileUseCase(getIt<ProfileRepository>()),
  );

  getIt.registerFactory<UpdateProfileNameUseCase>(
    () => UpdateProfileNameUseCase(getIt<ProfileRepository>()),
  );

  getIt.registerFactory<UpdateProfileImageUseCase>(
    () => UpdateProfileImageUseCase(getIt<ProfileRepository>()),
  );

  getIt.registerFactory<ProfileCubit>(
    () => ProfileCubit(
      getProfileUseCase: getIt<GetProfileUseCase>(),
      updateProfileNameUseCase: getIt<UpdateProfileNameUseCase>(),
      updateProfileImageUseCase: getIt<UpdateProfileImageUseCase>(),
    ),
  );

  // ── Auth ──────────────────────────────────────────────────────────────────
  getIt.registerLazySingleton<FirebaseAuthDataSource>(
    () => FirebaseAuthDataSource(
      FirebaseAuth.instance,
      getIt<FirestoreService>(),
    ),
  );
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt()),
  );
  getIt.registerFactory<LoginUseCase>(() => LoginUseCase(getIt()));
  getIt.registerFactory<SignUpUseCase>(() => SignUpUseCase(getIt()));
  getIt.registerFactory<LogoutUseCase>(() => LogoutUseCase(getIt()));
  getIt.registerFactory<AuthCubit>(
    () => AuthCubit(
      loginUseCase: getIt(),
      signUpUseCase: getIt(),
      logoutUseCase: getIt(),
    ),
  );

  // ── Splash ────────────────────────────────────────────────────────────────
  getIt.registerFactory<SplashCubit>(() => SplashCubit());

  // ── Meals ─────────────────────────────────────────────────────────────────
  // Dedicated ApiServices for TheMealDB (different base URL from StreetBite API).
  getIt.registerLazySingleton<MealRemoteDataSource>(
    () => MealRemoteDataSource(
      ApiServices(DioFactory.createDio(), baseUrl: ApiEndpoints.mealDbBaseUrl),
    ),
  );
  getIt.registerLazySingleton<MealLocalDataSource>(
    () => MealLocalDataSource(getIt()),
  );
  getIt.registerLazySingleton<MealDataSourceFactory>(
    () => MealDataSourceFactory(remote: getIt(), local: getIt()),
  );
  getIt.registerLazySingleton<MealRepository>(
    () => MealRepositoryImpl(getIt<MealDataSourceFactory>()),
  );
  getIt.registerFactory<GetMealsUseCase>(() => GetMealsUseCase(getIt()));
  getIt.registerLazySingleton<MealsCubit>(() => MealsCubit(getIt()));

  // ── Cart ──────────────────────────────────────────────────────────────────
  getIt.registerLazySingleton<CartRemoteDataSource>(
    () =>
        CartRemoteDataSource(getIt<FirestoreService>(), FirebaseAuth.instance),
  );

  getIt.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(getIt<CartRemoteDataSource>()),
  );

  getIt.registerFactory<WatchCartUseCase>(
    () => WatchCartUseCase(getIt<CartRepository>()),
  );

  getIt.registerFactory<SaveCartUseCase>(
    () => SaveCartUseCase(getIt<CartRepository>()),
  );

  getIt.registerLazySingleton<CartCubit>(
    () => CartCubit(
      watchCart: getIt<WatchCartUseCase>(),
      saveCart: getIt<SaveCartUseCase>(),
    )..watchCart(),
  );

  //  ── Favorites ─────────────────────────────────────────────────────────────────
  getIt.registerLazySingleton<FavoritesRemoteDataSource>(
    () => FavoritesRemoteDataSource(
      getIt<FirestoreService>(),
      FirebaseAuth.instance,
    ),
  );

  getIt.registerLazySingleton<FavoritesRepository>(
    () => FavoritesRepositoryImpl(getIt()),
  );

  getIt.registerFactory<WatchFavoritesUseCase>(
    () => WatchFavoritesUseCase(getIt()),
  );

  getIt.registerFactory<ToggleFavoriteUseCase>(
    () => ToggleFavoriteUseCase(getIt()),
  );

  getIt.registerLazySingleton<FavoritesCubit>(
    () =>
        FavoritesCubit(watchFavorites: getIt(), toggleFavorite: getIt())
          ..watchFavorites(),
  );

  // ── Orders ────────────────────────────────────────────────────────────────

  getIt.registerLazySingleton<OrderRemoteDataSource>(
    () => OrderRemoteDataSource(
      firestore: FirebaseFirestore.instance,
      auth: FirebaseAuth.instance,
    ),
  );

  getIt.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(getIt<OrderRemoteDataSource>()),
  );

  getIt.registerFactory<CreateOrderUseCase>(
    () => CreateOrderUseCase(getIt<OrderRepository>()),
  );

  getIt.registerFactory<WatchOrdersUseCase>(
    () => WatchOrdersUseCase(getIt<OrderRepository>()),
  );

  // Create a new order during checkout.
  getIt.registerFactory<OrderCubit>(
    () => OrderCubit(createOrder: getIt<CreateOrderUseCase>()),
  );

  // Load and listen to the user's previous orders.
  getIt.registerFactory<OrdersCubit>(
    () => OrdersCubit(watchOrders: getIt<WatchOrdersUseCase>()),
  );

  // ── Vendors ───────────────────────────────────────────────────────────────

  getIt.registerLazySingleton<VendorLocalDataSource>(
    () => const VendorLocalDataSource(),
  );

  getIt.registerLazySingleton<VendorRepository>(
    () => VendorRepositoryImpl(localDataSource: getIt<VendorLocalDataSource>()),
  );

  getIt.registerFactory<GetVendorsUseCase>(
    () => GetVendorsUseCase(repository: getIt<VendorRepository>()),
  );

  getIt.registerFactory<VendorsCubit>(
    () => VendorsCubit(getVendorsUseCase: getIt<GetVendorsUseCase>()),
  );
}
