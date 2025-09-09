import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/validators.dart';
import '../../../injection_container.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/loading_widget.dart';
import '../dashboard/dashboard_screen.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<AuthBloc>(),
      child: const _RegisterView(),
    );
  }
}

class _RegisterView extends StatefulWidget {
  const _RegisterView({Key? key}) : super(key: key);

  @override
  State<_RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<_RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _phoneController = TextEditingController();

  int _cooldown = 0; // seconds remaining
  int _cooldownTotal = 0; // total seconds for progress
  Timer? _cooldownTimer;
  bool _pendingRetry = false;

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _businessNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const DashboardScreen(),
              ),
              (route) => false,
            );
      } else if (state is AuthError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.message),
            backgroundColor: AppColors.error,
          ),
        );

        // Start cooldown on Supabase email rate limit
        final msg = state.message.toLowerCase();
        if (msg.contains('over_email_send_rate_limit') ||
            msg.contains('terlalu banyak permintaan') ||
            msg.contains('429')) {
          setState(() {
            _pendingRetry = true;
          });
          _startCooldown(60);
        }
      }
    },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const LoadingWidget(message: 'Membuat akun...');
          }

          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(),
                    SizedBox(height: 32.h),
                    _buildRegisterForm(),
                    SizedBox(height: 24.h),
                    _buildRegisterButton(),
                    SizedBox(height: 16.h),
                    _buildLoginLink(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          'Buat Akun Baru',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Mulai kelola toko online Anda',
          style: TextStyle(
            fontSize: 16.sp,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return Column(
      children: [
        CustomTextField(
          label: AppStrings.businessName,
          hint: 'Masukkan nama toko Anda',
          controller: _businessNameController,
          validator: (value) => Validators.validateRequired(value, 'Nama toko'),
          prefixIcon: const Icon(Icons.store_outlined),
          textCapitalization: TextCapitalization.words,
        ),
        SizedBox(height: 16.h),
        CustomTextField(
          label: AppStrings.email,
          hint: 'Masukkan email Anda',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          validator: Validators.validateEmail,
          prefixIcon: const Icon(Icons.email_outlined),
        ),
        SizedBox(height: 16.h),
        CustomTextField(
          label: AppStrings.phoneNumber,
          hint: 'Masukkan nomor telepon (opsional)',
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          validator: Validators.validatePhone,
          prefixIcon: const Icon(Icons.phone_outlined),
        ),
        SizedBox(height: 16.h),
        CustomTextField(
          label: AppStrings.password,
          hint: 'Masukkan kata sandi',
          controller: _passwordController,
          obscureText: true,
          validator: Validators.validatePassword,
          prefixIcon: const Icon(Icons.lock_outline),
        ),
        SizedBox(height: 16.h),
        CustomTextField(
          label: AppStrings.confirmPassword,
          hint: 'Konfirmasi kata sandi',
          controller: _confirmPasswordController,
          obscureText: true,
          validator: (value) => Validators.validateConfirmPassword(
            _passwordController.text,
            value,
          ),
          prefixIcon: const Icon(Icons.lock_outline),
        ),
      ],
    );
  }

  Widget _buildRegisterButton() {
    final isCoolingDown = _cooldown > 0;
    final buttonText = isCoolingDown
        ? 'Kirim ulang dalam ${_cooldown}s'
        : AppStrings.register;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomButton(
          text: buttonText,
          onPressed: isCoolingDown ? null : _onRegisterPressed,
        ),
        if (isCoolingDown) ...[
          SizedBox(height: 10.h),
          LinearProgressIndicator(
            value: _cooldownTotal > 0
                ? (_cooldownTotal - _cooldown) / _cooldownTotal
                : null,
            backgroundColor: AppColors.divider,
            color: AppColors.primary,
            minHeight: 6,
          ),
          SizedBox(height: 8.h),
          Text(
            'Kirim ulang otomatis dalam ${_cooldown}s',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.textSecondary,
            ),
          ),
        ]
      ],
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          AppStrings.alreadyHaveAccount,
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(width: 4.w),
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Text(
            AppStrings.login,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  void _onRegisterPressed() {
    if (_formKey.currentState!.validate()) {
      if (_cooldown > 0) return; // safety guard
      context.read<AuthBloc>().add(
            AuthRegisterRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text,
              businessName: _businessNameController.text.trim(),
              phone: _phoneController.text.trim().isNotEmpty
                  ? _phoneController.text.trim()
                  : null,
            ),
          );
    }
  }

  void _startCooldown(int seconds) {
    _cooldownTimer?.cancel();
    setState(() {
      _cooldown = seconds;
      _cooldownTotal = seconds;
    });
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_cooldown <= 1) {
        timer.cancel();
        if (mounted) {
          setState(() {
            _cooldown = 0;
          });
          // Auto retry once cooldown finished
          if (_pendingRetry) {
            // Avoid spamming if still loading
            final authState = context.read<AuthBloc>().state;
            final canSubmit = _formKey.currentState?.validate() ?? false;
            if (authState is! AuthLoading && canSubmit) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Mencoba kirim ulang pendaftaran...'),
                ),
              );
              _pendingRetry = false;
              _onRegisterPressed();
            }
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _cooldown -= 1;
          });
        }
      }
    });
  }
}
