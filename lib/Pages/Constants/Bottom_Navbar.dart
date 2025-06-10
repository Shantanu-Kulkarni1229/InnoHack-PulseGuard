import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PulseGuardNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTabChange;

  const PulseGuardNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTabChange,
  }) : super(key: key);

  @override
  State<PulseGuardNavBar> createState() => _PulseGuardNavBarState();
}

class _PulseGuardNavBarState extends State<PulseGuardNavBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: widget.currentIndex,
        onTap: (index) {
          HapticFeedback.lightImpact();
          widget.onTabChange(index);
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF004AAD),
        unselectedItemColor: Colors.grey[600],
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
            tooltip: 'Quick access to Panic, live status, shortcuts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: 'Map',
            tooltip: 'Realtime map showing nearby hospitals/police',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline),
            activeIcon: Icon(Icons.favorite),
            label: 'Health',
            tooltip: 'Medical info, allergies, blood group',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contacts_outlined),
            activeIcon: Icon(Icons.contacts),
            label: 'Contacts',
            tooltip: 'Emergency contacts + add/edit trusted people',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'More',
            tooltip: 'Profile, fake call, theme, logout, app info',
          ),
        ],
      ),
    );
  }
}