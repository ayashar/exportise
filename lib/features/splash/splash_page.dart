import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../onboarding/onboarding_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoScale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );
    _logoOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.58, 0.82, curve: Curves.easeOut),
    );
    _logoScale = Tween<double>(begin: 0.16, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.58, 0.92, curve: Curves.easeOutBack),
      ),
    );

    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder<void>(
            transitionDuration: const Duration(milliseconds: 320),
            pageBuilder: (context, animation, secondaryAnimation) {
              return FadeTransition(
                opacity: animation,
                child: const OnboardingPage(),
              );
            },
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral01,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final progress = _controller.value;
          final size = MediaQuery.sizeOf(context);
          return Stack(
            fit: StackFit.expand,
            children: [
              const ColoredBox(color: AppColors.neutral01),
              Opacity(
                opacity: progress < 0.16
                    ? 1.0
                    : _clamp01(1 - _phase(progress, 0.16, 0.30)),
                child: const ColoredBox(color: AppColors.primary04),
              ),
              _SplashWaveAsset(
                assetPath: 'assets/images/splash/wave-large.svg',
                height: size.height,
                opacity: _fadeInOut(progress, 0.10, 0.20, 0.30, 0.42),
                top: _lerp(-18, 18, _phase(progress, 0.10, 0.42)),
                width: size.width,
              ),
              _SplashWaveAsset(
                assetPath: 'assets/images/splash/wave-medium.svg',
                height: size.height * 0.78,
                opacity: _fadeInOut(progress, 0.30, 0.40, 0.50, 0.64),
                top: _lerp(112, 236, _phase(progress, 0.30, 0.64)),
                width: size.width,
              ),
              _SplashWaveAsset(
                assetPath: 'assets/images/splash/wave-small.svg',
                height: size.height * 0.48,
                opacity: _fadeInOut(progress, 0.52, 0.60, 0.68, 0.78),
                top: _lerp(
                  size.height * 0.52,
                  size.height * 0.70,
                  _phase(progress, 0.52, 0.78),
                ),
                width: size.width * 0.86,
              ),
              Center(
                child: FadeTransition(
                  opacity: _logoOpacity,
                  child: ScaleTransition(
                    scale: _logoScale,
                    child: const _SplashLogo(),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SplashWaveAsset extends StatelessWidget {
  const _SplashWaveAsset({
    required this.assetPath,
    required this.height,
    required this.opacity,
    required this.top,
    required this.width,
  });

  final String assetPath;
  final double height;
  final double opacity;
  final double top;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      top: top,
      child: IgnorePointer(
        child: Opacity(
          opacity: _clamp01(opacity),
          child: SvgPicture.asset(
            assetPath,
            width: width,
            height: height,
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }
}

class _SplashLogo extends StatelessWidget {
  const _SplashLogo();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/images/logo/exportise-yellow.png',
          width: 132,
          height: 132,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 8),
        Text(
          'Exportise',
          style: AppTypography.headlineLg.copyWith(
            color: AppColors.primary04,
            fontSize: 30,
          ),
        ),
      ],
    );
  }
}

double _lerp(double begin, double end, double t) {
  return begin + (end - begin) * t;
}

double _phase(double value, double start, double end) {
  if (value <= start) {
    return 0;
  }
  if (value >= end) {
    return 1;
  }
  return Curves.easeInOutCubic.transform((value - start) / (end - start));
}

double _clamp01(double value) {
  return value.clamp(0.0, 1.0).toDouble();
}

double _fadeInOut(
  double value,
  double fadeInStart,
  double fadeInEnd,
  double fadeOutStart,
  double fadeOutEnd,
) {
  if (value < fadeInStart || value > fadeOutEnd) {
    return 0;
  }
  if (value <= fadeInEnd) {
    return _phase(value, fadeInStart, fadeInEnd);
  }
  if (value < fadeOutStart) {
    return 1;
  }
  return 1 - _phase(value, fadeOutStart, fadeOutEnd);
}
