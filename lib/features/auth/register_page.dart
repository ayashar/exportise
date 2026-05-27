import 'package:flutter/material.dart';

import '../../core/api/api_client.dart';
import '../../core/api/api_repository.dart';
import '../../core/iconography/app_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/app_button.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _companyController = TextEditingController();
  final _emailController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _repository = ApiRepository();

  int _step = 0;
  bool _isLoading = false;

  @override
  void dispose() {
    _companyController.dispose();
    _emailController.dispose();
    _fullNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral01,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _BackButton(
                      onTap: () {
                        if (_step == 1) {
                          setState(() => _step = 0);
                          return;
                        }
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  const AuthBrand(),
                ],
              ),
              const SizedBox(height: 32),
              Text(
                'Mulai Ekspor Sekarang',
                textAlign: TextAlign.center,
                style: AppTypography.headlineLg.copyWith(
                  color: AppColors.neutral10,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Bergabunglah dengan ribuan UMKM yang\ntelah go-global bersama Eksportise.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.neutral08,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 42),
              AuthCard(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: _step == 0
                      ? _RegisterAccountStep(
                          companyController: _companyController,
                          confirmPasswordController: _confirmPasswordController,
                          emailController: _emailController,
                          fullNameController: _fullNameController,
                          onNext: () => setState(() => _step = 1),
                          passwordController: _passwordController,
                        )
                      : _RegisterBusinessStep(
                          isLoading: _isLoading,
                          onBack: () => setState(() => _step = 0),
                          onSubmit: () => _register(context),
                          phoneController: _phoneController,
                        ),
                ),
              ),
              const SizedBox(height: 28),
              const AuthTerms(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _register(BuildContext context) async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password dan konfirmasi harus sama.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _repository.register(
        companyName: _companyController.text.trim(),
        email: _emailController.text.trim(),
        fullName: _fullNameController.text.trim(),
        password: _passwordController.text,
        phone: _phoneController.text.trim(),
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Akun berhasil dibuat. Silakan masuk.')),
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (context) => const LoginPage()),
        (route) => false,
      );
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.message.isEmpty ? 'Registrasi gagal' : error.message,
          ),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registrasi gagal. Coba lagi.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

class _RegisterAccountStep extends StatelessWidget {
  const _RegisterAccountStep({
    required this.companyController,
    required this.confirmPasswordController,
    required this.emailController,
    required this.fullNameController,
    required this.onNext,
    required this.passwordController,
  });

  final TextEditingController companyController;
  final TextEditingController confirmPasswordController;
  final TextEditingController emailController;
  final TextEditingController fullNameController;
  final VoidCallback onNext;
  final TextEditingController passwordController;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('register-account'),
      children: [
        const StepDots(activeStep: 0, totalSteps: 2),
        const SizedBox(height: 32),
        AuthTextField(
          controller: fullNameController,
          label: 'Nama Lengkap',
          hintText: 'Masukan nama lengkap',
        ),
        const SizedBox(height: 20),
        AuthTextField(
          controller: emailController,
          label: 'Email Bisnis',
          hintText: 'contoh@bisnis.com',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 20),
        AuthTextField(
          controller: companyController,
          label: 'Nama UMKM',
          hintText: 'Nama usaha Anda',
        ),
        const SizedBox(height: 20),
        AuthTextField(
          controller: passwordController,
          label: 'Password',
          hintText: 'Minimal 8 karakter',
          obscureText: true,
        ),
        const SizedBox(height: 20),
        AuthTextField(
          controller: confirmPasswordController,
          label: 'Konfirmasi Password',
          hintText: 'Masukan kembali password',
          obscureText: true,
        ),
        const SizedBox(height: 32),
        AppButton(
          label: 'Selanjutnya',
          isFullWidth: true,
          size: AppButtonSize.lg,
          onPressed: onNext,
        ),
        const SizedBox(height: 16),
        AuthLinkRow(
          text: 'Sudah punya akun?',
          actionText: 'Masuk di sini',
          onTap: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

class _RegisterBusinessStep extends StatelessWidget {
  const _RegisterBusinessStep({
    required this.isLoading,
    required this.onBack,
    required this.onSubmit,
    required this.phoneController,
  });

  final bool isLoading;
  final VoidCallback onBack;
  final VoidCallback onSubmit;
  final TextEditingController phoneController;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('register-business'),
      children: [
        const StepDots(activeStep: 1, totalSteps: 2),
        const SizedBox(height: 32),
        AuthTextField(
          controller: phoneController,
          label: 'Nomor Telepon',
          hintText: '08xxxxxxxxxx',
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 20),
        Text(
          'Kontrak API saat ini hanya memakai identitas utama dan nomor telepon. Field tambahan untuk alamat belum tersedia di backend.',
          style: AppTypography.bodySm.copyWith(
            color: AppColors.neutral08,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 32),
        AppButton(
          label: 'Daftar',
          isFullWidth: true,
          isLoading: isLoading,
          size: AppButtonSize.lg,
          onPressed: isLoading ? null : onSubmit,
        ),
        const SizedBox(height: 16),
        AppButton(
          label: 'Kembali',
          isFullWidth: true,
          variant: AppButtonVariant.ghost,
          size: AppButtonSize.lg,
          onPressed: onBack,
        ),
        const SizedBox(height: 16),
        AuthLinkRow(
          text: 'Sudah punya akun?',
          actionText: 'Masuk di sini',
          onTap: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.neutral01,
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              color: Color(0x147A5900),
              blurRadius: 16,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: AppIcon(
            AppIcons.arrowLeft(),
            color: AppColors.neutral09,
            dimension: 28,
          ),
        ),
      ),
    );
  }
}
