import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as developer;
import 'viewStorereadingImage/Bloc/view_storereading_image_bloc.dart';

class viewStorereadingImage extends StatefulWidget {
  final String siteId;
  final String siteName;

  const viewStorereadingImage({
    super.key,
    required this.siteId,
    required this.siteName,
  });

  @override
  State<viewStorereadingImage> createState() => _viewStorereadingImageState();
}

class _viewStorereadingImageState extends State<viewStorereadingImage> {
  late ViewStorereadingImageBloc _readingBloc;

  @override
  void initState() {
    super.initState();
    _readingBloc = ViewStorereadingImageBloc();
    // Fetch data when screen loads
    _fetchReadingImages();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _fetchReadingImages() {
    developer.log('📤 Fetching store reading images for Site ID: ${widget.siteId}', name: 'ViewStoreReadingImage');
    _readingBloc.add(FetchStoreReadingImageEvent(siteId: widget.siteId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D47A1),
        elevation: 0,

        // 👇 Back button add
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: Text(
          widget.siteName.length > 30
              ? '${widget.siteName.substring(0, 30)}...'
              : widget.siteName,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: BlocListener<ViewStorereadingImageBloc, ViewStorereadingImageState>(
        bloc: _readingBloc,
        listener: (context, state) {
          if (state is ViewStorereadingImageFailure) {
            developer.log('❌ Store Reading Image Error: ${state.message}', name: 'ViewStoreReadingImage');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("❌ Error: ${state.message}"),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is ViewStorereadingImageNoInternet) {
            developer.log('❌ No internet connection', name: 'ViewStoreReadingImage');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("❌ No internet connection. Please check your network."),
                backgroundColor: Colors.orange,
              ),
            );
          } else if (state is ViewStorereadingImageSuccess) {
            developer.log('✅ Store reading images loaded successfully', name: 'ViewStoreReadingImage');
          }
        },
        child: BlocBuilder<ViewStorereadingImageBloc, ViewStorereadingImageState>(
          bloc: _readingBloc,
          builder: (context, state) {
            if (state is ViewStorereadingImageLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ViewStorereadingImageSuccess) {
              final List<dynamic> readingsData = state.responseData['data'] ?? [];
              
              if (readingsData.isEmpty) {
                return const Center(
                  child: Text(
                    "No reading data found",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                );
              }

              final readingData = readingsData.first;
              final currentReading = readingData['current_reading'] ?? {};
              final difference = readingData['difference'] ?? {};
              final powerFactor = readingData['power_factor'] ?? 0;

              developer.log('📊 Displaying reading data for site: ${widget.siteName}', name: 'ViewStoreReadingImage');
              developer.log('⚡ Power Factor: $powerFactor', name: 'ViewStoreReadingImage');

              return _buildContent(context, currentReading, difference, widget.siteId, widget.siteName);
            } else if (state is ViewStorereadingImageInitial || state is ViewStorereadingImageNoInternet) {
              return const Center(
                child: Text(
                  "Pull to refresh or check your internet connection",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }

            return const Center(
              child: Text(
                "No reading data found",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          },
        ),
      ),
    );
  }
}

extension on _viewStorereadingImageState {
  Widget _buildContent(
      BuildContext context,
      Map<String, dynamic> reading,
      Map<String, dynamic> difference,
      String siteId,
      String siteName,
      ) {

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildHeaderLabel('Site', 'Site ID: $siteId - $siteName'),
          const SizedBox(height: 12),
          _buildHeaderLabel('Current Reading', ''),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(Icons.location_on_outlined, 'Location',
                    reading['location'] ?? 'N/A'),
                const Divider(height: 32),
                _buildInfoRow(Icons.calendar_today_outlined, 'Date & Time',
                    reading['datetime'] ?? 'N/A'),
                const Divider(height: 32),
            
                _buildReadingItem(
                  'KWH Reading',
                  (reading['kwh_reading'] ?? 0).toString(),
                  'KWH Image',
                  reading['kwh_image'] ?? '',
                ),
            
                const SizedBox(height: 24),
            
                _buildReadingItem(
                  'KVAH Reading',
                  (reading['kvah_reading'] ?? 0).toString(),
                  'KVAH Image',
                  reading['kvah_image'] ?? '',
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          _buildHeaderLabel('Difference', ''),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildSimpleRow(
                    'KWH Difference', 
                    (difference['kwh_difference'] ?? 0).toString()),
                const SizedBox(height: 12),
                _buildSimpleRow(
                    'KVAH Difference', 
                    (difference['kvah_difference'] ?? 0).toString()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderLabel(String title, String sub) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EEF7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D47A1)),
            ),
            TextSpan(
              text: '  $sub',
              style: const TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
      IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: Colors.grey, fontSize: 12)),
              Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14)),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildReadingItem(
      String label, String val, String imgLabel, String url) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(Icons.bolt, label, val),
        const SizedBox(height: 12),
        Text(imgLabel,
            style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            url,
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87)),
      ],
    );
  }
}