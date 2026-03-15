import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/siteList/site_list_bloc.dart';
import '../meterReading/AddMeterReading.dart';

class CreateNewProject extends StatefulWidget {
  const CreateNewProject({super.key});

  @override
  State<CreateNewProject> createState() => _CreateNewProjectState();
}

class _CreateNewProjectState extends State<CreateNewProject> {

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
    _getCurrentLocation();
    _fetchSiteList();
  }

  void _fetchSiteList() {
    _siteListBloc.add(FetchSiteListEvent());
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

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _locationController.text = "Location disabled";
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      Position position = await Geolocator.getCurrentPosition();

      List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;

        String address =
            "${place.subLocality}, ${place.locality}, ${place.administrativeArea}";

        setState(() {
          _locationController.text = address;
        });
      }
    } catch (e) {
      _locationController.text = "Unable to get location";
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
          "New Project",
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

                Container(
                  width: double.infinity,
                  padding:  EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                  ),
                  child: Text(
                    DateFormat("dd/MM/yyyy hh:mm a").format(projectDateTime),
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
                      builder: (_) => AddMeterReadingScreen(
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