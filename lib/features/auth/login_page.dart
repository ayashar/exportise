import 'package:flutter/material.dart';

import '../../core/iconography/app_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/app_dropdown_field.dart';
import '../home/home_page.dart';
import 'register_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral01,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 54, 20, 28),
          child: Column(
            children: [
              const AuthBrand(),
              const SizedBox(height: 32),
              Text(
                'Selamat Datang!',
                textAlign: TextAlign.center,
                style: AppTypography.headlineLg.copyWith(
                  color: AppColors.neutral10,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Eksportise siap membantumu\nmengembangkan usaha yang kamu miliki.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.neutral08,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 44),
              AuthCard(
                child: Column(
                  children: [
                    const StepDots(activeStep: 0, totalSteps: 2),
                    const SizedBox(height: 32),
                    const AuthTextField(
                      label: 'Email Bisnis',
                      hintText: 'contoh@bisnis.com',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20),
                    const AuthTextField(
                      label: 'Password',
                      hintText: 'Minimal 8 karakter',
                      obscureText: true,
                    ),
                    const SizedBox(height: 32),
                    AuthPrimaryButton(
                      label: 'Masuk',
                      onPressed: () => _goHome(context),
                    ),
                    const SizedBox(height: 16),
                    AuthLinkRow(
                      text: 'Belum punya akun?',
                      actionText: 'Daftar di sini',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (context) => const RegisterPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              const AuthTerms(),
            ],
          ),
        ),
      ),
    );
  }
}

void _goHome(BuildContext context) {
  Navigator.of(context).pushReplacement(
    MaterialPageRoute<void>(builder: (context) => const HomePage()),
  );
}

class AuthBrand extends StatelessWidget {
  const AuthBrand({super.key});

  static const _logoAsset = 'assets/images/logo/exportise-brown.png';

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(_logoAsset, width: 36, height: 36, fit: BoxFit.contain),
        const SizedBox(width: 8),
        Text(
          'Eksportise',
          style: AppTypography.headlineMd.copyWith(color: AppColors.primary05),
        ),
      ],
    );
  }
}

class AuthCard extends StatelessWidget {
  const AuthCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: BoxDecoration(
        color: AppColors.system01,
        borderRadius: BorderRadius.circular(14),
      ),
      child: child,
    );
  }
}

class StepDots extends StatelessWidget {
  const StepDots({
    super.key,
    required this.activeStep,
    required this.totalSteps,
  });

  final int activeStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (index) {
        final isActive = index == activeStep;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: isActive ? 22 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary04 : AppColors.secondary08,
            borderRadius: BorderRadius.circular(8),
          ),
        );
      }),
    );
  }
}

class AuthTextField extends StatefulWidget {
  const AuthTextField({
    super.key,
    required this.hintText,
    required this.label,
    this.keyboardType,
    this.obscureText = false,
  });

  final String hintText;
  final TextInputType? keyboardType;
  final String label;
  final bool obscureText;

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  late bool _isObscured = widget.obscureText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AppTypography.bodySm.copyWith(
            color: AppColors.neutral08,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          obscureText: _isObscured,
          keyboardType: widget.keyboardType,
          style: AppTypography.bodySm.copyWith(color: AppColors.neutral08),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: AppTypography.bodySm.copyWith(color: AppColors.system05),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            filled: true,
            fillColor: AppColors.tertiary05,
            suffixIcon: widget.obscureText
                ? IconButton(
                    onPressed: () {
                      setState(() => _isObscured = !_isObscured);
                    },
                    icon: AppIcon(
                      AppIcons.eye(),
                      color: AppColors.system05,
                      dimension: 18,
                    ),
                  )
                : null,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.tertiary06),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary04),
            ),
          ),
        ),
      ],
    );
  }
}

class AuthDropdownField extends StatelessWidget {
  const AuthDropdownField({
    super.key,
    required this.hintText,
    required this.label,
    required this.items,
    required this.onChanged,
    this.value,
  });

  final String hintText;
  final List<String> items;
  final String label;
  final ValueChanged<String?> onChanged;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return AppDropdownField(
      hintText: hintText,
      items: items,
      label: label,
      onChanged: onChanged,
      value: value,
    );
  }
}

class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: AppColors.primary04,
          foregroundColor: AppColors.primary08,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          label,
          style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class AuthLinkRow extends StatelessWidget {
  const AuthLinkRow({
    super.key,
    required this.actionText,
    required this.onTap,
    required this.text,
  });

  final String actionText;
  final VoidCallback onTap;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '$text ',
          style: AppTypography.bodySm.copyWith(color: AppColors.primary05),
        ),
        InkWell(
          onTap: onTap,
          child: Text(
            actionText,
            style: AppTypography.bodySm.copyWith(color: AppColors.secondary04),
          ),
        ),
      ],
    );
  }
}

class AuthTerms extends StatelessWidget {
  const AuthTerms({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Dengan mendaftar, Anda menyetujui Syarat &\nKetentuan serta Kebijakan Privasi Eksportise.',
      textAlign: TextAlign.center,
      style: AppTypography.bodySm.copyWith(
        color: AppColors.neutral07,
        fontSize: 12,
        height: 1.2,
      ),
    );
  }
}
