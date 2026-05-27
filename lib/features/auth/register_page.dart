import 'package:flutter/material.dart';

import '../../core/iconography/app_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../home/home_page.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  int _step = 0;
  String? _province;
  String? _city;
  String? _district;

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
                          onNext: () => setState(() => _step = 1),
                        )
                      : _RegisterBusinessStep(
                          city: _city,
                          district: _district,
                          province: _province,
                          onCityChanged: (value) =>
                              setState(() => _city = value),
                          onDistrictChanged: (value) {
                            setState(() => _district = value);
                          },
                          onProvinceChanged: (value) {
                            setState(() => _province = value);
                          },
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
}

class _RegisterAccountStep extends StatelessWidget {
  const _RegisterAccountStep({required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('register-account'),
      children: [
        const StepDots(activeStep: 0, totalSteps: 2),
        const SizedBox(height: 32),
        const AuthTextField(
          label: 'Nama Lengkap',
          hintText: 'Masukan nama lengkap',
        ),
        const SizedBox(height: 20),
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
        const SizedBox(height: 20),
        const AuthTextField(
          label: 'Konfirmasi Password',
          hintText: 'Masukan kembali password',
          obscureText: true,
        ),
        const SizedBox(height: 32),
        AuthPrimaryButton(label: 'Selanjutnya', onPressed: onNext),
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
    required this.city,
    required this.district,
    required this.onCityChanged,
    required this.onDistrictChanged,
    required this.onProvinceChanged,
    required this.province,
  });

  final String? city;
  final String? district;
  final ValueChanged<String?> onCityChanged;
  final ValueChanged<String?> onDistrictChanged;
  final ValueChanged<String?> onProvinceChanged;
  final String? province;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('register-business'),
      children: [
        const StepDots(activeStep: 1, totalSteps: 2),
        const SizedBox(height: 32),
        const AuthTextField(label: 'Nama UMKM', hintText: 'Nama usaha Anda'),
        const SizedBox(height: 20),
        AuthDropdownField(
          label: 'Provinsi',
          hintText: 'Pilih Provinsi',
          value: province,
          items: const ['Yogyakarta', 'DI Yogyakarta', 'Jawa Tengah'],
          onChanged: onProvinceChanged,
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: AuthDropdownField(
                label: 'Kota/Kabupaten',
                hintText: 'Pilih...',
                value: city,
                items: const ['Sleman', 'Bantul', 'Yogyakarta'],
                onChanged: onCityChanged,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AuthDropdownField(
                label: 'Kecamatan/Distrik',
                hintText: 'Pilih...',
                value: district,
                items: const ['Berbah', 'Mlati', 'Depok'],
                onChanged: onDistrictChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const AuthTextField(
          label: 'Alamat Lengkap',
          hintText: 'Masukan Alamat',
        ),
        const SizedBox(height: 32),
        AuthPrimaryButton(
          label: 'Daftar',
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(builder: (context) => const HomePage()),
            );
          },
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
