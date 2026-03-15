import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../../../../../Api/Api_url.dart';
import '../../../../../Api/ConnectivityService.dart';

part 'show_in_reading_event.dart';
part 'show_in_reading_state.dart';

class ShowInReadingBloc extends Bloc<ShowInReadingEvent, ShowInReadingState> {
  ShowInReadingBloc() : super(ShowInReadingInitial()) {
    on<FetchReadingsEvent>(_onFetchReadings);
  }

  Future<void> _onFetchReadings(
    FetchReadingsEvent event,
    Emitter<ShowInReadingState> emit,
  ) async {
    emit(ShowInReadingLoading());

    try {
      // Check internet connectivity
      developer.log('🔵 Checking internet connectivity...', name: 'ShowInReadingBloc');
      final isConnected = await ConnectivityService.isConnected();
      
      if (!isConnected) {
        developer.log('❌ No internet connection', name: 'ShowInReadingBloc');
        emit(ShowInReadingNoInternet());
        return;
      }

      developer.log('✅ Internet connection available', name: 'ShowInReadingBloc');
      developer.log('🔵 API Request URL: ${ApiUrls.siteReadinglist}', name: 'ShowInReadingBloc');
      developer.log('📤 Fetching readings for User: ${event.userId}', name: 'ShowInReadingBloc');

      // Prepare request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiUrls.siteReadinglist),
      );

      // Add user_id parameter
      request.fields['user_id'] = event.userId;

      // Send request
      developer.log('🚀 Sending request to server...', name: 'ShowInReadingBloc');
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      developer.log('🟢 API Response Status Code: ${response.statusCode}', name: 'ShowInReadingBloc');
      developer.log('🟢 API Response Body: ${response.body}', name: 'ShowInReadingBloc');

      // Parse response
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        
        if (jsonData['status'] == true) {
          final List<dynamic> data = jsonData['data'];
          final readings = data.map((item) => Map<String, dynamic>.from(item)).toList();
          
          developer.log('✅ Readings fetched successfully! Total: ${readings.length}', name: 'ShowInReadingBloc');
          emit(ShowInReadingSuccess(readings));
        } else {
          final errorMessage = jsonData['message'] ?? 'Failed to fetch readings';
          developer.log('❌ API Error: $errorMessage', name: 'ShowInReadingBloc');
          emit(ShowInReadingFailure(errorMessage));
        }
      } else {
        developer.log('❌ HTTP Error: Status code ${response.statusCode}', name: 'ShowInReadingBloc');
        emit(ShowInReadingFailure('Server error: ${response.statusCode}'));
      }
    } catch (e) {
      developer.log('❌ Exception in fetchReadings: $e', name: 'ShowInReadingBloc');
      developer.log('❌ Stack trace: ${StackTrace.current}', name: 'ShowInReadingBloc');
      emit(ShowInReadingFailure('Network error: ${e.toString()}'));
    }
  }
}
