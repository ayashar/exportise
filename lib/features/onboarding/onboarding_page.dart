import 'package:flutter/material.dart';

import '../../core/iconography/app_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/app_button.dart';
import '../auth/login_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int _currentPage = 0;
  String? _category;
  int _experienceIndex = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (context) => const LoginPage()),
    );
  }

  void _nextPage() {
    if (_currentPage == 2) {
      _goToLogin();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  void _previousPage() {
    _controller.previousPage(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral01,
      body: SafeArea(
        child: PageView(
          controller: _controller,
          onPageChanged: (page) => setState(() => _currentPage = page),
          children: [
            _IntroOnboardingPage(
              activePage: _currentPage,
              onNext: _nextPage,
              onSkip: _goToLogin,
            ),
            _ProductStoryPage(
              activePage: _currentPage,
              selectedExperience: _experienceIndex,
              onBack: _previousPage,
              onExperienceChanged: (index) {
                setState(() => _experienceIndex = index);
              },
              onNext: _nextPage,
              onSkip: _goToLogin,
            ),
            _TryAnalysisPage(
              activePage: _currentPage,
              category: _category,
              onBack: _previousPage,
              onCategoryChanged: (value) {
                setState(() => _category = value);
              },
              onNext: _nextPage,
              onSkip: _goToLogin,
            ),
          ],
        ),
      ),
    );
  }
}

class _IntroOnboardingPage extends StatelessWidget {
  const _IntroOnboardingPage({
    required this.activePage,
    required this.onNext,
    required this.onSkip,
  });

  final int activePage;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return _OnboardingShell(
      activePage: activePage,
      buttonLabel: 'Selanjutnya',
      onNext: onNext,
      onSkip: onSkip,
      children: [
        const AuthBrand(),
        const SizedBox(height: 34),
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.asset(
            'assets/images/onboarding/export_market_hero.png',
            width: double.infinity,
            height: 224,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 34),
        Text(
          'Produkmu bisa laku di\nAmerika, Eropa, Jepang',
          style: AppTypography.headlineLg.copyWith(
            color: AppColors.neutral10,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Tapi kamu perlu tahu apa yang diinginkan pembeli di sana. Eksportise bantu kamu riset pasar hanya dalam 15 menit.',
          style: AppTypography.bodyMd.copyWith(
            color: AppColors.neutral08,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 32),
        const _ComparisonCard(),
      ],
    );
  }
}

class _ProductStoryPage extends StatelessWidget {
  const _ProductStoryPage({
    required this.activePage,
    required this.onBack,
    required this.onExperienceChanged,
    required this.onNext,
    required this.onSkip,
    required this.selectedExperience,
  });

  final int activePage;
  final VoidCallback onBack;
  final ValueChanged<int> onExperienceChanged;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final int selectedExperience;

  @override
  Widget build(BuildContext context) {
    return _OnboardingShell(
      activePage: activePage,
      buttonLabel: 'Selanjutnya',
      onNext: onNext,
      onSkip: onSkip,
      children: [
        _OnboardingHeader(onBack: onBack, showBackButton: true),
        const SizedBox(height: 32),
        Text(
          'Cerita dulu tentang\nprodukmu',
          style: AppTypography.headlineLg.copyWith(
            color: AppColors.neutral10,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Supaya analisis lebih akurat. Kamu bisa ubah ini kapan saja.',
          style: AppTypography.bodyMd.copyWith(
            color: AppColors.neutral08,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 34),
        Text(
          'Produk utama yang kamu jual',
          style: AppTypography.bodyMd.copyWith(
            color: AppColors.neutral09,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 14),
        const Row(
          children: [
            _CategoryChip(label: 'Kerajinan Tangan'),
            SizedBox(width: 10),
            _CategoryChip(label: 'Pakaian'),
          ],
        ),
        const SizedBox(height: 34),
        Text(
          'Sudah pernah ekspor?',
          style: AppTypography.bodyMd.copyWith(
            color: AppColors.neutral09,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 14),
        _ExperienceOption(
          icon: AppIcons.smiley(),
          isSelected: selectedExperience == 0,
          label: 'Belum Pernah',
          onTap: () => onExperienceChanged(0),
        ),
        const SizedBox(height: 16),
        _ExperienceOption(
          icon: AppIcons.truck(),
          isSelected: selectedExperience == 1,
          label: 'Pernah Coba',
          onTap: () => onExperienceChanged(1),
        ),
        const SizedBox(height: 16),
        _ExperienceOption(
          icon: AppIcons.rocket(),
          isSelected: selectedExperience == 2,
          label: 'Eksportir Aktif',
          onTap: () => onExperienceChanged(2),
        ),
      ],
    );
  }
}

class _TryAnalysisPage extends StatelessWidget {
  const _TryAnalysisPage({
    required this.activePage,
    required this.category,
    required this.onBack,
    required this.onCategoryChanged,
    required this.onNext,
    required this.onSkip,
  });

  final int activePage;
  final String? category;
  final VoidCallback onBack;
  final ValueChanged<String?> onCategoryChanged;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return _OnboardingShell(
      activePage: activePage,
      buttonLabel: 'Coba Analisis',
      onNext: onNext,
      onSkip: onSkip,
      children: [
        _OnboardingHeader(onBack: onBack, showBackButton: true),
        const SizedBox(height: 32),
        Text(
          'Coba sekarang',
          style: AppTypography.headlineLg.copyWith(
            color: AppColors.neutral10,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Ketik nama barangmu, pilih negara tujuan, lihat hasilnya langsung.',
          style: AppTypography.bodyMd.copyWith(
            color: AppColors.neutral08,
            height: 1.55,
          ),
        ),
        const SizedBox(height: 32),
        AuthCard(
          child: Column(
            children: [
              const AuthTextField(
                label: 'Nama barang',
                hintText: 'e.g., tas anyaman',
              ),
              const SizedBox(height: 28),
              AuthDropdownField(
                label: 'Kategori',
                hintText: 'Pilih Kategori',
                value: category,
                items: const ['Kerajinan Tangan', 'Pakaian'],
                onChanged: onCategoryChanged,
              ),
              const SizedBox(height: 28),
              const AuthTextField(
                label: 'Deskripsi Produk',
                hintText: 'e.g., tas anyaman',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OnboardingShell extends StatelessWidget {
  const _OnboardingShell({
    required this.activePage,
    required this.buttonLabel,
    required this.children,
    required this.onNext,
    required this.onSkip,
  });

  final int activePage;
  final String buttonLabel;
  final List<Widget> children;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final topPadding = MediaQuery.paddingOf(context).top;
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: screenHeight - topPadding - bottomPadding - 50,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...children,
            const SizedBox(height: 40),
            AppButton(
              label: buttonLabel,
              isFullWidth: true,
              size: AppButtonSize.lg,
              onPressed: onNext,
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: onSkip,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary05,
                  minimumSize: const Size(80, 40),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Lewati',
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.primary05,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 26),
            Center(child: StepDots(activeStep: activePage, totalSteps: 3)),
          ],
        ),
      ),
    );
  }
}

class _OnboardingHeader extends StatelessWidget {
  const _OnboardingHeader({required this.onBack, required this.showBackButton});

  final VoidCallback onBack;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (showBackButton)
          Align(
            alignment: Alignment.centerLeft,
            child: _BackCircleButton(onTap: onBack),
          ),
        const AuthBrand(),
      ],
    );
  }
}

class _BackCircleButton extends StatelessWidget {
  const _BackCircleButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: const BoxDecoration(
          color: AppColors.neutral01,
          shape: BoxShape.circle,
          boxShadow: [
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

class _ComparisonCard extends StatelessWidget {
  const _ComparisonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 22),
      decoration: BoxDecoration(
        color: AppColors.system01,
        border: Border.all(color: AppColors.neutral06),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _ComparisonTitle('Tanpa Exportise'),
          SizedBox(height: 10),
          _ComparisonLine(
            icon: AppIcons.close,
            iconColor: AppColors.error02,
            text: '4-8 minggu riset manual',
          ),
          SizedBox(height: 10),
          _ComparisonLine(
            icon: AppIcons.close,
            iconColor: AppColors.error02,
            text: 'Biaya riset Rp 5-15 Juta',
          ),
          SizedBox(height: 18),
          Divider(height: 1, color: AppColors.neutral05),
          SizedBox(height: 18),
          _ComparisonTitle('Dengan Exportise', color: AppColors.primary05),
          SizedBox(height: 10),
          _ComparisonLine(
            icon: AppIcons.check,
            iconColor: AppColors.tertiary03,
            text: 'Riset instan dengan AI cerdas',
          ),
          SizedBox(height: 10),
          _ComparisonLine(
            icon: AppIcons.check,
            iconColor: AppColors.tertiary03,
            text: 'Insight pasar global yang akurat',
          ),
        ],
      ),
    );
  }
}

class _ComparisonTitle extends StatelessWidget {
  const _ComparisonTitle(this.text, {this.color = AppColors.neutral07});

  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: AppTypography.bodySm.copyWith(color: color));
  }
}

class _ComparisonLine extends StatelessWidget {
  const _ComparisonLine({
    required this.icon,
    required this.iconColor,
    required this.text,
  });

  final IconData Function([PhosphorIconsStyle style]) icon;
  final Color iconColor;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppIcon(icon(), color: iconColor, dimension: 17),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTypography.bodySm.copyWith(color: AppColors.neutral08),
          ),
        ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.neutral01,
        border: Border.all(color: AppColors.secondary08),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        label,
        style: AppTypography.bodySm.copyWith(
          color: AppColors.neutral09,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ExperienceOption extends StatelessWidget {
  const _ExperienceOption({
    required this.icon,
    required this.isSelected,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final bool isSelected;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        height: 74,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.neutral01,
          border: Border.all(color: AppColors.secondary08),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.neutral03,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: AppIcon(icon, color: AppColors.primary05, dimension: 24),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.neutral09,
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary04
                      : AppColors.secondary08,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: AppColors.primary04,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
