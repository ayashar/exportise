import 'package:flutter/material.dart';

import '../../core/api/api_client.dart';
import '../../core/api/api_repository.dart';
import '../../core/iconography/app_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/app_bottom_navigation.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_dropdown_field.dart';
import '../brains/brain_studio_page.dart';
import '../notifications/notification_page.dart';
import '../profile/profile_page.dart';
import '../reports/history_page.dart';
import 'analysis_result_page.dart';

class AnalysisInputPage extends StatefulWidget {
  const AnalysisInputPage({super.key});

  @override
  State<AnalysisInputPage> createState() => _AnalysisInputPageState();
}

class _AnalysisInputPageState extends State<AnalysisInputPage> {
  final _repository = ApiRepository();
  final _productNameController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _category;
  bool _isLoading = false;

  @override
  void dispose() {
    _productNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral01,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _AnalysisHeader(),
                  const SizedBox(height: 42),
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'Analisis Kesiapan Ekspor',
                          textAlign: TextAlign.center,
                          style: AppTypography.headlineLg.copyWith(
                            color: AppColors.neutral09,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Masukan nama produk Anda, kami akan membantu menganalisis tren pasar.',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodyMd.copyWith(
                            color: AppColors.neutral08,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 34),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(24, 26, 24, 24),
                    decoration: BoxDecoration(
                      color: AppColors.system01,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x127A5900),
                          blurRadius: 24,
                          offset: Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _FieldLabel('Nama produk'),
                        const SizedBox(height: 10),
                        _AppTextField(
                          controller: _productNameController,
                          hintText: 'e.g., tas anyaman',
                        ),
                        const SizedBox(height: 28),
                        const _FieldLabel('Kategori'),
                        const SizedBox(height: 10),
                        _CategoryDropdown(
                          value: _category,
                          onChanged: (value) {
                            setState(() => _category = value);
                          },
                        ),
                        const SizedBox(height: 28),
                        const _FieldLabel('Deskripsi Produk'),
                        const SizedBox(height: 10),
                        _AppTextField(
                          controller: _descriptionController,
                          hintText:
                              'Jelaskan singkat produk, material, dan target pasar.',
                          maxLines: 5,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                  AppButton(
                    label: 'Analisis Market',
                    isFullWidth: true,
                    isLoading: _isLoading,
                    size: AppButtonSize.lg,
                    onPressed: _isLoading ? null : () => _submit(context),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: AppBottomNavigation(
                selectedTab: AppTab.analysis,
                onTabSelected: (tab) {
                  if (tab == AppTab.home) {
                    Navigator.of(context).popUntil((route) => route.isFirst);
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

  Future<void> _submit(BuildContext context) async {
    final category = _category;
    if (category == null || category.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih kategori terlebih dahulu.')),
      );
      return;
    }

    if (_productNameController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama produk dan deskripsi wajib diisi.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final product = await _repository.createAnalysisProduct(
        category: _apiCategory(category),
        description: _descriptionController.text.trim(),
        productName: _productNameController.text.trim(),
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => AnalysisResultPage(analysProductId: product.id),
        ),
      );
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.message.isEmpty ? 'Analisis gagal dibuat' : error.message,
          ),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Analisis gagal dibuat. Coba lagi.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _apiCategory(String value) {
    return value.toLowerCase();
  }
}

class _AnalysisHeader extends StatelessWidget {
  const _AnalysisHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => _openProfile(context),
          child: const CircleAvatar(
            radius: 24,
            backgroundImage: AssetImage('assets/images/home/profile.png'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => _openProfile(context),
            child: Text(
              'Arunika Tas',
              style: AppTypography.headlineSm.copyWith(
                color: AppColors.neutral09,
              ),
            ),
          ),
        ),
        InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => _openNotifications(context),
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

void _openProfile(BuildContext context) {
  Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (context) => const ProfilePage()));
}

void _openNotifications(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (context) => const NotificationPage()),
  );
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTypography.bodyMd.copyWith(
        color: AppColors.neutral09,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _AppTextField extends StatelessWidget {
  const _AppTextField({
    required this.controller,
    required this.hintText,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String hintText;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: AppTypography.bodyMd.copyWith(color: AppColors.neutral09),
      decoration: _fieldDecoration(hintText),
    );
  }
}

class _CategoryDropdown extends StatelessWidget {
  const _CategoryDropdown({required this.onChanged, required this.value});

  final ValueChanged<String?> onChanged;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return AppDropdownField(
      hintText: 'Pilih Kategori',
      items: const ['Pakaian', 'Kerajinan Tangan'],
      onChanged: onChanged,
      textStyle: AppTypography.bodyMd.copyWith(color: AppColors.neutral09),
      value: value,
    );
  }
}

InputDecoration _fieldDecoration(String hintText) {
  return InputDecoration(
    hintText: hintText,
    hintStyle: AppTypography.bodyMd.copyWith(color: AppColors.system05),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    filled: true,
    fillColor: AppColors.tertiary05,
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.tertiary06),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.primary04),
    ),
  );
}
