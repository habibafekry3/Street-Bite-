import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/validators.dart';
import 'auth_footer_widget.dart';
import 'auth_listener_widget.dart';
import 'auth_text_field_widget.dart';
import 'password_field_widget.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class SignUpBodyWidget extends StatefulWidget {
  const SignUpBodyWidget({super.key});

  @override
  State<SignUpBodyWidget> createState() => _SignUpBodyWidgetState();
}

class _SignUpBodyWidgetState extends State<SignUpBodyWidget> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().signUp(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthListenerWidget(
      replaceAll: true,
      child: Scaffold(
        appBar: AppBar(title: Text('signUpTitle'.tr())),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'signUpSubtitle'.tr(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 32),
                  AuthTextFieldWidget(
                    controller: _nameController,
                    label: 'nameLabel'.tr(),
                    validator: (v) => Validators.required(v, 'nameRequired'),
                  ),
                  const SizedBox(height: 16),
                  AuthTextFieldWidget(
                    controller: _emailController,
                    label: 'emailLabel'.tr(),
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
                  ),
                  const SizedBox(height: 16),
                  PasswordFieldWidget(
                    controller: _passwordController,
                    label: 'passwordLabel'.tr(),
                    validator: Validators.password,
                  ),
                  const SizedBox(height: 16),
                  PasswordFieldWidget(
                    controller: _confirmController,
                    label: 'confirmPasswordLabel'.tr(),
                    validator: (v) =>
                        Validators.confirmPassword(v, _passwordController.text),
                  ),
                  const SizedBox(height: 32),
                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      if (state is AuthLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return ElevatedButton(
                        onPressed: _submit,
                        child: Text('signUpButton'.tr()),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  AuthFooterWidget(
                    questionText: 'haveAccount'.tr(),
                    linkText: 'loginLink'.tr(),
                    onTap: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
