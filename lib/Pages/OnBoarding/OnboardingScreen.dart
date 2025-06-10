import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _heartbeatController;
  late AnimationController _pulseController;
  late AnimationController _emergencyController;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      icon: Icons.security_outlined,
      title: "Emergency Response System",
      description:
          "Professional-grade emergency alert system trusted by safety experts. Get help when every second counts.",
      primaryColor: const Color(0xFFE53E3E),
      accentColor: const Color(0xFF1A202C),
      backgroundGradient: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFF7FAFC), Color(0xFFEDF2F7)],
      ),
      features: ["24/7 Monitoring", "Instant Alerts", "GPS Tracking"],
    ),
    OnboardingPage(
      icon: Icons.my_location_outlined,
      title: "Real-Time Location & Emergency Contacts",
      description:
          "Automatically shares your precise GPS coordinates with hospitals, police, and your trusted emergency contacts instantly.",
      primaryColor: const Color(0xFF3182CE),
      accentColor: const Color(0xFF1A202C),
      backgroundGradient: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFF7FAFC), Color(0xFFEBF8FF)],
      ),
      features: ["Live GPS", "Emergency Network", "Instant Dispatch"],
    ),
    OnboardingPage(
      icon: Icons.health_and_safety_outlined,
      title: "Smart Safety Features & Medical Data",
      description:
          "Background recording, fake calls, health information storage, and geo-fence protection for comprehensive safety.",
      primaryColor: const Color(0xFF38A169),
      accentColor: const Color(0xFF1A202C),
      backgroundGradient: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFF7FAFC), Color(0xFFF0FFF4)],
      ),
      features: ["Medical Info", "Smart Recording", "Geo-Fencing"],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _heartbeatController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
    _emergencyController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _heartbeatController.dispose();
    _pulseController.dispose();
    _emergencyController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background with gradient
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            decoration: BoxDecoration(
              gradient: _pages[_currentPage].backgroundGradient,
            ),
          ),

          // Emergency signals only on first page
          if (_currentPage == 0) _buildEmergencySignals(),

          SafeArea(
            child: Column(
              children: [
                // Header with logo and skip button
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Logo
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: _pages[_currentPage].primaryColor,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: _pages[_currentPage].primaryColor
                                      .withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.security,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "JeevanBandhu",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: _pages[_currentPage].accentColor,
                                ),
                              ),
                              Text(
                                "Emergency System",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.3),

                      // Skip button
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: Colors.grey[300]!),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        child: Text(
                          "Skip Setup",
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ).animate().fadeIn(delay: 300.ms).slideX(begin: 1),
                    ],
                  ),
                ),

                // Main content area
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _pages.length,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    itemBuilder: (context, index) {
                      return OnboardingPageWidget(
                        page: _pages[index],
                        heartbeatController: _heartbeatController,
                        emergencyController: _emergencyController,
                        isActive: index == _currentPage,
                      );
                    },
                  ),
                ),

                // Page indicators
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    children: [
                      Text(
                        "${_currentPage + 1} of ${_pages.length}",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _pages.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: _currentPage == index ? 24 : 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color:
                                  _currentPage == index
                                      ? _pages[_currentPage].primaryColor
                                      : Colors.grey[300],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Navigation buttons
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Column(
                    children: [
                      // Main action button
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _pages[_currentPage].primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                            shadowColor: _pages[_currentPage].primaryColor
                                .withOpacity(0.3),
                          ),
                          onPressed: () {
                            if (_currentPage < _pages.length - 1) {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeInOut,
                              );
                            } else {
                              Navigator.pushReplacementNamed(context, '/login');
                            }
                          },
                          child: Text(
                            _currentPage == _pages.length - 1
                                ? "Get Started"
                                : "Continue",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      // Previous button conditionally shown
                      if (_currentPage > 0) ...[
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: Text(
                            "Previous",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencySignals() {
    return AnimatedBuilder(
      animation: _emergencyController,
      builder: (context, child) {
        return Stack(
          children: List.generate(3, (index) {
            final double angle =
                (_emergencyController.value * 2 * math.pi) +
                (index * 2 * math.pi / 3);
            final double radius =
                200 + (math.sin(_emergencyController.value * math.pi) * 50);

            return Positioned(
              left:
                  MediaQuery.of(context).size.width / 2 +
                  math.cos(angle) * radius -
                  2,
              top:
                  MediaQuery.of(context).size.height / 2 +
                  math.sin(angle) * radius -
                  2,
              child: Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE53E3E).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

class OnboardingPage {
  final IconData icon;
  final String title;
  final String description;
  final Color primaryColor;
  final Color accentColor;
  final LinearGradient backgroundGradient;
  final List<String> features;

  OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.primaryColor,
    required this.accentColor,
    required this.backgroundGradient,
    required this.features,
  });
}

class OnboardingPageWidget extends StatelessWidget {
  final OnboardingPage page;
  final AnimationController heartbeatController;
  final AnimationController emergencyController;
  final bool isActive;

  const OnboardingPageWidget({
    Key? key,
    required this.page,
    required this.heartbeatController,
    required this.emergencyController,
    required this.isActive,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),

            // Animated icon
            AnimatedBuilder(
                  animation: heartbeatController,
                  builder: (context, child) {
                    final pulseValue =
                        (math.sin(heartbeatController.value * 2 * math.pi) *
                            0.1) +
                        1.0;
                    return Transform.scale(
                      scale: pulseValue,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: page.primaryColor.withOpacity(0.2),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: page.primaryColor.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: page.primaryColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                            ),
                            Icon(page.icon, size: 40, color: page.primaryColor),
                          ],
                        ),
                      ),
                    );
                  },
                )
                .animate()
                .fadeIn(duration: 800.ms)
                .scale(begin: const Offset(0.5, 0.5)),

            const SizedBox(height: 32),

            // Title
            Text(
                  page.title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: page.accentColor,
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                )
                .animate()
                .fadeIn(duration: 600.ms, delay: 200.ms)
                .slideY(begin: 0.3),

            const SizedBox(height: 16),

            // Description
            Text(
                  page.description,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                )
                .animate()
                .fadeIn(duration: 600.ms, delay: 400.ms)
                .slideY(begin: 0.2),

            const SizedBox(height: 32),

            // Features
            Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[200]!),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children:
                        page.features.map((feature) {
                          return _buildFeatureItem(feature, page.primaryColor);
                        }).toList(),
                  ),
                )
                .animate()
                .fadeIn(duration: 600.ms, delay: 600.ms)
                .slideY(begin: 0.3),

            const SizedBox(height: 24),

            // Trust indicator
            if (isActive)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.verified_user, size: 16, color: Colors.grey[500]),
                  const SizedBox(width: 8),
                  Text(
                    "Trusted by Emergency Services",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 400.ms, delay: 1000.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String feature, Color color) {
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: color.withOpacity(0.2), width: 1),
              ),
              child: Icon(Icons.check, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              feature,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
