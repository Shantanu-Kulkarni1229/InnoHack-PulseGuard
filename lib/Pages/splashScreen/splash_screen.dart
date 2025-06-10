import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math' as math;

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _trustController;
  late AnimationController _textController;
  late AnimationController _progressController;
  late AnimationController _shieldController;
  late AnimationController _heartbeatController;

  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoFadeAnimation;
  late Animation<Offset> _logoSlideAnimation;
  late Animation<double> _textStaggerAnimation;
  late Animation<Color?> _gradientAnimation1;
  late Animation<Color?> _gradientAnimation2;
  late Animation<double> _progressAnimation;
  late Animation<double> _shieldGlowAnimation;
  late Animation<double> _heartbeatAnimation;
  late Animation<double> _trustIndicatorAnimation;

  final List<TrustWave> _trustWaves = [];
  Timer? _navigationTimer;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();

    // Set system UI overlay style for professional theme
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    _initializeAnimations();
    _initializeTrustWaves();
    _startAnimationSequence();
  }

  void _initializeAnimations() {
    // Main animation controller (3.5 seconds)
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    );

    // Trust/security pulse controller
    _trustController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    // Text animation controller
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    // Progress animation controller
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    );

    // Shield protection controller
    _shieldController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    // Heartbeat controller for life monitoring
    _heartbeatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    // Logo animations with professional theme
    _logoScaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
      ),
    );

    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _logoSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    // Text stagger animation
    _textStaggerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
    );

    // Professional gradient animations (blue/white theme for trust)
    _gradientAnimation1 = ColorTween(
      begin: const Color(0xFF0a1628),
      end: const Color(0xFF1e3a5f),
    ).animate(_mainController);

    _gradientAnimation2 = ColorTween(
      begin: const Color(0xFF2e5984),
      end: const Color(0xFF4a90e2),
    ).animate(_mainController);

    // Progress animation
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    // Shield glow animation for security
    _shieldGlowAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _shieldController, curve: Curves.easeInOut),
    );

    // Heartbeat animation for life monitoring
    _heartbeatAnimation = Tween<double>(begin: 0.8, end: 1.1).animate(
      CurvedAnimation(parent: _heartbeatController, curve: Curves.easeInOut),
    );

    // Trust indicator animation
    _trustIndicatorAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _trustController, curve: Curves.easeInOut),
    );
  }

  void _initializeTrustWaves() {
    for (int i = 0; i < 3; i++) {
      _trustWaves.add(
        TrustWave(
          delay: i * 0.4,
          maxRadius: 120.0 + (i * 25),
          color: i % 2 == 0 ? const Color(0xFF4a90e2) : const Color(0xFF64b5f6),
        ),
      );
    }
  }

  void _startAnimationSequence() {
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      // Start main animation
      _mainController.forward();

      // Start progress animation with slight delay
      await Future.delayed(const Duration(milliseconds: 300));
      _progressController.forward();

      // Start text animations with stagger
      await Future.delayed(const Duration(milliseconds: 600));
      _textController.forward();

      // Navigate after completion
      _navigationTimer = Timer(const Duration(milliseconds: 5000), () {
        if (!_isNavigating && mounted) {
          _navigateToNext();
        }
      });
    });
  }

  void _navigateToNext() {
    if (_isNavigating) return;
    _isNavigating = true;

    // Add exit animation
    _mainController.reverse().then((_) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/onboarding');
      }
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _mainController.dispose();
    _trustController.dispose();
    _textController.dispose();
    _progressController.dispose();
    _shieldController.dispose();
    _heartbeatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: GestureDetector(
        onTap: () => _navigateToNext(),
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _mainController,
            _trustController,
            _textController,
            _progressController,
            _shieldController,
            _heartbeatController,
          ]),
          builder: (context, child) {
            return Container(
              width: size.width,
              height: size.height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _gradientAnimation1.value ?? const Color(0xFF0a1628),
                    _gradientAnimation2.value ?? const Color(0xFF2e5984),
                    const Color(0xFF1a2332),
                  ],
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
              child: Stack(
                children: [
                  // Professional trust waves
                  Positioned.fill(
                    child: CustomPaint(
                      painter: TrustWavesPainter(
                        waves: _trustWaves,
                        animationValue: _trustController.value,
                      ),
                    ),
                  ),

                  // Shield protection indicator
                  Positioned.fill(
                    child: CustomPaint(
                      painter: ShieldProtectionPainter(
                        progress: _shieldController.value,
                        glowIntensity: _shieldGlowAnimation.value,
                      ),
                    ),
                  ),

                  // Main content
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Professional Logo section
                        SlideTransition(
                          position: _logoSlideAnimation,
                          child: ScaleTransition(
                            scale: _logoScaleAnimation,
                            child: FadeTransition(
                              opacity: _logoFadeAnimation,
                              child: const ProfessionalLogo(),
                            ),
                          ),
                        ),

                        SizedBox(height: 45 * _textStaggerAnimation.value),

                        // App name with professional styling
                        _buildAnimatedText(
                          'JeevanBandhu',
                          fontSize: 48,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 2.0,
                          delay: 0.0,
                          glowColor: const Color(0xFF4a90e2),
                        ),

                        const SizedBox(height: 12),

                        // Professional tagline
                        _buildAnimatedText(
                          'TRUSTED EMERGENCY RESPONSE',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF64b5f6),
                          letterSpacing: 2.0,
                          delay: 0.15,
                        ),

                        const SizedBox(height: 20),

                        // Professional service features
                        _buildServiceFeatureRow(),

                        const SizedBox(height: 35),

                        // Trust message
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: _buildAnimatedText(
                            'Certified Emergency Response • GPS Location • Medical Alert\nProfessional Support • Instant Response • 24/7 Monitoring',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white70,
                            letterSpacing: 0.5,
                            delay: 0.4,
                            textAlign: TextAlign.center,
                          ),
                        ),

                        const SizedBox(height: 50),

                        // Professional loading indicator
                        _buildProfessionalLoadingIndicator(),

                        const SizedBox(height: 25),

                        // Status text
                        _buildAnimatedText(
                          'Connecting to Emergency Network...',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          delay: 0.6,
                          letterSpacing: 1.0,
                        ),

                        const SizedBox(height: 8),

                        // System status
                        _buildAnimatedText(
                          'Verifying Emergency Response System',
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: Colors.white60,
                          delay: 0.7,
                        ),
                      ],
                    ),
                  ),

                  // Trust indicator
                  if (_textStaggerAnimation.value > 0.3)
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 15,
                      left: 20,
                      child: FadeTransition(
                        opacity: Tween<double>(begin: 0.0, end: 0.9).animate(
                          CurvedAnimation(
                            parent: _textController,
                            curve: const Interval(0.3, 1.0),
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4a90e2).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF4a90e2).withOpacity(0.5),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Transform.scale(
                                scale: _heartbeatAnimation.value,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4CAF50),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF4CAF50,
                                        ).withOpacity(0.6),
                                        blurRadius: 4,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'SECURE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Skip button
                  if (_textStaggerAnimation.value > 0.5)
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 20,
                      right: 20,
                      child: FadeTransition(
                        opacity: Tween<double>(begin: 0.0, end: 0.7).animate(
                          CurvedAnimation(
                            parent: _textController,
                            curve: const Interval(0.5, 1.0),
                          ),
                        ),
                        child: TextButton(
                          onPressed: _navigateToNext,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white60,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                          child: const Text(
                            'Skip',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildServiceFeatureRow() {
    return AnimatedBuilder(
      animation: _textController,
      builder: (context, child) {
        final progress = math.max(
          0.0,
          math.min(1.0, (_textStaggerAnimation.value - 0.25) / 0.3),
        );

        return Transform.translate(
          offset: Offset(0, 20 * (1 - progress)),
          child: Opacity(
            opacity: progress,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildServiceIcon(
                  Icons.verified_user,
                  "SECURE",
                  const Color(0xFF4CAF50),
                ),
                const SizedBox(width: 40),
                _buildServiceIcon(
                  Icons.medical_services,
                  "MEDICAL",
                  const Color(0xFF2196F3),
                ),
                const SizedBox(width: 40),
                _buildServiceIcon(
                  Icons.support_agent,
                  "SUPPORT",
                  const Color(0xFF64b5f6),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildServiceIcon(IconData icon, String label, Color iconColor) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: iconColor.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: iconColor.withOpacity(0.2),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedText(
    String text, {
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
    double letterSpacing = 0.0,
    required double delay,
    TextAlign textAlign = TextAlign.center,
    Color? glowColor,
  }) {
    return AnimatedBuilder(
      animation: _textController,
      builder: (context, child) {
        final progress = math.max(
          0.0,
          math.min(1.0, (_textStaggerAnimation.value - delay) / 0.3),
        );

        return Transform.translate(
          offset: Offset(0, 30 * (1 - progress)),
          child: Opacity(
            opacity: progress,
            child: Text(
              text,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: fontWeight,
                color: color,
                letterSpacing: letterSpacing,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.3),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                  if (glowColor != null)
                    Shadow(
                      color: glowColor.withOpacity(0.3),
                      offset: const Offset(0, 0),
                      blurRadius: 15,
                    ),
                ],
              ),
              textAlign: textAlign,
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfessionalLoadingIndicator() {
    return AnimatedBuilder(
      animation: _progressController,
      builder: (context, child) {
        final progress = _progressAnimation.value;

        return Column(
          children: [
            Container(
              width: 220,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(3),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Stack(
                children: [
                  Container(
                    width: 220 * progress,
                    height: 6,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF4a90e2),
                          Color(0xFF64b5f6),
                          Color(0xFF4a90e2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(3),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4a90e2).withOpacity(0.4),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            Text(
              '${(progress * 100).toInt()}%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
              ),
            ),
          ],
        );
      },
    );
  }
}

// Professional emergency logo widget
class ProfessionalLogo extends StatefulWidget {
  const ProfessionalLogo({Key? key}) : super(key: key);

  @override
  _ProfessionalLogoState createState() => _ProfessionalLogoState();
}

class _ProfessionalLogoState extends State<ProfessionalLogo>
    with TickerProviderStateMixin {
  late AnimationController _shieldController;
  late AnimationController _heartController;
  late Animation<double> _shieldAnimation;
  late Animation<double> _heartAnimation;

  @override
  void initState() {
    super.initState();

    _shieldController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();

    _shieldAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _shieldController, curve: Curves.easeInOut),
    );

    _heartAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _heartController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _shieldController.dispose();
    _heartController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_shieldController, _heartController]),
      builder: (context, child) {
        return Transform.scale(
          scale: _shieldAnimation.value,
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF4a90e2).withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4a90e2).withOpacity(0.3),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
                BoxShadow(
                  color: const Color(0xFF64b5f6).withOpacity(0.2),
                  blurRadius: 50,
                  spreadRadius: 20,
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF4a90e2),
                      Color(0xFF64b5f6),
                      Color(0xFF2196F3),
                    ],
                  ),
                ),
                child: Center(
                  child: Transform.scale(
                    scale: _heartAnimation.value,
                    child: CustomPaint(
                      size: const Size(70, 70),
                      painter: ProfessionalIconPainter(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Trust wave class
class TrustWave {
  final double delay;
  final double maxRadius;
  final Color color;

  TrustWave({
    required this.delay,
    required this.maxRadius,
    required this.color,
  });
}

// Custom painters for professional theme
class TrustWavesPainter extends CustomPainter {
  final List<TrustWave> waves;
  final double animationValue;

  TrustWavesPainter({required this.waves, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    for (var wave in waves) {
      final adjustedProgress = math.max(
        0.0,
        (animationValue - wave.delay) % 1.0,
      );
      final radius = wave.maxRadius * adjustedProgress;
      final opacity = (1.0 - adjustedProgress) * 0.2;

      if (opacity > 0 && radius > 0) {
        final paint =
            Paint()
              ..color = wave.color.withOpacity(opacity)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2.0;

        canvas.drawCircle(center, radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant TrustWavesPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}

class ShieldProtectionPainter extends CustomPainter {
  final double progress;
  final double glowIntensity;

  ShieldProtectionPainter({
    required this.progress,
    required this.glowIntensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.35;

    // Draw protection field
    final protectionAngle = progress * 2 * math.pi;
    final gradient = SweepGradient(
      startAngle: protectionAngle - 1.0,
      endAngle: protectionAngle,
      colors: [
        Colors.transparent,
        const Color(0xFF4a90e2).withOpacity(0.05 * glowIntensity),
        const Color(0xFF4a90e2).withOpacity(0.15 * glowIntensity),
      ],
    );

    final paint =
        Paint()
          ..shader = gradient.createShader(
            Rect.fromCircle(center: center, radius: radius),
          );

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant ShieldProtectionPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.glowIntensity != glowIntensity;
}

class ProfessionalIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;

    final strokePaint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0
          ..strokeCap = StrokeCap.round;

    // Draw professional shield
    final shieldPath =
        Path()
          ..moveTo(size.width / 2, size.height * 0.1)
          ..quadraticBezierTo(
            size.width * 0.8,
            size.height * 0.1,
            size.width * 0.8,
            size.height * 0.4,
          )
          ..quadraticBezierTo(
            size.width * 0.8,
            size.height * 0.7,
            size.width / 2,
            size.height * 0.9,
          )
          ..quadraticBezierTo(
            size.width * 0.2,
            size.height * 0.7,
            size.width * 0.2,
            size.height * 0.4,
          )
          ..quadraticBezierTo(
            size.width * 0.2,
            size.height * 0.1,
            size.width / 2,
            size.height * 0.1,
          );

    canvas.drawPath(shieldPath, paint);

    // Draw medical cross inside shield
    strokePaint.color = const Color(0xFF4a90e2);
    strokePaint.strokeWidth = 4.0;

    // Vertical line of cross
    canvas.drawLine(
      Offset(size.width / 2, size.height * 0.3),
      Offset(size.width / 2, size.height * 0.7),
      strokePaint,
    );

    // Horizontal line of cross
    canvas.drawLine(
      Offset(size.width * 0.35, size.height / 2),
      Offset(size.width * 0.65, size.height / 2),
      strokePaint,
    );

    // Draw heartbeat line around shield
    strokePaint.color = const Color(0xFF4CAF50);
    strokePaint.strokeWidth = 2.5;

    final heartbeatPath = Path();
    final centerY = size.height * 0.25;

    heartbeatPath.moveTo(size.width * 0.15, centerY);
    heartbeatPath.lineTo(size.width * 0.25, centerY);
    heartbeatPath.lineTo(size.width * 0.3, centerY - 15);
    heartbeatPath.lineTo(size.width * 0.35, centerY + 15);
    heartbeatPath.lineTo(size.width * 0.4, centerY - 10);
    heartbeatPath.lineTo(size.width * 0.45, centerY);
    heartbeatPath.lineTo(size.width * 0.85, centerY);

    canvas.drawPath(heartbeatPath, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
