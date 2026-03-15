import 'dart:developer' as devloper;

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:developer' as developer;
import '../../../../../Api/Api_url.dart';
import '../../../../../Api/ConnectivityService.dart';

part 'addmeter_reading_event.dart';
part 'addmeter_reading_state.dart';

class AddmeterReadingBloc extends Bloc<AddmeterReadingEvent, AddmeterReadingState> {
  AddmeterReadingBloc() : super(AddmeterReadingInitial()) {
    on<SubmitMeterReadingEvent>(_onSubmitMeterReading);
  }

  Future<void> _onSubmitMeterReading(
    SubmitMeterReadingEvent event,
    Emitter<AddmeterReadingState> emit,
  ) async {
    emit(AddmeterReadingLoading());

    try {
      // Check internet connectivity
      devloper.log('🔵 Checking internet connectivity...', name: 'MeterReadingBloc');
      final isConnected = await ConnectivityService.isConnected();
      
      if (!isConnected) {
        devloper.log('❌ No internet connection', name: 'MeterReadingBloc');
        emit(AddmeterReadingNoInternet());
        return;
      }

      devloper.log('✅ Internet connection available', name: 'MeterReadingBloc');
      devloper.log('🔵 API Request URL: ${ApiUrls.siteReadingInsert}', name: 'MeterReadingBloc');
      devloper.log('📤 Submitting meter reading for User: ${event.userId}, Site: ${event.siteId}', name: 'MeterReadingBloc');

      // Prepare request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiUrls.siteReadingInsert),
      );

      // Add text fields
      request.fields['user_id'] = event.userId;
      request.fields['site_id'] = event.siteId;
      request.fields['location'] = event.location;
      request.fields['datetime'] = event.dateTime;
      request.fields['kwh_reading'] = event.kwhReading;
      request.fields['kvah_reading'] = event.kvahReading;

      // Add KWH image if exists
      if (event.kwhImage != null) {
        final kwhFile = event.kwhImage!;
        final kwhExists = await kwhFile.exists();
        final kwhSize = await kwhFile.length();
        
        devloper.log('📸 KWH Image exists: $kwhExists', name: 'MeterReadingBloc');
        devloper.log('📸 KWH Image path: ${kwhFile.path}', name: 'MeterReadingBloc');
        devloper.log('📸 KWH Image size: $kwhSize bytes', name: 'MeterReadingBloc');
        
        try {
          // Create multipart file with explicit JPEG content type
          final kwhMultipartFile = await http.MultipartFile.fromPath(
            'kwh_image',
            kwhFile.path,
            contentType: MediaType('image', 'jpeg'),
          );
          request.files.add(kwhMultipartFile);
          devloper.log('✅ KWH image added to request - Field: kwh_image, Filename: ${kwhMultipartFile.filename}, Size: ${kwhMultipartFile.length}, Type: ${kwhMultipartFile.contentType}', name: 'MeterReadingBloc');
        } catch (e) {
          devloper.log('❌ Error adding KWH image: $e', name: 'MeterReadingBloc');
        }
      } else {
        devloper.log('⚠️ No KWH image to attach', name: 'MeterReadingBloc');
      }

      // Add KVAH image if exists
      if (event.kvahImage != null) {
        final kvahFile = event.kvahImage!;
        final kvahExists = await kvahFile.exists();
        final kvahSize = await kvahFile.length();
        
        devloper.log('📸 KVAH Image exists: $kvahExists', name: 'MeterReadingBloc');
        devloper.log('📸 KVAH Image path: ${kvahFile.path}', name: 'MeterReadingBloc');
        devloper.log('📸 KVAH Image size: $kvahSize bytes', name: 'MeterReadingBloc');
        
        try {
          // Create multipart file with explicit JPEG content type
          final kvahMultipartFile = await http.MultipartFile.fromPath(
            'kvah_image',
            kvahFile.path,
            contentType: MediaType('image', 'jpeg'),
          );
          request.files.add(kvahMultipartFile);
          devloper.log('✅ KVAH image added to request - Field: kvah_image, Filename: ${kvahMultipartFile.filename}, Size: ${kvahMultipartFile.length}, Type: ${kvahMultipartFile.contentType}', name: 'MeterReadingBloc');
        } catch (e) {
          devloper.log('❌ Error adding KVAH image: $e', name: 'MeterReadingBloc');
        }
      } else {
        devloper.log('⚠️ No KVAH image to attach', name: 'MeterReadingBloc');
      }

      // Log request details
      devloper.log('📦 Total files in request: ${request.files.length}', name: 'MeterReadingBloc');
      devloper.log('📝 Total fields: ${request.fields.length}', name: 'MeterReadingBloc');
      for (var entry in request.fields.entries) {
        devloper.log('📝 Field: ${entry.key} = ${entry.value}', name: 'MeterReadingBloc');
      }
      for (var file in request.files) {
        devloper.log('📎 File - Field: ${file.field}, Name: ${file.filename}, Size: ${file.length} bytes, Type: ${file.contentType}', name: 'MeterReadingBloc');
      }

      // Send request
      devloper.log('🚀 Sending multipart request to server...', name: 'MeterReadingBloc');
      devloper.log('📡 Target URL: ${ApiUrls.siteReadingInsert}', name: 'MeterReadingBloc');
      
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      devloper.log('🟢 API Response Status Code: ${response.statusCode}', name: 'MeterReadingBloc');
      devloper.log('🟢 API Response Body: ${response.body}', name: 'MeterReadingBloc');

      // Parse response
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        
        if (jsonData['status'] == true) {
          devloper.log('✅ Meter reading submitted successfully!', name: 'MeterReadingBloc');
          devloper.log('📝 Inserted ID: ${jsonData['data']?['id'] ?? 'N/A'}', name: 'MeterReadingBloc');
          emit(AddmeterReadingSuccess(jsonData));
        } else {
          final errorMessage = jsonData['message'] ?? 'Failed to submit meter reading';
          devloper.log('❌ API Error: $errorMessage', name: 'MeterReadingBloc');
          emit(AddmeterReadingFailure(errorMessage));
        }
      } else {
        devloper.log('❌ HTTP Error: Status code ${response.statusCode}', name: 'MeterReadingBloc');
        emit(AddmeterReadingFailure('Server error: ${response.statusCode}'));
      }
    } catch (e) {
      devloper.log('❌ Exception in submitMeterReading: $e', name: 'MeterReadingBloc');
      devloper.log('❌ Stack trace: ${StackTrace.current}', name: 'MeterReadingBloc');
      emit(AddmeterReadingFailure('Network error: ${e.toString()}'));
    }
  }
}
