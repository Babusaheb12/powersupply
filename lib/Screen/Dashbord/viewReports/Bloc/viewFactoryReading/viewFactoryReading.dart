import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/factory_reading_bloc.dart';

class ViewFactoryReading extends StatelessWidget {
  final String siteId;
  final String siteName;

  ViewFactoryReading({super.key, required this.siteId, required this.siteName});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FactoryReadingBloc()..add(FetchFactoryReadingEvent(siteId: siteId)),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0D47A1),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            siteName.length > 30 ? '${siteName.substring(0, 30)}...' : siteName,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<FactoryReadingBloc, FactoryReadingState>(
          builder: (context, state) {
            if (state is FactoryReadingLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is FactoryReadingNoInternet) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.wifi_off, color: Colors.grey, size: 64),
                    const SizedBox(height: 16),
                    Text(
                      'No internet connection',
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
                    ),
                  ],
                ),
              );
            }
            if (state is FactoryReadingFailure) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
              );
            }
            if (state is FactoryReadingSuccess) {
              final dataList = state.data['data'] as List<dynamic>?;
              if (dataList == null || dataList.isEmpty) {
                return const Center(
                  child: Text('No reading data available'),
                );
              }
              return _buildContent(context, dataList);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    List<dynamic> dataList,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderLabel('Site', 'Site ID: $siteId - $siteName'),
          const SizedBox(height: 12),
          ...dataList.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value as Map<String, dynamic>;
            final reading =
                item['current_reading'] as Map<String, dynamic>? ?? {};
            final difference = item['difference'] as Map<String, dynamic>? ?? {};
            final kwhReading = reading['kwh_reading'];
            final kvahReading = reading['kvah_reading'];
            final kwhDiff = difference['kwh_difference'];
            final kvahDiff = difference['kvah_difference'];
            final dailyPf = item['daily_pf'];
            final monthPf = item['month_pf'];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderLabel('Record ${index + 1}', ''),
                const SizedBox(height: 12),
                _buildHeaderLabel('Current Reading', ''),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(Icons.location_on_outlined, 'Location',
                          (reading['location'] ?? '').toString()),
                      const Divider(height: 32),
                      _buildInfoRow(Icons.calendar_today_outlined, 'Date & Time',
                          (reading['datetime'] ?? '').toString()),
                      const Divider(height: 32),
                      _buildReadingItem(
                        'KWH Reading',
                        kwhReading != null
                            ? (kwhReading is num
                                ? kwhReading.toStringAsFixed(2)
                                : kwhReading.toString())
                            : '—',
                        'KWH Image',
                        (reading['kwh_image'] ?? '').toString(),
                      ),
                      const SizedBox(height: 24),
                      _buildReadingItem(
                        'KVAH Reading',
                        kvahReading != null
                            ? (kvahReading is num
                                ? kvahReading.toStringAsFixed(2)
                                : kvahReading.toString())
                            : '—',
                        'KVAH Image',
                        (reading['kvah_image'] ?? '').toString(),
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
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      _buildSimpleRow(
                        'KWH Difference',
                        kwhDiff != null
                            ? (kwhDiff is num
                                ? kwhDiff.toStringAsFixed(2)
                                : kwhDiff.toString())
                            : '—',
                      ),
                      const SizedBox(height: 12),
                      _buildSimpleRow(
                        'KVAH Difference',
                        kvahDiff != null
                            ? (kvahDiff is num
                                ? kvahDiff.toStringAsFixed(2)
                                : kvahDiff.toString())
                            : '—',
                      ),
                      const SizedBox(height: 12),
                      _buildSimpleRow(
                        'Daily PF',
                        _formatValue(dailyPf),
                      ),
                      const SizedBox(height: 12),
                      _buildSimpleRow(
                        'Month PF',
                        _formatValue(monthPf),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildHeaderLabel(String title, String sub) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFE8EEF7), borderRadius: BorderRadius.circular(8)),
      child: Text.rich(TextSpan(
        children: [
          TextSpan(text: title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D47A1))),
          TextSpan(text: '  $sub', style: const TextStyle(color: Colors.black54)),
        ],
      )),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey, size: 20),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          ],
        ))
      ],
    );
  }

  Widget _buildReadingItem(String label, String val, String imgLabel, String url) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(Icons.bolt, label, val),
        const SizedBox(height: 12),
        Text(imgLabel, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: url.isNotEmpty
              ? Image.network(
                  url,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 180,
                    width: double.infinity,
                    color: Colors.grey.shade200,
                    alignment: Alignment.center,
                    child: const Text('Image not available'),
                  ),
                )
              : Container(
                  height: 180,
                  width: double.infinity,
                  color: Colors.grey.shade200,
                  alignment: Alignment.center,
                  child: const Text('Image not available'),
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
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
      ],
    );
  }

  // String _formatValue(dynamic value) {
  //   if (value == null) return '—';
  //   if (value is num) return value.toStringAsFixed(4);
  //   return value.toString();
  // }

  String _formatValue(dynamic value) {
    if (value == null) return '—';
    if (value is num) return value.toStringAsFixed(4); // 👈 yaha change
    return value.toString();
  }
}