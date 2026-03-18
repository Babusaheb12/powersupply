import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:powersupply/Screen/StoreReading/storereadingshow/viewStorereadingImage.dart';
import 'dart:developer' as developer;
import '../../../../../../Api/shared_preference.dart';
import 'Bloc/store_reading_bloc.dart';

class StoreReadingScreen extends StatefulWidget {
  final Function(int)? onNavigateToProfile;

  StoreReadingScreen({super.key, this.onNavigateToProfile});

  @override
  State<StoreReadingScreen> createState() => _StoreReadingScreenState();
}

class _StoreReadingScreenState extends State<StoreReadingScreen> {
  late StoreReadingBloc _readingBloc;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _readingBloc = StoreReadingBloc();
    // Fetch data when screen loads
    _fetchReadings();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _fetchReadings() {
    final userId = Prefs.userId ?? '';
    developer.log('📤 Fetching store readings for User ID: $userId', name: 'StoreReadingScreen');
    _readingBloc.add(FetchStoreReadingsEvent(userId: userId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,

      appBar: AppBar(
        backgroundColor: const Color(0xFF1E4FA1),
        title: const Text(
          " month Reports",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: BlocListener<StoreReadingBloc, StoreReadingState>(
        bloc: _readingBloc,
        listener: (context, state) {
          if (state is StoreReadingFailure) {
            developer.log('❌ Store Reading Error: ${state.message}', name: 'StoreReadingScreen');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("❌ Error: ${state.message}"),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is StoreReadingNoInternet) {
            developer.log('❌ No internet connection', name: 'StoreReadingScreen');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("❌ No internet connection. Please check your network."),
                backgroundColor: Colors.orange,
              ),
            );
          } else if (state is StoreReadingSuccess) {
            developer.log('✅ Store readings loaded successfully', name: 'StoreReadingScreen');
          }
        },
        child: Column(
          children: [

            /// 🔍 Search Box
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {}); // Trigger rebuild for filtering
                },
                decoration: InputDecoration(
                  hintText: "Search factories...",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            /// 📋 List
            Expanded(
              child: BlocBuilder<StoreReadingBloc, StoreReadingState>(
                bloc: _readingBloc,
                builder: (context, state) {
                  if (state is StoreReadingLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (state is StoreReadingSuccess) {
                    final List<dynamic> allReadings = state.responseData['data'] ?? [];
                    developer.log('📊 Displaying ${allReadings.length} readings', name: 'StoreReadingScreen');
                    
                    // Filter readings based on search
                    final filteredReadings = _searchController.text.isEmpty
                        ? allReadings
                        : allReadings.where((reading) {
                            final siteName = reading['site_name']?.toString().toLowerCase() ?? '';
                            final location = reading['location']?.toString().toLowerCase() ?? '';
                            final searchText = _searchController.text.toLowerCase();
                            return siteName.contains(searchText) || location.contains(searchText);
                          }).toList();

                    if (filteredReadings.isEmpty) {
                      return const Center(
                        child: Text(
                          "No meter readings found",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredReadings.length,
                      itemBuilder: (context, index) {
                        final reading = filteredReadings[index];

                        return GestureDetector(
                          onTap: () {
                            developer.log('🔵 Tapped on site: ${reading['site_name']}', name: 'StoreReadingScreen');
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => viewStorereadingImage(
                                  siteId: reading['site_id'],
                                  siteName: reading['site_name'],
                                ),
                              ),
                            );
                          },
                          child: ReportCard(
                            title: reading['site_name'] ?? 'Unknown',
                            location: reading['location'] ?? 'Unknown',
                            date: reading['datetime'] ?? '',
                            kwh: reading['kwh_reading'] ?? '0',
                            kvah: reading['kvah_reading'] ?? '0',
                          ),
                        );
                      },
                    );
                  } else if (state is StoreReadingInitial || state is StoreReadingNoInternet) {
                    return const Center(
                      child: Text(
                        "Pull to refresh or check your internet connection",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    );
                  }

                  return const Center(
                    child: Text(
                      "No meter readings found",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
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
}

class ReportCard extends StatelessWidget {
  final String title;
  final String location;
  final String date;
  final String kwh;
  final String kvah;

  const ReportCard({
    super.key,
    required this.title,
    required this.location,
    required this.date,
    required this.kwh,
    required this.kvah,
  });

  @override
  Widget build(BuildContext context) {

    /// ✅ Format Date
    String formattedDate = date;
    try {
      final parsedDate = DateTime.parse(date);
      formattedDate = DateFormat("dd MMM yyyy, hh:mm a").format(parsedDate);
    } catch (_) {}

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
          )
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// 🏭 Title
          Row(
            children: [
              const Icon(Icons.business, color: Colors.blue, size: 28),
              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
          ),

          const SizedBox(height: 10),

          /// 📍 Location
          Row(
            children: [
              const Icon(Icons.location_on, size: 18, color: Colors.grey),
              const SizedBox(width: 6),

              Expanded(
                child: Text(
                  location,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                  ),
                ),
              )
            ],
          ),

          const SizedBox(height: 6),

          /// 📅 Date
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
              const SizedBox(width: 6),

              Text(
                "Date: $formattedDate",
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                ),
              )
            ],
          ),

          const SizedBox(height: 8),

          /// ⚡ Readings
          Text(
            "KWH: $kwh    KVAH: $kvah",
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          )
        ],
      ),
    );
  }
}