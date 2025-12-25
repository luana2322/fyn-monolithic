import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../data/models/location_info.dart';
import '../../../../core/services/serpapi_service.dart';

/// Map location picker with SerpAPI search + OpenStreetMap display
/// Best of both worlds: powerful search + free maps!
class MapLocationPicker extends StatefulWidget {
  final void Function(LocationInfo) onLocationSelected;
  final LatLng? initialLocation;

  const MapLocationPicker({
    super.key,
    required this.onLocationSelected,
    this.initialLocation,
  });

  @override
  State<MapLocationPicker> createState() => _MapLocationPickerState();
}

class _MapLocationPickerState extends State<MapLocationPicker> {
  final MapController _mapController = MapController();
  final _searchController = TextEditingController();
  final _serpApiService = SerpApiService();
  
  LatLng _currentCenter = const LatLng(21.0285, 105.8542); // Default: Hanoi
  LatLng? _selectedLocation;
  String? _placeName;
  String? _address;
  double? _rating;
  
  List<PlaceSearchResult> _searchResults = [];
  bool _isSearching = false;
  bool _showResults = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialLocation != null) {
      _selectedLocation = widget.initialLocation;
      _currentCenter = widget.initialLocation!;
      _reverseGeocode(widget.initialLocation!);
    } else {
      _getCurrentLocation();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Search bar with SerpAPI
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search for restaurants, cafes, landmarks...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _showResults = false;
                          _searchResults = [];
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: isDark ? const Color(0xFF2C2C2E) : Colors.white,
            ),
            onChanged: _onSearchChanged,
            onSubmitted: (_) => _searchPlaces(),
          ),
        ),

        // Map or Search Results
        Expanded(
          child: Stack(
            children: [
              // OpenStreetMap with flutter_map
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _currentCenter,
                  initialZoom: 15.0,
                  onTap: (tapPosition, point) => _onMapTap(point),
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all,
                  ),
                ),
                children: [
                  // OpenStreetMap tiles (FREE!)
                  TileLayer(
                    urlTemplate: isDark
                        ? 'https://tiles.stadiamaps.com/tiles/alidade_smooth_dark/{z}/{x}/{y}{r}.png?api_key=${dotenv.get('STADIA_MAPS_API_KEY', fallback: '')}'
                        : 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c'],
                    userAgentPackageName: 'com.fyn.app',
                    maxZoom: 19,
                    retinaMode: RetinaMode.isHighDensity(context),
                  ),
                  
                  // Marker for selected location
                  if (_selectedLocation != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _selectedLocation!,
                          width: 50,
                          height: 50,
                          alignment: Alignment.topCenter,
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 50,
                          ),
                        ),
                      ],
                    ),
                ],
              ),

              // Search results overlay
              if (_showResults && _searchResults.isNotEmpty)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 300),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(12),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(8),
                      itemCount: _searchResults.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final result = _searchResults[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.red.shade50,
                            child: const Icon(Icons.place, color: Colors.red, size: 20),
                          ),
                          title: Text(
                            result.title,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (result.address != null)
                                Text(
                                  result.address!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              if (result.rating != null)
                                Row(
                                  children: [
                                    const Icon(Icons.star, size: 14, color: Colors.amber),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${result.rating} · ${result.reviews ?? 0} reviews',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                          onTap: () => _selectSearchResult(result),
                        );
                      },
                    ),
                  ),
                ),

              // Loading indicator
              if (_isLoading)
                Container(
                  color: Colors.black26,
                  child: const Center(child: CircularProgressIndicator()),
                ),

              // Current location button
              Positioned(
                right: 16,
                bottom: _selectedLocation != null ? 180 : 20,
                child: FloatingActionButton(
                  mini: true,
                  backgroundColor: Colors.white,
                  onPressed: _getCurrentLocation,
                  child: const Icon(Icons.my_location, color: Colors.blue),
                ),
              ),
            ],
          ),
        ),

        // Selected location info panel
        Container(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_placeName != null) ...[
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _placeName!,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _address ?? '',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          if (_rating != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.star, size: 16, color: Colors.amber),
                                const SizedBox(width: 4),
                                Text(
                                  '$_rating',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _confirmLocation,
                    icon: const Icon(Icons.check),
                    label: const Text('Confirm Location'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ] else ...[
                Text(
                  'Search for a place or tap on the map to select a location',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  void _onSearchChanged(String value) {
    if (value.length > 2) {
      // Debounce: Auto-search after user stops typing
      Future.delayed(const Duration(milliseconds: 800), () {
        if (_searchController.text == value && value.length > 2) {
          _searchPlaces();
        }
      });
    }
  }

  Future<void> _searchPlaces() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
      _showResults = true;
    });

    try {
      final results = await _serpApiService.searchPlaces(
        query,
        location: '${_currentCenter.latitude},${_currentCenter.longitude}',
      );

      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() => _isSearching = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Search failed: $e')),
        );
      }
    }
  }

  void _selectSearchResult(PlaceSearchResult result) {
    if (!result.hasCoordinates) return;

    final location = LatLng(result.latitude!, result.longitude!);

    setState(() {
      _showResults = false;
      _currentCenter = location;
      _selectedLocation = location;
      _placeName = result.title;
      _address = result.address ?? '${result.latitude}, ${result.longitude}';
      _rating = result.rating;
    });

    // Animate map to selected location
    _mapController.move(location, 17.0);
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);
    
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        final position = await Geolocator.getCurrentPosition();
        final location = LatLng(position.latitude, position.longitude);
        
        setState(() {
          _currentCenter = location;
          _selectedLocation = location;
        });
        
        _mapController.move(location, 15.0);
        await _reverseGeocode(location);
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _onMapTap(LatLng point) async {
    setState(() {
      _selectedLocation = point;
      _isLoading = true;
      _rating = null; // Clear rating when manually tapping
    });

    await _reverseGeocode(point);
  }

  Future<void> _reverseGeocode(LatLng position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        setState(() {
          _placeName = place.name ?? place.street ?? 'Selected Location';
          _address = [
            place.street,
            place.locality,
            place.administrativeArea,
            place.country,
          ].where((e) => e != null && e.isNotEmpty).join(', ');
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _placeName = 'Selected Location';
        _address = '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
        _isLoading = false;
      });
    }
  }

  void _confirmLocation() {
    if (_selectedLocation != null && _placeName != null) {
      widget.onLocationSelected(LocationInfo(
        name: _placeName!,
        address: _address ?? '',
        latitude: _selectedLocation!.latitude,
        longitude: _selectedLocation!.longitude,
      ));
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
