import 'package:flutter/material.dart';

import '../../core/iconography/app_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/app_bottom_navigation.dart';
import '../../shared/widgets/app_button.dart';
import '../analysis/analysis_input_page.dart';
import '../brains/brain_studio_page.dart';
import '../notifications/notification_page.dart';
import '../reports/history_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isEditing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral01,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 130),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _ProfileHeader(),
                  const SizedBox(height: 34),
                  Align(
                    alignment: Alignment.centerRight,
                    child: _EditProfileButton(
                      isEditing: _isEditing,
                      onTap: () => setState(() => _isEditing = true),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const _ProfileIdentity(),
                  const SizedBox(height: 34),
                  _ProfileSection(
                    title: 'Informasi Akun',
                    children: [
                      const _ProfileTextField(
                        label: 'Nama Lengkap',
                        value: 'Khanirani Nuraddawiya',
                      ),
                      const SizedBox(height: 20),
                      const _ProfileTextField(
                        label: 'Email Bisnis',
                        value: 'arunika@gmail.com',
                      ),
                      const SizedBox(height: 20),
                      const _ProfileTextField(
                        label: 'Password',
                        value: '********',
                        obscureAction: true,
                      ),
                      if (_isEditing) ...[
                        const SizedBox(height: 20),
                        const _ProfileTextField(
                          label: 'Konfirmasi Password',
                          value: '********',
                          obscureAction: true,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 36),
                  _ProfileSection(
                    title: 'Informasi UMKM',
                    children: [
                      const _ProfileTextField(
                        label: 'Nama UMKM',
                        value: 'Arunika Tas',
                      ),
                      const SizedBox(height: 20),
                      const _ProfileTextField(
                        label: 'Provinsi',
                        value: 'DI Yogyakarta',
                        dropdown: true,
                      ),
                      const SizedBox(height: 20),
                      const Row(
                        children: [
                          Expanded(
                            child: _ProfileTextField(
                              label: 'Kota/Kabupaten',
                              value: 'Sleman',
                              dropdown: true,
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: _ProfileTextField(
                              label: 'Kecamatan',
                              value: 'Mlati',
                              dropdown: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const _ProfileTextField(
                        label: 'Alamat Lengkap',
                        value: 'Jalan rindu, Sendadi, Jogoboyoo Limo',
                      ),
                    ],
                  ),
                  if (_isEditing) ...[
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            label: 'Batal',
                            variant: AppButtonVariant.ghost,
                            onPressed: () {
                              setState(() => _isEditing = false);
                            },
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: AppButton(
                            label: 'Simpan Perubahan',
                            size: AppButtonSize.lg,
                            onPressed: () {
                              setState(() => _isEditing = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Perubahan profil disimpan.'),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: AppBottomNavigation(
                selectedTab: AppTab.home,
                onTabSelected: (tab) {
                  if (tab == AppTab.home) {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  }
                  if (tab == AppTab.analysis) {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => const AnalysisInputPage(),
                      ),
                    );
                  }
                  if (tab == AppTab.reports) {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => const HistoryPage(),
                      ),
                    );
                  }
                  if (tab == AppTab.brains) {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => const BrainStudioPage.fresh(),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 24,
          backgroundImage: AssetImage('assets/images/home/profile.png'),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Arunika Tas',
            style: AppTypography.headlineSm.copyWith(
              color: AppColors.neutral09,
            ),
          ),
        ),
        InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => const NotificationPage(),
              ),
            );
          },
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.system01,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.neutral03),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A7A5900),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: AppIcon(
                AppIcons.bell(),
                color: AppColors.primary05,
                dimension: 22,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _EditProfileButton extends StatelessWidget {
  const _EditProfileButton({required this.isEditing, required this.onTap});

  final bool isEditing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: isEditing ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isEditing ? AppColors.system04 : AppColors.primary04,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Ubah Profile',
          style: AppTypography.bodySm.copyWith(
            color: isEditing ? AppColors.neutral08 : AppColors.primary08,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _ProfileIdentity extends StatelessWidget {
  const _ProfileIdentity();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 104,
                height: 104,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary02, width: 2),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/home/profile.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                right: 2,
                bottom: 2,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: AppColors.neutral03,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: AppIcon(
                      AppIcons.edit(),
                      color: AppColors.neutral08,
                      dimension: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            'Arunika Tas',
            style: AppTypography.headlineMd.copyWith(
              color: AppColors.neutral09,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({required this.children, required this.title});

  final List<Widget> children;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.bodyMd.copyWith(
            color: AppColors.primary05,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.system01,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }
}

class _ProfileTextField extends StatelessWidget {
  const _ProfileTextField({
    required this.label,
    required this.value,
    this.dropdown = false,
    this.obscureAction = false,
  });

  final bool dropdown;
  final String label;
  final bool obscureAction;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.bodyMd.copyWith(
            color: AppColors.neutral08,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.tertiary05,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.tertiary06),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A201B11),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.neutral08,
                  ),
                ),
              ),
              if (dropdown)
                AppIcon(
                  AppIcons.dropdown(),
                  color: AppColors.system06,
                  dimension: 16,
                ),
              if (obscureAction)
                AppIcon(
                  AppIcons.eye(),
                  color: AppColors.system05,
                  dimension: 18,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
