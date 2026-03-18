import 'dart:developer' as developer;
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../../../Api/Api_url.dart';
import '../../../../../../Api/ConnectivityService.dart';

part 'store_reading_event.dart';
part 'store_reading_state.dart';

class StoreReadingBloc extends Bloc<StoreReadingEvent, StoreReadingState> {
  StoreReadingBloc() : super(StoreReadingInitial()) {
    on<FetchStoreReadingsEvent>(_onFetchStoreReadings);
  }

  Future<void> _onFetchStoreReadings(
    FetchStoreReadingsEvent event,
    Emitter<StoreReadingState> emit,
  ) async {
    emit(StoreReadingLoading());

    try {
      // Check internet connectivity
      developer.log('🔵 Checking internet connectivity...', name: 'StoreReadingBloc');
      final isConnected = await ConnectivityService.isConnected();

      if (!isConnected) {
        developer.log('❌ No internet connection', name: 'StoreReadingBloc');
        emit(StoreReadingNoInternet());
        return;
      }

      developer.log('✅ Internet connection available', name: 'StoreReadingBloc');
      developer.log('🔵 API Request URL: ${ApiUrls.storeReading}', name: 'StoreReadingBloc');
      developer.log('📤 Fetching store readings for User ID: ${event.userId}', name: 'StoreReadingBloc');

      // Prepare request with form data
      final requestBody = <String, String>{
        'user_id': event.userId,
      };
      
      developer.log('📝 Request Headers: Content-Type: application/x-www-form-urlencoded', name: 'StoreReadingBloc');
      developer.log('📝 Request Body: user_id=${event.userId}', name: 'StoreReadingBloc');

      final response = await http.post(
        Uri.parse(ApiUrls.storeReading),
        headers: <String, String>{
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: requestBody,
      );

      developer.log('🟢 API Response Status Code: ${response.statusCode}', name: 'StoreReadingBloc');
      developer.log('🟢 API Response Body: ${response.body}', name: 'StoreReadingBloc');

      // Parse response
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['status'] == true) {
          developer.log('✅ Store readings fetched successfully!', name: 'StoreReadingBloc');
          final List<dynamic> readingsData = jsonData['data'] ?? [];
          developer.log('📊 Total readings received: ${readingsData.length}', name: 'StoreReadingBloc');
          emit(StoreReadingSuccess(jsonData));
        } else {
          final errorMessage = jsonData['message'] ?? 'Failed to fetch store readings';
          developer.log('❌ API Error: $errorMessage', name: 'StoreReadingBloc');
          emit(StoreReadingFailure(errorMessage));
        }
      } else {
        developer.log('❌ HTTP Error: Status code ${response.statusCode}', name: 'StoreReadingBloc');
        emit(StoreReadingFailure('Server error: ${response.statusCode}'));
      }
    } catch (e) {
      developer.log('❌ Exception in fetchStoreReadings: $e', name: 'StoreReadingBloc');
      developer.log('❌ Stack trace: ${StackTrace.current}', name: 'StoreReadingBloc');
      emit(StoreReadingFailure('Network error: ${e.toString()}'));
    }
  }
}
