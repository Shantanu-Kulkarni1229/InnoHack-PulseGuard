import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  bool _darkMode = false;
  bool _notificationsEnabled = true;
  bool _locationEnabled = true;
  double _sensitivity = 0.7;
  String _defaultEmergencyType = 'Medical';
  bool _isLoggedIn = true;
  late AnimationController _animationController;

  final List<String> _emergencyTypes = ['Medical', 'Police', 'Fire', 'Other'];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FadeTransition(
        opacity: _animationController,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Section with enhanced design
              _buildProfileSection(context),

              const SizedBox(height: 8),

              // App Preferences
              _buildSection(context, 'App Preferences', Icons.tune, [
                _buildEnhancedSettingSwitch(
                  context,
                  icon: Icons.notifications_outlined,
                  activeIcon: Icons.notifications,
                  title: 'Push Notifications',
                  subtitle: 'Receive emergency alerts and updates',
                  value: _notificationsEnabled,
                  onChanged: (v) => setState(() => _notificationsEnabled = v),
                ),
                _buildEnhancedSettingSwitch(
                  context,
                  icon: Icons.dark_mode_outlined,
                  activeIcon: Icons.dark_mode,
                  title: 'Dark Mode',
                  subtitle: 'Easy on the eyes in low light',
                  value: _darkMode,
                  onChanged: (v) => setState(() => _darkMode = v),
                ),
                _buildEnhancedSettingSwitch(
                  context,
                  icon: Icons.location_on_outlined,
                  activeIcon: Icons.location_on,
                  title: 'Location Services',
                  subtitle: 'Allow location access for emergency services',
                  value: _locationEnabled,
                  onChanged: (v) => setState(() => _locationEnabled = v),
                ),
                _buildSensitivitySetting(context),
                _buildEmergencyTypeSetting(context),
              ]),

              // Privacy & Security
              _buildSection(context, 'Privacy & Security', Icons.security, [
                _buildEnhancedSettingButton(
                  context,
                  icon: Icons.lock_outline,
                  title: 'Change Security PIN',
                  subtitle: 'Update your emergency access PIN',
                  onTap: () => _showComingSoonSnackBar('PIN change'),
                ),
                _buildEnhancedSettingButton(
                  context,
                  icon: Icons.data_usage_outlined,
                  title: 'Data & Privacy',
                  subtitle: 'Manage what data is shared',
                  onTap: () => _showComingSoonSnackBar('Data management'),
                ),
                _buildEnhancedSettingButton(
                  context,
                  icon: Icons.delete_outline,
                  title: 'Clear Emergency Data',
                  subtitle: 'Remove all stored emergency information',
                  isDestructive: true,
                  onTap: () => _showClearDataDialog(),
                ),
              ]),

              // Help & Support
              _buildSection(context, 'Help & Support', Icons.help_outline, [
                _buildEnhancedSettingButton(
                  context,
                  icon: Icons.quiz_outlined,
                  title: 'How PulseGuard Works',
                  subtitle: 'Learn about emergency features',
                  onTap: () => _showComingSoonSnackBar('Tutorial'),
                ),
                _buildEnhancedSettingButton(
                  context,
                  icon: Icons.safety_check_outlined,
                  title: 'Safety Guidelines',
                  subtitle: 'Important safety information',
                  onTap: () => _showComingSoonSnackBar('Safety guide'),
                ),
                _buildEnhancedSettingButton(
                  context,
                  icon: Icons.support_agent_outlined,
                  title: 'Contact Support',
                  subtitle: 'Get help from our team',
                  onTap: _launchSupportEmail,
                ),
              ]),

              // Legal & About
              _buildSection(context, 'Legal & About', Icons.info_outline, [
                _buildEnhancedSettingButton(
                  context,
                  icon: Icons.description_outlined,
                  title: 'Terms of Service',
                  subtitle: 'Legal terms and conditions',
                  onTap: () => _showComingSoonSnackBar('Terms of Service'),
                ),
                _buildEnhancedSettingButton(
                  context,
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  subtitle: 'How we protect your privacy',
                  onTap: () => _showComingSoonSnackBar('Privacy Policy'),
                ),
                _buildEnhancedSettingButton(
                  context,
                  icon: Icons.code_outlined,
                  title: 'Open Source Licenses',
                  subtitle: 'Third-party software licenses',
                  onTap: () => _showComingSoonSnackBar('Licenses'),
                ),
                _buildEnhancedSettingButton(
                  context,
                  icon: Icons.people_outline,
                  title: 'About PulseGuard',
                  subtitle: 'Meet the team behind the app',
                  onTap: () => _showAboutDialog(),
                ),
              ]),

              // Account Actions
              _buildSection(context, 'Account', Icons.account_circle_outlined, [
                if (_isLoggedIn)
                  _buildEnhancedSettingButton(
                    context,
                    icon: Icons.logout_outlined,
                    title: 'Sign Out',
                    subtitle: 'Sign out of your account',
                    isDestructive: true,
                    onTap: () => _showLogoutDialog(),
                  ),
                _buildEnhancedSettingButton(
                  context,
                  icon: Icons.exit_to_app_outlined,
                  title: 'Exit App',
                  subtitle: 'Close PulseGuard completely',
                  isDestructive: true,
                  onTap: () => _showExitDialog(),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer,
            colorScheme.primaryContainer.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: colorScheme.onPrimaryContainer.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: CircleAvatar(
                radius: 35,
                backgroundColor: colorScheme.primary,
                child: Icon(
                  Icons.person,
                  size: 35,
                  color: colorScheme.onPrimary,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Shantanu Kulkarni',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'shantanukulkarni1229@gmail.com',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onPrimaryContainer.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Premium Member',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: colorScheme.onPrimaryContainer.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.edit_outlined,
                  color: colorScheme.onPrimaryContainer,
                ),
                onPressed: () => _showComingSoonSnackBar('Profile editing'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
          child: Row(
            children: [
              Icon(icon, size: 20, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: children),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildEnhancedSettingSwitch(
    BuildContext context, {
    required IconData icon,
    required IconData activeIcon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: Icon(
          value ? activeIcon : icon,
          key: ValueKey(value),
          color: value ? colorScheme.primary : colorScheme.onSurfaceVariant,
        ),
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: colorScheme.primary,
      ),
    );
  }

  Widget _buildEnhancedSettingButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final color =
        isDestructive ? colorScheme.error : colorScheme.onSurfaceVariant;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: isDestructive ? colorScheme.error : null,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color:
              isDestructive
                  ? colorScheme.error.withOpacity(0.7)
                  : colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: color.withOpacity(0.5)),
      onTap: onTap,
    );
  }

  Widget _buildSensitivitySetting(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.touch_app_outlined,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Button Sensitivity',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'How sensitive the emergency button should be',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _getSensitivityLabel(_sensitivity),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: colorScheme.primary,
              inactiveTrackColor: colorScheme.surfaceContainerHighest,
              thumbColor: colorScheme.primary,
              overlayColor: colorScheme.primary.withOpacity(0.1),
              valueIndicatorColor: colorScheme.primary,
              trackHeight: 4,
            ),
            child: Slider(
              value: _sensitivity,
              onChanged: (v) => setState(() => _sensitivity = v),
              divisions: 4,
              label: _getSensitivityLabel(_sensitivity),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyTypeSetting(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Icon(
        Icons.emergency_outlined,
        color: colorScheme.onSurfaceVariant,
      ),
      title: Text(
        'Default Emergency Type',
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        'Primary emergency service to contact',
        style: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButton<String>(
          value: _defaultEmergencyType,
          underline: const SizedBox(),
          isDense: true,
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: colorScheme.onSurfaceVariant,
          ),
          items:
              _emergencyTypes.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
          onChanged: (v) {
            if (v != null) {
              setState(() => _defaultEmergencyType = v);
            }
          },
        ),
      ),
    );
  }

  String _getSensitivityLabel(double value) {
    if (value <= 0.25) return 'Very Low';
    if (value <= 0.5) return 'Low';
    if (value <= 0.75) return 'Medium';
    return 'High';
  }

  void _showComingSoonSnackBar(String feature) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$feature coming soon!'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.favorite,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                const Text('About PulseGuard'),
              ],
            ),
            content: const Text(
              'PulseGuard is designed to keep you safe in emergency situations. Our dedicated team works around the clock to ensure your safety and peace of mind.\n\nVersion 1.0.0\nMade with ❤️ for your safety',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  Future<void> _launchSupportEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'support@pulseguard.com',
      queryParameters: {
        'subject': 'PulseGuard Support Request',
        'body':
            'Hi PulseGuard team,\n\nI need help with:\n\n[Please describe your issue here]\n\nApp Version: 1.0.0\nDevice: ${Platform.operatingSystem}\n\nThank you!',
      },
    );

    try {
      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri);
      } else {
        throw Exception('Could not launch email client');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Could not launch email client. Please contact support@pulseguard.com',
            ),
            action: SnackBarAction(
              label: 'Copy Email',
              onPressed: () {
                Clipboard.setData(
                  const ClipboardData(text: 'support@pulseguard.com'),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Email copied to clipboard')),
                );
              },
            ),
          ),
        );
      }
    }
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            icon: Icon(
              Icons.warning_amber_rounded,
              color: Theme.of(context).colorScheme.error,
              size: 48,
            ),
            title: const Text('Clear All Emergency Data?'),
            content: const Text(
              'This action cannot be undone. All your emergency contacts, health information, and settings will be permanently deleted.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'All emergency data has been cleared',
                        ),
                        backgroundColor: Theme.of(context).colorScheme.error,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                ),
                child: const Text('Clear Data'),
              ),
            ],
          ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Sign Out?'),
            content: const Text(
              'You will need to sign in again to access your emergency profile and settings.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() => _isLoggedIn = false);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Successfully signed out')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                ),
                child: const Text('Sign Out'),
              ),
            ],
          ),
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Exit PulseGuard?'),
            content: const Text(
              'Are you sure you want to close the app completely?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  if (Platform.isAndroid) {
                    SystemNavigator.pop();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                ),
                child: const Text('Exit App'),
              ),
            ],
          ),
    );
  }
}
