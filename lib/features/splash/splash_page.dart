import 'package:flutter/material.dart';

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
          return Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(
                painter: _SplashWavePainter(progress: _controller.value),
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

class _SplashWavePainter extends CustomPainter {
  const _SplashWavePainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.primary04;

    if (progress <= 0.12) {
      canvas.drawRect(Offset.zero & size, paint);
      return;
    }

    final t = ((progress - 0.12) / 0.56).clamp(0.0, 1.0);
    final eased = Curves.easeInOutCubic.transform(t);
    final radius = _lerp(size.longestSide * 1.08, size.width * 0.72, eased);
    final center = Offset(
      _lerp(size.width * 0.34, -size.width * 0.26, eased),
      _lerp(size.height * 0.30, size.height * 0.98, eased),
    );

    final path = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius))
      ..addOval(
        Rect.fromCircle(
          center: Offset(center.dx + radius * 0.52, center.dy - radius * 0.10),
          radius: radius * 0.66,
        ),
      );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SplashWavePainter oldDelegate) {
    return oldDelegate.progress != progress;
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
