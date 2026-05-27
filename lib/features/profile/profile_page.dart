import 'package:flutter/material.dart';

import '../../core/api/api_client.dart';
import '../../core/api/api_models.dart';
import '../../core/api/api_repository.dart';
import '../../core/iconography/app_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/app_bottom_navigation.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_dropdown_field.dart';
import '../analysis/analysis_input_page.dart';
import '../auth/login_page.dart';
import '../brains/brain_studio_page.dart';
import '../notifications/notification_page.dart';
import '../reports/history_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _repository = ApiRepository();
  late Future<ApiUser> _userFuture;

  bool _isEditing = false;
  bool _isLoggingOut = false;
  String _city = 'Sleman';
  String _district = 'Mlati';
  String _province = 'DI Yogyakarta';

  @override
  void initState() {
    super.initState();
    _userFuture = _repository.me();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral01,
      body: SafeArea(
        child: Stack(
          children: [
            FutureBuilder<ApiUser>(
              future: _userFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return _ProfileError(
                    message: _errorMessage(snapshot.error),
                    onRetry: _reload,
                  );
                }

                final user = snapshot.data;
                if (user == null) {
                  return _ProfileError(
                    message: 'Profil kosong.',
                    onRetry: _reload,
                  );
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 130),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ProfileHeader(user: user),
                      const SizedBox(height: 34),
                      Align(
                        alignment: Alignment.centerRight,
                        child: _EditProfileButton(
                          isEditing: _isEditing,
                          onTap: () => setState(() => _isEditing = true),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _ProfileIdentity(user: user),
                      const SizedBox(height: 34),
                      _ProfileSection(
                        title: 'Informasi Akun',
                        children: [
                          _ProfileTextField(
                            label: 'Nama Lengkap',
                            value: user.fullName,
                          ),
                          const SizedBox(height: 20),
                          _ProfileTextField(
                            label: 'Email Bisnis',
                            value: user.email,
                          ),
                          const SizedBox(height: 20),
                          _ProfileTextField(
                            label: 'Password',
                            value: '********',
                            obscureAction: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 36),
                      _ProfileSection(
                        title: 'Informasi UMKM',
                        children: [
                          _ProfileTextField(
                            label: 'Nama UMKM',
                            value: user.companyName,
                          ),
                          const SizedBox(height: 20),
                          _ProfileDropdownField(
                            label: 'Provinsi',
                            value: _province,
                            items: const [
                              'DI Yogyakarta',
                              'Jawa Timur',
                              'Sumatera Utara',
                              'Sulawesi Selatan',
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _province = value);
                              }
                            },
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: _ProfileDropdownField(
                                  label: 'Kota/Kabupaten',
                                  value: _city,
                                  items: const [
                                    'Sleman',
                                    'Bantul',
                                    'Yogyakarta',
                                    'Surabaya',
                                  ],
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() => _city = value);
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _ProfileDropdownField(
                                  label: 'Kecamatan',
                                  value: _district,
                                  items: const [
                                    'Mlati',
                                    'Berbah',
                                    'Depok',
                                    'Gamping',
                                  ],
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() => _district = value);
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _ProfileTextField(
                            label: 'Alamat Lengkap',
                            value: user.phone.isEmpty
                                ? 'Alamat belum tersedia'
                                : user.phone,
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
                                      content: Text(
                                        'Profil belum punya endpoint update, jadi perubahan hanya lokal.',
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 24),
                      AppButton(
                        label: 'Logout',
                        isFullWidth: true,
                        isLoading: _isLoggingOut,
                        variant: AppButtonVariant.danger,
                        onPressed: _isLoggingOut
                            ? null
                            : () => _logout(context),
                      ),
                    ],
                  ),
                );
              },
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

  Future<void> _reload() async {
    setState(() {
      _userFuture = _repository.me();
    });
  }

  Future<void> _logout(BuildContext context) async {
    setState(() => _isLoggingOut = true);

    try {
      await _repository.logout();
      if (!context.mounted) {
        return;
      }

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (context) => const LoginPage()),
        (route) => false,
      );
    } on ApiException catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message.isEmpty ? 'Logout gagal' : error.message),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoggingOut = false);
      }
    }
  }

  String _errorMessage(Object? error) {
    if (error is ApiException) {
      return error.message;
    }

    return 'Gagal memuat profil.';
  }
}

class _ProfileDropdownField extends StatelessWidget {
  const _ProfileDropdownField({
    required this.items,
    required this.label,
    required this.onChanged,
    required this.value,
  });

  final List<String> items;
  final String label;
  final ValueChanged<String?> onChanged;
  final String value;

  @override
  Widget build(BuildContext context) {
    return AppDropdownField(
      fillColor: AppColors.tertiary05,
      height: 44,
      hintText: label,
      itemHeight: 46,
      items: items,
      label: label,
      labelStyle: AppTypography.bodyMd.copyWith(
        color: AppColors.neutral08,
        fontWeight: FontWeight.w700,
      ),
      onChanged: onChanged,
      textStyle: AppTypography.bodySm.copyWith(color: AppColors.neutral08),
      value: value,
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user});

  final ApiUser user;

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
            user.companyName.isEmpty ? user.fullName : user.companyName,
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
  const _ProfileIdentity({required this.user});

  final ApiUser user;

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
            user.fullName,
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
          style: AppTypography.headlineSm.copyWith(color: AppColors.neutral09),
        ),
        const SizedBox(height: 18),
        Column(children: children),
      ],
    );
  }
}

class _ProfileTextField extends StatelessWidget {
  const _ProfileTextField({
    required this.label,
    required this.value,
    this.obscureAction = false,
  });

  final bool obscureAction;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.bodySm.copyWith(
            color: AppColors.neutral08,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.tertiary05,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.tertiary06),
          ),
          child: Text(
            obscureAction ? '********' : value,
            style: AppTypography.bodySm.copyWith(color: AppColors.neutral08),
          ),
        ),
      ],
    );
  }
}

class _ProfileError extends StatelessWidget {
  const _ProfileError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            AppButton(label: 'Coba lagi', onPressed: onRetry),
          ],
        ),
      ),
    );
  }
}
