import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  LatLng? _currentLocation;
  List<Map<String, dynamic>> _locations = [];
  List<Marker> _allMarkers = [];
  bool _isLoading = true;
  String _filterType = 'all';
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  // CSMSS College location and nearby hospitals
  final LatLng _csmssLocation = const LatLng(19.8762, 75.3433);
  final List<Map<String, dynamic>> _csmssHospitals = [
    {
      'name': 'Government Medical College and Hospital, Aurangabad',
      'lat': '19.8744',
      'lon': '75.3432',
      'type': 'hospital',
      'phone': '+91-240-2382201',
      'address': 'GMCH Campus, Aurangabad, Maharashtra 431001',
      'distance': '0.2 km',
      'emergency': true,
      'rating': 4.2,
    },
    {
      'name': 'Medipoint Hospital',
      'lat': '19.8756',
      'lon': '75.3445',
      'type': 'hospital',
      'phone': '+91-240-2335678',
      'address': 'Near CSMSS College, Aurangabad',
      'distance': '0.3 km',
      'emergency': true,
      'rating': 4.0,
    },
    {
      'name': 'Apollo Hospital Aurangabad',
      'lat': '19.8823',
      'lon': '75.3512',
      'type': 'hospital',
      'phone': '+91-240-6604000',
      'address': 'Plot No. 6, Chikalthana, Aurangabad',
      'distance': '1.2 km',
      'emergency': true,
      'rating': 4.5,
    },
    {
      'name': 'Care Hospital',
      'lat': '19.8690',
      'lon': '75.3398',
      'type': 'hospital',
      'phone': '+91-240-6627000',
      'address': 'MIDC, Chikalthana, Aurangabad',
      'distance': '1.5 km',
      'emergency': true,
      'rating': 4.3,
    },
    {
      'name': 'Kamla Nehru Hospital',
      'lat': '19.8834',
      'lon': '75.3421',
      'type': 'hospital',
      'phone': '+91-240-2334455',
      'address': 'Panchakki Road, Aurangabad',
      'distance': '1.8 km',
      'emergency': false,
      'rating': 3.8,
    },
    {
      'name': 'City Hospital and Research Centre',
      'lat': '19.8712',
      'lon': '75.3356',
      'type': 'hospital',
      'phone': '+91-240-2485000',
      'address': 'Railway Station Road, Aurangabad',
      'distance': '2.1 km',
      'emergency': true,
      'rating': 4.1,
    },
    {
      'name': 'Sushrut Hospital',
      'lat': '19.8945',
      'lon': '75.3234',
      'type': 'hospital',
      'phone': '+91-240-2345678',
      'address': 'Cantonment Area, Aurangabad',
      'distance': '2.3 km',
      'emergency': false,
      'rating': 3.9,
    },
    {
      'name': 'Lifecare Hospital',
      'lat': '19.8567',
      'lon': '75.3567',
      'type': 'hospital',
      'phone': '+91-240-2456789',
      'address': 'Jalna Road, Aurangabad',
      'distance': '2.8 km',
      'emergency': true,
      'rating': 4.0,
    },
  ];

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.easeInOut),
    );
    _fetchAllLocations();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  Future<void> _fetchAllLocations() async {
    setState(() => _isLoading = true);

    try {
      final pos = await Geolocator.getCurrentPosition();
      _currentLocation = LatLng(pos.latitude, pos.longitude);

      List<Map<String, dynamic>> combined = [];

      // Add CSMSS hospitals first
      combined.addAll(_csmssHospitals);

      // Fetch additional hospitals from current location
      final hospitals = await _fetchNominatim(
        "hospital",
        pos.latitude,
        pos.longitude,
      );
      combined.addAll(hospitals);

      // Fetch police stations
      final police = await _fetchNominatim("police", pos.latitude, pos.longitude);
      combined.addAll(police);

      List<Marker> markers = combined.map((loc) {
        return Marker(
          child: GestureDetector(
            onTap: () => _showLocationDetails(loc),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                loc['type'] == 'hospital'
                    ? Icons.local_hospital
                    : Icons.local_police,
                color: loc['type'] == 'hospital'
                    ? (loc['emergency'] == true ? Colors.red : Colors.orange)
                    : Colors.blue,
                size: 28,
              ),
            ),
          ),
          point: LatLng(double.parse(loc['lat']), double.parse(loc['lon'])),
          width: 40,
          height: 40,
        );
      }).toList();

      setState(() {
        _locations = combined;
        _allMarkers = markers;
        _isLoading = false;
      });

      _fabAnimationController.forward();
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Failed to fetch locations: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _fetchNominatim(
      String query,
      double lat,
      double lon,
      ) async {
    try {
      final url =
          "https://nominatim.openstreetmap.org/search?format=json&q=$query&limit=10&bounded=1&lat=$lat&lon=$lon&radius=5000";
      final response = await http.get(
        Uri.parse(url),
        headers: {'User-Agent': 'PulseGuardApp/1.0 (your@email.com)'},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch data');
      }

      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(
        data.map(
              (item) => {
            'name': item['display_name'],
            'lat': item['lat'],
            'lon': item['lon'],
            'type': query,
            'phone': item['extratags']?['phone'] ?? '',
            'address': item['display_name'],
            'emergency': true,
            'rating': 0.0,
          },
        ),
      );
    } catch (e) {
      return [];
    }
  }

  void _showLocationDetails(Map<String, dynamic> loc) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 50,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Header with icon and type
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: loc['type'] == 'hospital'
                        ? Colors.red.withOpacity(0.1)
                        : Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    loc['type'] == 'hospital'
                        ? Icons.local_hospital
                        : Icons.local_police,
                    color: loc['type'] == 'hospital' ? Colors.red : Colors.blue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc['type'] == 'hospital' ? 'Hospital' : 'Police Station',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (loc['emergency'] == true)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            '24/7 Emergency',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Name
            Text(
              loc['name'],
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            // Rating (if available)
            if (loc['rating'] != null && loc['rating'] > 0)
              Row(
                children: [
                  ...List.generate(5, (index) {
                    return Icon(
                      index < loc['rating'].floor()
                          ? Icons.star
                          : Icons.star_border,
                      color: Colors.amber,
                      size: 16,
                    );
                  }),
                  const SizedBox(width: 8),
                  Text(
                    '${loc['rating']} rating',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),

            if (loc['rating'] != null && loc['rating'] > 0)
              const SizedBox(height: 12),

            // Address
            if (loc['address'] != null && loc['address'].isNotEmpty)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.location_on, color: Colors.grey[600], size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      loc['address'],
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),

            if (loc['address'] != null && loc['address'].isNotEmpty)
              const SizedBox(height: 12),

            // Distance
            if (loc['distance'] != null)
              Row(
                children: [
                  Icon(Icons.directions, color: Colors.grey[600], size: 16),
                  const SizedBox(width: 8),
                  Text(
                    loc['distance'],
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 20),

            // Action buttons
            Row(
              children: [
                if (loc['phone'] != null && loc['phone'].isNotEmpty)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        launchUrl(Uri.parse("tel:${loc['phone']}"));
                      },
                      icon: const Icon(Icons.call, size: 20),
                      label: const Text("Call Now"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),

                if (loc['phone'] != null && loc['phone'].isNotEmpty)
                  const SizedBox(width: 12),

                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      final lat = loc['lat'];
                      final lon = loc['lon'];
                      launchUrl(Uri.parse("https://maps.google.com/?q=$lat,$lon"));
                    },
                    icon: const Icon(Icons.directions, size: 20),
                    label: const Text("Directions"),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showAllInBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle and header
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: 50,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text(
                        'Nearby Safety Services',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${_getFilteredLocations().length} places',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Filter chips
                  Row(
                    children: [
                      _buildFilterChip('all', 'All', Icons.map),
                      const SizedBox(width: 8),
                      _buildFilterChip('hospital', 'Hospitals', Icons.local_hospital),
                      const SizedBox(width: 8),
                      _buildFilterChip('police', 'Police', Icons.local_police),
                    ],
                  ),
                ],
              ),
            ),

            // List
            Expanded(
              child: ListView.builder(
                itemCount: _getFilteredLocations().length,
                itemBuilder: (ctx, i) {
                  final loc = _getFilteredLocations()[i];
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[200]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: loc['type'] == 'hospital'
                              ? Colors.red.withOpacity(0.1)
                              : Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          loc['type'] == 'hospital'
                              ? Icons.local_hospital
                              : Icons.local_police,
                          color: loc['type'] == 'hospital' ? Colors.red : Colors.blue,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        loc['name'],
                        style: const TextStyle(fontWeight: FontWeight.w600),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (loc['distance'] != null)
                            Text(
                              loc['distance'],
                              style: const TextStyle(fontSize: 12),
                            ),
                          if (loc['emergency'] == true)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                '24/7 Emergency',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      trailing: loc['phone'] != null && loc['phone'].isNotEmpty
                          ? IconButton(
                        icon: const Icon(Icons.call, color: Colors.green),
                        onPressed: () {
                          launchUrl(Uri.parse("tel:${loc['phone']}"));
                        },
                      )
                          : null,
                      onTap: () => _showLocationDetails(loc),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String value, String label, IconData icon) {
    final isSelected = _filterType == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _filterType = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.teal : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredLocations() {
    if (_filterType == 'all') return _locations;
    return _locations.where((loc) => loc['type'] == _filterType).toList();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Safety Services Near You'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchAllLocations,
          ),
        ],
      ),

      floatingActionButton: AnimatedBuilder(
        animation: _fabAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _fabAnimation.value,
            child: FloatingActionButton.extended(
              onPressed: _showAllInBottomSheet,
              label: const Text("View All Services"),
              icon: const Icon(Icons.list),
              backgroundColor: Colors.teal.shade700,
              heroTag: 'main_fab',
            ),
          );
        },
      ),

      body: _isLoading
          ? Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.teal.shade50, Colors.white],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
              ),
              SizedBox(height: 16),
              Text(
                'Finding nearby safety services...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.teal,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      )
          : _currentLocation == null
          ? Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.red.shade50, Colors.white],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_off,
                size: 64,
                color: Colors.red,
              ),
              SizedBox(height: 16),
              Text(
                'Unable to get your location',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Please enable location services and try again',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      )
          : FlutterMap(
        options: MapOptions(
          center: _currentLocation!,
          zoom: 14.0,
          maxZoom: 18.0,
          minZoom: 10.0,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            userAgentPackageName: 'com.pulseguard.app',
          ),
          MarkerLayer(
            markers: [
              // Current location marker
              Marker(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.my_location,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                width: 40,
                height: 40,
                point: _currentLocation!,
              ),

              // CSMSS College marker
              Marker(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.purple,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.school,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                width: 30,
                height: 30,
                point: _csmssLocation,
              ),

              ..._allMarkers,
            ],
          ),
        ],
      ),
    );
  }
}