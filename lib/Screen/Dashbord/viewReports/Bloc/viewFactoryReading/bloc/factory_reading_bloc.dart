import 'dart:convert';
import 'dart:developer' as developer;

import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

import '../../../../../../Api/Api_url.dart';
import '../../../../../../Api/ConnectivityService.dart';

part 'factory_reading_event.dart';
part 'factory_reading_state.dart';

class FactoryReadingBloc extends Bloc<FactoryReadingEvent, FactoryReadingState> {
  FactoryReadingBloc() : super(FactoryReadingInitial()) {
    on<FetchFactoryReadingEvent>(_onFetchFactoryReading);
  }

  Future<void> _onFetchFactoryReading(
    FetchFactoryReadingEvent event,
    Emitter<FactoryReadingState> emit,
  ) async {
    emit(FactoryReadingLoading());

    try {
      developer.log('🔵 Checking internet connectivity...', name: 'FactoryReadingBloc');
      final isConnected = await ConnectivityService.isConnected();

      if (!isConnected) {
        developer.log('❌ No internet connection', name: 'FactoryReadingBloc');
        emit(FactoryReadingNoInternet());
        return;
      }

      developer.log('✅ Internet connection available', name: 'FactoryReadingBloc');
      developer.log('🔵 API Request URL: ${ApiUrls.ShowInReading}', name: 'FactoryReadingBloc');
      developer.log('📤 Request body: site_id = ${event.siteId}', name: 'FactoryReadingBloc');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiUrls.ShowInReading),
      );
      request.fields['site_id'] = event.siteId;

      developer.log('🚀 Sending request to server...', name: 'FactoryReadingBloc');
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      developer.log('🟢 API Response Status Code: ${response.statusCode}', name: 'FactoryReadingBloc');
      developer.log('🟢 API Response Body: ${response.body}', name: 'FactoryReadingBloc');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;

        if (jsonData['status'] == true) {
          final data = Map<String, dynamic>.from(jsonData);
          developer.log('✅ Factory reading fetched successfully for site_id: ${event.siteId}', name: 'FactoryReadingBloc');
          emit(FactoryReadingSuccess(data));
        } else {
          final errorMessage = jsonData['message']?.toString() ?? 'Failed to fetch factory reading';
          developer.log('❌ API Error: $errorMessage', name: 'FactoryReadingBloc');
          emit(FactoryReadingFailure(errorMessage));
        }
      } else {
        developer.log('❌ HTTP Error: Status code ${response.statusCode}', name: 'FactoryReadingBloc');
        emit(FactoryReadingFailure('Server error: ${response.statusCode}'));
      }
    } catch (e) {
      developer.log('❌ Exception in fetchFactoryReading: $e', name: 'FactoryReadingBloc');
      developer.log('❌ Stack trace: ${StackTrace.current}', name: 'FactoryReadingBloc');
      emit(FactoryReadingFailure('Network error: ${e.toString()}'));
    }
  }
}
