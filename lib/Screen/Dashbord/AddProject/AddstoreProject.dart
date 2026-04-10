import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../StoreReading/storeReding.dart';
import 'bloc/siteList/site_list_bloc.dart';

class CreateStoreProject extends StatefulWidget {
  const CreateStoreProject({super.key});

  @override
  State<CreateStoreProject> createState() => _CreateStoreProjectState();
}

class _CreateStoreProjectState extends State<CreateStoreProject> {

  final _locationController = TextEditingController();
  final _searchController = TextEditingController();

  String selectedSite = "";
  String selectedSiteId = "";

  DateTime projectDateTime = DateTime.now();

  late SiteListBloc _siteListBloc;

  @override
  void initState() {
    super.initState();
    _siteListBloc = SiteListBloc();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getCurrentLocation();
    });
    _fetchSiteList();
  }

  LocationSettings _currentPositionSettings() {
    if (kIsWeb) {
      return const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 20),
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return AndroidSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 0,
          timeLimit: const Duration(seconds: 20),
        );
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return AppleSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 20),
        );
      default:
        return const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        );
    }
  }

  String _placemarkToAddress(Placemark place) {
    final parts = <String>[
      if ((place.street ?? '').trim().isNotEmpty) place.street!.trim(),
      if ((place.subLocality ?? '').trim().isNotEmpty) place.subLocality!.trim(),
      if ((place.locality ?? '').trim().isNotEmpty) place.locality!.trim(),
      if ((place.administrativeArea ?? '').trim().isNotEmpty)
        place.administrativeArea!.trim(),
      if ((place.postalCode ?? '').trim().isNotEmpty) place.postalCode!.trim(),
      if ((place.country ?? '').trim().isNotEmpty) place.country!.trim(),
    ];
    return parts.join(', ');
  }

  void _applyLocationText(String text) {
    if (!mounted) return;
    setState(() {
      _locationController.text = text;
    });
  }

  void _fetchSiteList() {
    _siteListBloc.add(FetchSiteListEvent());
  }

  /// Select Date Time
  Future<void> _selectDateTime() async {
    // Get current time components
    final currentTime = DateTime.now();
    
    // Show Date Picker (prevent future dates)
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: projectDateTime,
      firstDate: DateTime(2000),
      lastDate: currentTime, // Prevent selecting future dates
    );

    if (pickedDate != null) {
      setState(() {
        // Keep the current time, only change the date
        projectDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          currentTime.hour,
          currentTime.minute,
        );
      });
    }
  }

  @override
  void dispose() {
    _locationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// Get Current Location
  Future<void> _getCurrentLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _applyLocationText('Location services are off. Turn them on to use your current location.');
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        _applyLocationText('Location permission denied.');
        return;
      }
      if (permission == LocationPermission.deniedForever) {
        _applyLocationText(
            'Location permission blocked. Enable it in app settings, then reopen this screen.');
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: _currentPositionSettings(),
      );

      final coordLabel =
          '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';

      List<Placemark> placemarks;
      try {
        placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
      } catch (_) {
        placemarks = const [];
      }

      if (placemarks.isNotEmpty) {
        final address = _placemarkToAddress(placemarks.first);
        _applyLocationText(address.isNotEmpty ? address : coordLabel);
      } else {
        _applyLocationText(coordLabel);
      }
    } catch (e) {
      _applyLocationText('Unable to get location');
    }
  }

  /// Bottom Sheet
  void openSiteBottomSheet() {
    _searchController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return BlocBuilder<SiteListBloc, SiteListState>(
          bloc: _siteListBloc,
          builder: (context, state) {
            // Get screen height and calculate 90%
            final screenHeight = MediaQuery.of(context).size.height;
            final bottomSheetHeight = screenHeight * 0.9;

            if (state is SiteListInitial || state is SiteListLoading) {
              return SizedBox(
                height: bottomSheetHeight,
                child: const Center(child: CircularProgressIndicator()),
              );
            } else if (state is SiteListLoaded) {
              return StatefulBuilder(
                builder: (context, setModalState) {
                  // Filter sites based on search query
                  final filteredSites = state.sites.where((site) {
                    final siteName = (site['site_name'] ?? '').toLowerCase();
                    final searchQuery = _searchController.text.toLowerCase();
                    return siteName.contains(searchQuery);
                  }).toList();

                  return SizedBox(
                    height: bottomSheetHeight,
                    child: Column(
                      children: [
                        /// Header with Search Bar
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Select Site",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    icon: const Icon(Icons.close),
                                  )
                                ],
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _searchController,
                                decoration: InputDecoration(
                                  hintText: 'Search sites...',
                                  prefixIcon: const Icon(Icons.search),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[100],
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                ),
                                onChanged: (value) {
                                  setModalState(() {});
                                },
                              ),
                            ],
                          ),
                        ),
                        const Divider(),
                        /// Site List
                        Expanded(
                          child: filteredSites.isEmpty
                              ? const Center(
                            child: Text(
                              'No sites found',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          )
                              : ListView.builder(
                            itemCount: filteredSites.length,
                            itemBuilder: (context, index) {
                              final site = filteredSites[index];
                              final siteName = site['site_name'] ?? '';
                              final siteId = site['id'] ?? '';

                              return ListTile(
                                title: Text(
                                  siteName,
                                  style: const TextStyle(fontSize: 15),
                                ),
                                onTap: () {
                                  setState(() {
                                    selectedSite = siteName;
                                    selectedSiteId = siteId;
                                  });
                                  Navigator.pop(context);
                                },
                              );
                            },
                          ),
                        )
                      ],
                    ),
                  );
                },
              );
            } else if (state is SiteListError) {
              return SizedBox(
                height: bottomSheetHeight,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text(state.message, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          _fetchSiteList();
                        },
                        child: const Text("Retry"),
                      )
                    ],
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    const primaryColor = Color(0xFF1F4FA3);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text(
          "Add store project",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            /// Site Name
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const Row(
                  children: [
                    Text(
                      "Site Name",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
                    Text(
                      " *",
                      style: TextStyle(color: Colors.red),
                    )
                  ],
                ),

                const SizedBox(height: 8),

                GestureDetector(
                  onTap: openSiteBottomSheet,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [

                        Text(
                          selectedSite.isEmpty
                              ? "Select Site Name"
                              : selectedSite,
                          style: const TextStyle(fontSize: 16),
                        ),

                        const Icon(Icons.keyboard_arrow_down)
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            /// Location
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const Row(
                  children: [
                    Text(
                      "Location",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
                    Text(
                      " *",
                      style: TextStyle(color: Colors.red),
                    )
                  ],
                ),

                const SizedBox(height: 8),

                TextFormField(
                  controller: _locationController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_on),
                  ),
                )
              ],
            ),

            SizedBox(height: 20),

            /// Date Time
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Row(
                  children: [
                    Text(
                      "Date & Time",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
                    Text(
                      " *",
                      style: TextStyle(color: Colors.red),
                    )
                  ],
                ),

                SizedBox(height: 8),

                GestureDetector(
                  onTap: _selectDateTime,
                  child: Container(
                    width: double.infinity,
                    padding:  EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat("dd/MM/yyyy hh:mm a").format(projectDateTime),
                          style: const TextStyle(fontSize: 16),
                        ),
                        const Icon(Icons.calendar_today, size: 20),
                      ],
                    ),
                  ),
                )
              ],
            ),

            // const Spacer(),
            SizedBox(height: 40),


            /// Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Validate that site is selected
                  if (selectedSite.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select a site'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  // Validate that site is selected
                  if (selectedSite.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select a site'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  // Navigate to AddMeterReadingScreen with parameters
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddStoreMeterReadingScreen(
                        siteName: selectedSite,
                        siteId: selectedSiteId,
                        location: _locationController.text,
                        dateTime: DateFormat("yyyy-MM-dd HH:mm:ss").format(projectDateTime),
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding:  EdgeInsets.symmetric(vertical: 16),
                ),
                child:  Text(
                  "Submit",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}