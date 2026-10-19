import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_app/core/dependency_injection/injection.dart';
import '../../../../core/theming/cubit/theme_cubit.dart';
import '../../domain/entities/meal_entity.dart';
import '../cubit/meals_cubit.dart';
import '../cubit/meals_state.dart';
import '../widgets/featured_banner_widget.dart';
import '../widgets/hot_offers_widget.dart';
import '../widgets/meal_card_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<MealsCubit>()..loadMeals(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'appName'.tr(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            BlocBuilder<ThemeCubit, ThemeMode>(
              builder: (ctx, mode) {
                final isDark =
                    mode == ThemeMode.dark ||
                    (mode == ThemeMode.system &&
                        MediaQuery.platformBrightnessOf(ctx) ==
                            Brightness.dark);
                return IconButton(
                  tooltip: 'toggleTheme'.tr(),
                  icon: Icon(
                    isDark
                        ? Icons.light_mode_outlined
                        : Icons.dark_mode_outlined,
                  ),
                  onPressed: () => ctx.read<ThemeCubit>().setTheme(
                    isDark ? ThemeMode.light : ThemeMode.dark,
                  ),
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<MealsCubit, MealsState>(
          builder: (ctx, state) {
            if (state is MealsInitial || state is MealsLoading) {
              return const _LoadingBody();
            }
            if (state is MealsError) {
              return _ErrorBody(messageKey: state.messageKey);
            }
            if (state is MealsEmpty) {
              return Center(child: Text('noMealsAvailable'.tr()));
            }
            if (state is MealsLoaded) {
              return _HomeBody(meals: state.meals);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

// ── Loading ───────────────────────────────────────────────────────────────────

class _LoadingBody extends StatelessWidget {
  const _LoadingBody();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

// ── Error ─────────────────────────────────────────────────────────────────────

class _ErrorBody extends StatelessWidget {
  final String messageKey;
  const _ErrorBody({required this.messageKey});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              messageKey.tr(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Success body ──────────────────────────────────────────────────────────────

class _HomeBody extends StatelessWidget {
  final List<MealEntity> meals;
  const _HomeBody({required this.meals});

  @override
  Widget build(BuildContext context) {
    // Featured banner: up to first 5 meals.
    final featured = meals.take(5).toList();
    // Hot picks: next up to 5 distinct meals (different from featured).
    final offers = meals.skip(featured.length).take(5).toList();

    return RefreshIndicator(
      onRefresh: () => context.read<MealsCubit>().refreshMeals(),
      child: CustomScrollView(
        slivers: [
          // ── Featured meals header ────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Text(
                'featuredMeals'.tr(),
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // ── Featured PageView banner ─────────────────────────────────────────
          SliverToBoxAdapter(child: FeaturedBannerWidget(meals: featured)),

          // ── Hot picks horizontal list ────────────────────────────────────────
          SliverToBoxAdapter(child: HotOffersWidget(meals: offers)),

          // ── Live Menu header ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Text(
                'liveMenu'.tr(),
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // ── Two-column meals grid (no nested scroll conflicts) ───────────────
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.55,
              ),
              delegate: SliverChildBuilderDelegate(
                (ctx, idx) => MealCardWidget(meal: meals[idx]),
                childCount: meals.length,
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }
}
