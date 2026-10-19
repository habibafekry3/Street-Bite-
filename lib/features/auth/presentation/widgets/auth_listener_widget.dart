import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../main_layout/main_layout_screen.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class AuthListenerWidget extends StatelessWidget {
  final Widget child;
  final bool replaceAll;

  const AuthListenerWidget({
    super.key,
    required this.child,
    this.replaceAll = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          if (replaceAll) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const MainLayoutScreen()),
              (route) => false,
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const MainLayoutScreen()),
            );
          }
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message.tr()),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      },
      child: child,
    );
  }
}
