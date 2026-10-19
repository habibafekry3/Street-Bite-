import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/dependency_injection/injection.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';

import '../cubit/profile_cubit.dart';
import '../widgets/profile_body_widget.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<AuthCubit>()),
        BlocProvider(create: (_) => getIt<ProfileCubit>()..loadSavedImage()),
      ],
      child: const ProfileBodyWidget(),
    );
  }
}
