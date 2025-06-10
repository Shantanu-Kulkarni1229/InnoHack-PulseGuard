import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({Key? key}) : super(key: key);

  @override
  State<EmergencyContactsScreen> createState() =>
      _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  final List<Map<String, dynamic>> _contacts = [
    
  ];

  bool _autoSendAlerts = true;
  bool _allowLocationTracking = true;
  bool _showAddContactForm = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String? _selectedRelationship;

  final List<String> _relationships = [
    'Family',
    'Friend',
    'Doctor',
    'Caregiver',
    'Neighbor',
    'Coworker',
    'Other',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _addContact() {
    if (_nameController.text.isEmpty || _phoneController.text.isEmpty) {
      _showSnackBar('Please fill all required fields');
      return;
    }

    setState(() {
      _contacts.add({
        'name': _nameController.text,
        'phone': _phoneController.text,
        'relationship': _selectedRelationship ?? 'Other',
        'status': 'Active',
      });
      _nameController.clear();
      _phoneController.clear();
      _selectedRelationship = null;
      _showAddContactForm = false;
    });
    _showSnackBar('Contact added successfully');
  }

  void _deleteContact(int index) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Contact'),
            content: const Text(
              'Are you sure you want to remove this emergency contact?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  setState(() => _contacts.removeAt(index));
                  Navigator.pop(context);
                  _showSnackBar('Contact removed');
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  void _sendTestAlert() {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Test Alert Sent'),
            content: const Text(
              'A test alert has been sent to all active contacts.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _makeFakeCall(Map<String, dynamic> contact) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FakeCallScreen(contact: contact),
        fullscreenDialog: true,
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Contacts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // Show info about alert process
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trusted people who will be notified when you\'re in danger.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),

            // Add Contact Form (Conditional)
            if (_showAddContactForm) _buildAddContactForm(theme),

            // Contacts List
            ..._contacts.asMap().entries.map((entry) {
              final index = entry.key;
              final contact = entry.value;
              return _buildContactCard(contact, index, theme);
            }),

            const SizedBox(height: 16),

            // Add Contact Button
            if (!_showAddContactForm)
              Center(
                child: FilledButton.icon(
                  onPressed: () => setState(() => _showAddContactForm = true),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Emergency Contact'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 32),

            // Alert Preferences
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: theme.dividerColor),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Auto-send alerts to all contacts'),
                      subtitle: const Text(
                        'Immediately notify contacts when emergency is triggered',
                      ),
                      value: _autoSendAlerts,
                      onChanged:
                          (value) => setState(() => _autoSendAlerts = value),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      title: const Text('Share location with contacts'),
                      subtitle: const Text(
                        'Allow contacts to track your location during alerts',
                      ),
                      value: _allowLocationTracking,
                      onChanged:
                          (value) =>
                              setState(() => _allowLocationTracking = value),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Safety Tip
            Card(
              elevation: 0,
              color: theme.colorScheme.primaryContainer.withOpacity(0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Pro Tip',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Always keep at least 2 active contacts for better emergency response coverage.',
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        // Show what happens during alert
                      },
                      child: const Text(
                        'What happens when I trigger an alert?',
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 80), // Space for FAB
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: _sendTestAlert,
      //   icon: const Icon(Icons.warning_amber),
      //   label: const Text('Send Test Alert'),
      //   backgroundColor: Colors.orange,
      //   elevation: 2,
      // ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildContactCard(
    Map<String, dynamic> contact,
    int index,
    ThemeData theme,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contact['name'],
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(contact['phone'], style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.call),
                  onPressed: () => _makeFakeCall(contact),
                  color: Colors.green,
                  tooltip: 'Call ${contact['name']}',
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    // Implement edit functionality
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteContact(index),
                  color: theme.colorScheme.error,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Chip(
                  label: Text(contact['relationship']),
                  backgroundColor: theme.colorScheme.surfaceVariant,
                ),
                const Spacer(),
                Chip(
                  label: Text(contact['status']),
                  backgroundColor:
                      contact['status'] == 'Active'
                          ? Colors.green.withOpacity(0.2)
                          : Colors.orange.withOpacity(0.2),
                  labelStyle: TextStyle(
                    color:
                        contact['status'] == 'Active'
                            ? Colors.green
                            : Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddContactForm(ThemeData theme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add New Contact',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedRelationship,
              decoration: InputDecoration(
                labelText: 'Relationship',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.group),
              ),
              items:
                  _relationships.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
              onChanged: (newValue) {
                setState(() => _selectedRelationship = newValue);
              },
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed:
                        () => setState(() => _showAddContactForm = false),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton(
                    onPressed: _addContact,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Save Contact'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Fake Call Screen
class FakeCallScreen extends StatefulWidget {
  final Map<String, dynamic> contact;

  const FakeCallScreen({Key? key, required this.contact}) : super(key: key);

  @override
  State<FakeCallScreen> createState() => _FakeCallScreenState();
}

class _FakeCallScreenState extends State<FakeCallScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _connectingController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _connectingAnimation;
  
  String _callStatus = 'Calling...';
  bool _isConnected = false;
  Timer? _statusTimer;
  Timer? _connectionTimer;
  Duration _callDuration = Duration.zero;
  Timer? _durationTimer;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    
    _connectingController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _connectingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _connectingController,
      curve: Curves.easeInOut,
    ));

    _pulseController.repeat(reverse: true);
    _connectingController.repeat();
    
    // Simulate connection after 3 seconds
    _connectionTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _callStatus = 'Connected';
          _isConnected = true;
        });
        _pulseController.stop();
        _connectingController.stop();
        _startCallDuration();
      }
    });
    
    // Add haptic feedback
    HapticFeedback.lightImpact();
  }

  void _startCallDuration() {
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _callDuration = Duration(seconds: _callDuration.inSeconds + 1);
        });
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes);
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  void _endCall() {
    HapticFeedback.mediumImpact();
    Navigator.of(context).pop();
  }

  void _toggleMute() {
    HapticFeedback.selectionClick();
    // Implement mute functionality
  }

  void _toggleSpeaker() {
    HapticFeedback.selectionClick();
    // Implement speaker functionality
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _connectingController.dispose();
    _statusTimer?.cancel();
    _connectionTimer?.cancel();
    _durationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFF1a1a1a),
      body: SafeArea(
        child: Column(
          children: [
            // Status bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _callStatus,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  if (_isConnected)
                    Text(
                      _formatDuration(_callDuration),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
            
            const Spacer(),
            
            // Contact info
            Column(
              children: [
                // Avatar with pulse animation
                AnimatedBuilder(
                  animation: _isConnected ? const AlwaysStoppedAnimation(1.0) : _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[300],
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 3,
                          ),
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 80,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 24),
                
                // Contact name
                Text(
                  widget.contact['name'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Phone number
                Text(
                  widget.contact['phone'],
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                  ),
                ),
                
                const SizedBox(height: 4),
                
                // Relationship
                Text(
                  widget.contact['relationship'],
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            
            const Spacer(),
            
            // Connection animation
            if (!_isConnected)
              AnimatedBuilder(
                animation: _connectingAnimation,
                builder: (context, child) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(
                            ((_connectingAnimation.value + index * 0.3) % 1.0),
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),
            
            const SizedBox(height: 40),
            
            // Call controls
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Mute button
                  _buildCallButton(
                    icon: Icons.mic_off,
                    onPressed: _toggleMute,
                    backgroundColor: Colors.white.withOpacity(0.2),
                  ),
                  
                  // End call button
                  _buildCallButton(
                    icon: Icons.call_end,
                    onPressed: _endCall,
                    backgroundColor: Colors.red,
                    size: 70,
                  ),
                  
                  // Speaker button
                  _buildCallButton(
                    icon: Icons.volume_up,
                    onPressed: _toggleSpeaker,
                    backgroundColor: Colors.white.withOpacity(0.2),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildCallButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color backgroundColor,
    double size = 60,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: backgroundColor,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: size * 0.4,
        ),
      ),
    );
  }
}