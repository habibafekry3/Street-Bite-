import 'dart:io';
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theming/cubit/theme_cubit.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import '../screens/edit_profile_screen.dart';

class ProfileBodyWidget extends StatelessWidget {
  const ProfileBodyWidget({super.key});

  void _showLogoutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('logoutConfirmTitle'.tr()),
        content: Text('logoutConfirmMessage'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AuthCubit>().logout();
            },
            child: Text(
              'confirm'.tr(),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthLoggedOut) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        }
      },
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'profileTitle'.tr(),
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 24),

            // User Profile Card
            Builder(
              builder: (context) {
                final user = FirebaseAuth.instance.currentUser;

                final userName = user?.displayName?.trim().isNotEmpty == true
                    ? user!.displayName!
                    : (user?.email?.split('@').first ?? 'StreetBite User');

                final email = user?.email ?? '';

                return Card(
                  elevation: 0,
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        BlocBuilder<ProfileCubit, ProfileState>(
                          builder: (context, state) {
                            ImageProvider? profileImage;

                            if (state.profileImageBase64 != null) {
                              profileImage = MemoryImage(
                                base64Decode(state.profileImageBase64!),
                              );
                            } else if (state.imagePath != null &&
                                File(state.imagePath!).existsSync()) {
                              profileImage = FileImage(File(state.imagePath!));
                            }

                            return GestureDetector(
                              onTap: state.isLoading
                                  ? null
                                  : () => context
                                        .read<ProfileCubit>()
                                        .pickProfileImage(),
                              child: CircleAvatar(
                                radius: 35,
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primaryContainer,
                                backgroundImage: profileImage,
                                child: profileImage == null
                                    ? Icon(
                                        Icons.add_a_photo_outlined,
                                        size: 30,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      )
                                    : null,
                              ),
                            );
                          },
                        ),

                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                email,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 32),
            BlocBuilder<ProfileCubit, ProfileState>(
              builder: (context, state) {
                final user = FirebaseAuth.instance.currentUser;

                final userName = state.displayName?.trim().isNotEmpty == true
                    ? state.displayName!
                    : (user?.email?.split('@').first ?? 'StreetBite User');

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: context.read<ProfileCubit>(),
                              child: EditProfileScreen(initialName: userName),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit_outlined),
                      label: Text('editProfile'.tr()),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 32),

            // Theme selector
            Text(
              'themeLabel'.tr(),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            BlocBuilder<ThemeCubit, ThemeMode>(
              builder: (context, mode) {
                return SegmentedButton<ThemeMode>(
                  segments: [
                    ButtonSegment(
                      value: ThemeMode.light,
                      label: Text('themeLight'.tr()),
                      icon: const Icon(Icons.light_mode_outlined),
                    ),
                    ButtonSegment(
                      value: ThemeMode.system,
                      label: Text('themeSystem'.tr()),
                      icon: const Icon(Icons.settings_suggest_outlined),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      label: Text('themeDark'.tr()),
                      icon: const Icon(Icons.dark_mode_outlined),
                    ),
                  ],
                  selected: {mode},
                  onSelectionChanged: (selected) =>
                      context.read<ThemeCubit>().setTheme(selected.first),
                );
              },
            ),
            const SizedBox(height: 32),

            // Language selector
            Text(
              'languageLabel'.tr(),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: [
                ButtonSegment(value: 'en', label: Text('languageEnglish'.tr())),
                ButtonSegment(value: 'ar', label: Text('languageArabic'.tr())),
              ],
              selected: {context.locale.languageCode},
              onSelectionChanged: (selected) =>
                  context.setLocale(Locale(selected.first)),
            ),
            const SizedBox(height: 48),

            // Logout
            OutlinedButton.icon(
              onPressed: () => _showLogoutDialog(context),
              icon: Icon(
                Icons.logout_rounded,
                color: Theme.of(context).colorScheme.error,
              ),
              label: Text(
                'logoutButton'.tr(),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Theme.of(context).colorScheme.error),
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
