import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'Bloc/ShowInReading/show_in_reading_bloc.dart';
import '../../../Api/shared_preference.dart';
import 'Bloc/viewFactoryReading/viewFactoryReading.dart';

class ShowInReadingScreen extends StatelessWidget {
  final Function(int)? onNavigateToProfile;

   ShowInReadingScreen({super.key, this.onNavigateToProfile});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ShowInReadingBloc()..add(FetchReadingsEvent(userId: Prefs.userId ?? '')),
      child: _ShowInReadingScreenView(),
    );
  }
}

class _ShowInReadingScreenView extends StatelessWidget {
   _ShowInReadingScreenView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,

      appBar: AppBar(
        backgroundColor:  Color(0xFF1E4FA1),
        title:  Text(
          "Reports",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme:  IconThemeData(color: Colors.white),
      ),

      body: BlocBuilder<ShowInReadingBloc, ShowInReadingState>(
        builder: (context, state) {
          if (state is ShowInReadingInitial || state is ShowInReadingLoading) {
            return  Center(child: CircularProgressIndicator());
          } else if (state is ShowInReadingSuccess) {
            final readings = state.readings;
            
            if (readings.isEmpty) {
              return  Center(
                child: Text(
                  "No meter readings found",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }
            
            return Column(
              children: [
                /// Search Box
                Padding(
                  padding:  EdgeInsets.all(16),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search factories...",
                      prefixIcon:  Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:  EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                /// List
                Expanded(
                  child: ListView.builder(
                    padding:  EdgeInsets.symmetric(horizontal: 16),
                    itemCount: readings.length,
                    itemBuilder: (context, index) {
                      final reading = readings[index];
                      final siteId = reading['site_id'] ?? '';
                      
                      return GestureDetector(
                        onTap: () {
                          // Navigate to ViewFactoryReading with site_id
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ViewFactoryReading(
                                siteId: siteId,
                                siteName: reading['site_name'] ?? 'Unknown Site',
                              ),
                            ),
                          );
                        },
                        child: ReportCard(
                          title: reading['site_name'] ?? 'Unknown Site',
                          location: reading['location'] ?? '',
                          date: reading['datetime'] ?? '',
                          kwh: reading['kwh_reading'] ?? 'N/A',
                          kvah: reading['kvah_reading'] ?? 'N/A',
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          } else if (state is ShowInReadingFailure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(Icons.error_outline, color: Colors.red, size: 48),
                   SizedBox(height: 16),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style:  TextStyle(color: Colors.red),
                  ),
                   SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ShowInReadingBloc>().add(
                        FetchReadingsEvent(userId: Prefs.userId ?? ''),
                      );
                    },
                    child:  Text("Retry"),
                  )
                ],
              ),
            );
          } else if (state is ShowInReadingNoInternet) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(Icons.wifi_off, color: Colors.orange, size: 48),
                   SizedBox(height: 16),
                   Text(
                    "No internet connection",
                    style: TextStyle(fontSize: 16, color: Colors.orange),
                  ),
                   SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ShowInReadingBloc>().add(
                        FetchReadingsEvent(userId: Prefs.userId ?? ''),
                      );
                    },
                    child:  Text("Retry"),
                  )
                ],
              ),
            );
          }
          
          return  SizedBox.shrink();
        },
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

   ReportCard({super.key, required this.title, required this.location, required this.date, required this.kwh, required this.kvah,});

  @override
  Widget build(BuildContext context) {

    return Container(
      margin:  EdgeInsets.only(bottom: 16),
      padding:  EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Title Row
          Row(
            children: [
               Icon(
                Icons.business,
                color: Colors.blue,
                size: 28,
              ),
               SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style:  TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )

            ],
          ),

           SizedBox(height: 10),

          /// Location
          Row(
            children: [

               Icon(Icons.location_on, size: 18, color: Colors.grey),

               SizedBox(width: 6),

              Expanded(
                child: Text(
                  location,
                  style:  TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                  ),
                ),
              )

            ],
          ),

           SizedBox(height: 6),

          /// Date
          Row(
            children: [

               Icon(Icons.calendar_today, size: 16, color: Colors.grey),

               SizedBox(width: 6),

              Text(
                "Date: $date",
                style:  TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                ),
              )

            ],
          ),

           SizedBox(height: 8),

          /// Reading
          Text(
            "KWH: $kwh    KVAH: $kvah",
            style:  TextStyle(
              fontWeight: FontWeight.w500,
            ),
          )

        ],
      ),
    );
  }
}