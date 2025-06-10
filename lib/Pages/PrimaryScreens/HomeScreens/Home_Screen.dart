import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'dart:async';
import '../../../services/emergency_service.dart'; // Import the emergency service

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _floatingController;
  late AnimationController _breathingController;
  bool _panicMode = false;
  bool _isPressed = false;
  bool _sendingAlert = false;
  int _pressDuration = 0;
  late Timer _pressTimer;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _floatingController.dispose();
    _breathingController.dispose();
    super.dispose();
  }

  void _startPressTimer() {
    _pressTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        _pressDuration += 100;
        if (_pressDuration >= 2000) {
          _triggerEmergency();
          timer.cancel();
        }
      });
    });
  }

  void _triggerEmergency() async {
    HapticFeedback.heavyImpact();
    setState(() {
      _panicMode = true;
      _sendingAlert = true;
    });
    
    // Show emergency dialog
    _showEmergencyDialog();
    
    // Send emergency SMS
    try {
      bool success = await EmergencyService.sendEmergencyAlert();
      
      setState(() {
        _sendingAlert = false;
      });
      
      if (success) {
        _showSuccessSnackBar();
      } else {
        _showErrorSnackBar();
      }
    } catch (e) {
      setState(() {
        _sendingAlert = false;
      });
      _showErrorSnackBar();
      print('Emergency alert failed: $e');
    }
  }

  void _showEmergencyDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Colors.red.shade50,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Iconsax.warning_2, size: 80, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Emergency Alert Activated!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade800,
              ),
            ),
            const SizedBox(height: 8),
            if (_sendingAlert)
              Column(
                children: [
                  CircularProgressIndicator(color: Colors.red),
                  const SizedBox(height: 8),
                  Text(
                    'Sending SMS to emergency contacts...',
                    style: TextStyle(color: Colors.red.shade600),
                    textAlign: TextAlign.center,
                  ),
                ],
              )
            else
              Text(
                'Emergency SMS sent to your contacts.',
                style: TextStyle(color: Colors.red.shade600),
                textAlign: TextAlign.center,
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _sendingAlert ? null : () {
              Navigator.pop(context);
              setState(() => _panicMode = false);
            },
            child: Text(_sendingAlert ? 'Sending...' : 'Cancel'),
          ),
          if (!_sendingAlert)
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                // Call emergency services
                await EmergencyService.makeEmergencyCall('112');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Call 112'),
            ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text('Emergency SMS sent successfully!'),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Text('Failed to send emergency SMS. Please try again.'),
          ],
        ),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: () => _triggerEmergency(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF0F1419),
                    const Color(0xFF1A202C),
                    const Color(0xFF2D3748),
                  ]
                : [
                    const Color(0xFFF8FAFC),
                    const Color(0xFFE2E8F0),
                    const Color(0xFFCBD5E0),
                  ],
          ),
        ),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Enhanced Collapsing App Bar (keeping it minimal for space)
            SliverAppBar(
              expandedHeight: 120,
              collapsedHeight: 60,
              floating: false,
              pinned: true,
              snap: false,
              elevation: 0,
              backgroundColor: Colors.transparent,
              automaticallyImplyLeading: false,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  "Emergency App",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                centerTitle: true,
              ),
            ),

            // Main Content
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 20),

                  // Enhanced Panic Button Section
                  _buildEnhancedPanicSection(theme, isDark, size),

                  const SizedBox(height: 32),

                  // Emergency Contacts Status
                  _buildEmergencyContactsStatus(theme, isDark),

                  const SizedBox(height: 24),

                  // Quick Emergency Actions
                  _buildQuickEmergencyActions(theme, isDark),

                  const SizedBox(height: 32),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedPanicSection(ThemeData theme, bool isDark, Size size) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.grey.shade900.withOpacity(0.5)
            : Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "Emergency Response",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Hold the button for 2 seconds to send SMS alerts",
            style: TextStyle(
              color: isDark ? Colors.white60 : Colors.black54,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Enhanced Panic Button
          GestureDetector(
            onTapDown: (_) {
              HapticFeedback.mediumImpact();
              setState(() => _isPressed = true);
              _startPressTimer();
            },
            onTapUp: (_) {
              _pressTimer.cancel();
              setState(() {
                _isPressed = false;
                _pressDuration = 0;
              });
            },
            onTapCancel: () {
              _pressTimer.cancel();
              setState(() {
                _isPressed = false;
                _pressDuration = 0;
              });
            },
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Container(
                  width: _isPressed ? 140 : 160,
                  height: _isPressed ? 140 : 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFFF6B6B),
                        const Color(0xFFE53E3E),
                        const Color(0xFFDB2777),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE53E3E)
                            .withOpacity(_pulseController.value * 0.6),
                        blurRadius: _isPressed ? 30 : 50,
                        spreadRadius: _isPressed ? 5 : 15,
                      ),
                      BoxShadow(
                        color: Colors.red.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      _sendingAlert ? Iconsax.info_circle : Iconsax.warning_2,
                      size: _isPressed ? 50 : 60,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // Progress indicator when pressed
          if (_isPressed) ...[
            LinearProgressIndicator(
              value: _pressDuration / 2000,
              backgroundColor: Colors.grey.shade300,
              color: Colors.red,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 12),
          ],

          Text(
            _sendingAlert
                ? "Sending SMS..."
                : _isPressed
                    ? "Activating in ${(2000 - _pressDuration) ~/ 1000 + 1}s..."
                    : "EMERGENCY",
            style: TextStyle(
              fontSize: _isPressed ? 16 : 18,
              fontWeight: FontWeight.w700,
              color: _isPressed || _sendingAlert
                  ? Colors.red
                  : (isDark ? Colors.white : Colors.black87),
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyContactsStatus(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.grey.shade900.withOpacity(0.5)
            : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Emergency Contacts",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildContactStatus("SMS Contacts", "4 Configured", Colors.green, isDark),
              ),
              Expanded(
                child: _buildContactStatus("Location", "Enabled", Colors.blue, isDark),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactStatus(String title, String status, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            status,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 14,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: isDark ? Colors.white60 : Colors.black54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickEmergencyActions(ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Quick Actions",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionButton("Call 112", Iconsax.call, Colors.red, () {
                EmergencyService.makeEmergencyCall('112');
              }),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionButton("Test SMS", Iconsax.message, Colors.blue, () async {
                await EmergencyService.sendEmergencyAlert(
                  customMessage: "🧪 This is a test message from your emergency app. Please ignore.",
                );
              }),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(label, style: TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}