import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../home/domain/entities/meal_entity.dart';
import '../cubit/favorites_cubit.dart';
import '../cubit/favorites_state.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _FavoritesView();
  }
}

class _FavoritesView extends StatelessWidget {
  const _FavoritesView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'favouriteTitle'.tr(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: BlocBuilder<FavoritesCubit, FavoritesState>(
        builder: (context, state) {
          if (state is FavoritesInitial || state is FavoritesLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is FavoritesError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      '${'favoritesError'.tr()}\n${state.message}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () {
                        context.read<FavoritesCubit>().watchFavorites();
                      },
                      child: Text('retry'.tr()),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is FavoritesLoaded) {
            if (state.meals.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.favorite_border, size: 64),
                    const SizedBox(height: 12),
                    Text(
                      'favoritesEmpty'.tr(),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              );
            }

            return SafeArea(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.meals.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final meal = state.meals[index];

                  return _FavoriteMealCard(meal: meal);
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _FavoriteMealCard extends StatelessWidget {
  final MealEntity meal;

  const _FavoriteMealCard({required this.meal});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: const EdgeInsets.all(8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            meal.thumbnailUrl,
            width: 76,
            height: 76,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => const SizedBox(
              width: 76,
              height: 76,
              child: Icon(Icons.broken_image_outlined),
            ),
          ),
        ),
        title: Text(meal.name, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Text(meal.category),
        trailing: IconButton(
          tooltip: 'removeFavorite'.tr(),
          icon: const Icon(Icons.favorite, color: Colors.red),
          onPressed: () {
            context.read<FavoritesCubit>().removeFavorite(meal.id);
          },
        ),
      ),
    );
  }
}
