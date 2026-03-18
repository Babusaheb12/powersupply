import 'dart:developer' as devloper;

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image/image.dart' as img;
import '../../../../../Api/Api_url.dart';
import '../../../../../Api/ConnectivityService.dart';

part 'store_meter_reading_event.dart';
part 'store_meter_reading_state.dart';

/// Max dimension for upload (keeps meter readable, stays under PHP post_max_size).
const int _kMaxImageDimension = 1920;
const int _kJpegQuality = 85;

class StoreMeterReadingBloc extends Bloc<StoreMeterReadingEvent, StoreMeterReadingState> {
  StoreMeterReadingBloc() : super(StoreMeterReadingInitial()) {
    on<MeterReadingEvent>(_onSubmitMeterReading);
  }

  /// Compress image so total request stays under PHP post_max_size (e.g. 8MB).
  Future<List<int>> _compressImage(File file) async {
      final bytes = await file.readAsBytes();
      img.Image? image = img.decodeImage(bytes);
      if (image == null) return bytes;
      if (image.width > _kMaxImageDimension || image.height > _kMaxImageDimension) {
        if (image.width >= image.height) {
          image = img.copyResize(image, width: _kMaxImageDimension);
        } else {
          image = img.copyResize(image, height: _kMaxImageDimension);
        }
      }
      return img.encodeJpg(image, quality: _kJpegQuality) ?? bytes;
    }

  Future<void> _onSubmitMeterReading(
    MeterReadingEvent event,
    Emitter<StoreMeterReadingState> emit,
  ) async {
    emit(StoreMeterReadingLoading());

    try {
        // Check internet connectivity
        devloper.log('🔵 Checking internet connectivity...', name: 'MeterReadingBloc');
        final isConnected = await ConnectivityService.isConnected();

        if (!isConnected) {
          devloper.log('❌ No internet connection', name: 'MeterReadingBloc');
          emit(StoreMeterReadingNoInternet());
          return;
        }

        devloper.log('✅ Internet connection available', name: 'MeterReadingBloc');
        devloper.log('🔵 API Request URL: ${ApiUrls.storeReadingInsert}', name: 'StoreMeterReadingBloc');
        devloper.log('📤 Submitting meter reading for User: ${event.userId}, Site: ${event.siteId}', name: 'StoreMeterReadingBloc');

        // Prepare request
        var request = http.MultipartRequest(
          'POST',
          Uri.parse(ApiUrls.storeReadingInsert),
        );

        // Add text fields
        request.fields['user_id'] = event.userId;
        request.fields['site_id'] = event.siteId;
        request.fields['location'] = event.location;
        request.fields['datetime'] = event.dateTime;
        request.fields['kwh_reading'] = event.kwhReading;
        request.fields['kvah_reading'] = event.kvahReading;

        // Add KWH image if exists (read as bytes so form-data is sent reliably; fromPath can fail on Android at send time)
        if (event.kwhImage != null) {
          final kwhFile = event.kwhImage! as File;
          final kwhExists = await kwhFile.exists();
          final kwhSize = await kwhFile.length();

          devloper.log('📸 KWH Image exists: $kwhExists', name: 'StoreMeterReadingBloc');
          devloper.log('📸 KWH Image path: ${kwhFile.path}', name: 'StoreMeterReadingBloc');
          devloper.log('📸 KWH Image size: $kwhSize bytes', name: 'StoreMeterReadingBloc');

          try {
            final kwhBytes = await _compressImage(kwhFile);
            final kwhFilename = kwhFile.path.split('/').last;
            final kwhName = (kwhFilename.isNotEmpty && (kwhFilename.toLowerCase().endsWith('.jpg') || kwhFilename.toLowerCase().endsWith('.jpeg')))
                ? kwhFilename
                : 'kwh_image.jpg';
            final kwhMultipartFile = http.MultipartFile.fromBytes(
              'kwh_image',
              kwhBytes,
              filename: kwhName,
              contentType: MediaType('image', 'jpeg'),
            );
            request.files.add(kwhMultipartFile);
            devloper.log('✅ KWH image added to request (compressed) - Field: kwh_image, Filename: ${kwhMultipartFile.filename}, Size: ${kwhBytes.length}, Type: ${kwhMultipartFile.contentType}', name: 'StoreMeterReadingBloc');
          } catch (e) {
            devloper.log('❌ Error adding KWH image: $e', name: 'StoreMeterReadingBloc');
          }
        } else {
          devloper.log('⚠️ No KWH image to attach', name: 'StoreMeterReadingBloc');
        }

        // Add KVAH image if exists (read as bytes so form-data is sent reliably)
        if (event.kvahImage != null) {
          final kvahFile = event.kvahImage! as File;
          final kvahExists = await kvahFile.exists();
          final kvahSize = await kvahFile.length();

          devloper.log('📸 KVAH Image exists: $kvahExists', name: 'StoreMeterReadingBloc');
          devloper.log('📸 KVAH Image path: ${kvahFile.path}', name: 'StoreMeterReadingBloc');
          devloper.log('📸 KVAH Image size: $kvahSize bytes', name: 'StoreMeterReadingBloc');

          try {
            final kvahBytes = await _compressImage(kvahFile);
            final kvahFilename = kvahFile.path.split('/').last;
            final kvahName = (kvahFilename.isNotEmpty && (kvahFilename.toLowerCase().endsWith('.jpg') || kvahFilename.toLowerCase().endsWith('.jpeg')))
                ? kvahFilename
                : 'kvah_image.jpg';
            final kvahMultipartFile = http.MultipartFile.fromBytes(
              'kvah_image',
              kvahBytes,
              filename: kvahName,
              contentType: MediaType('image', 'jpeg'),
            );
            request.files.add(kvahMultipartFile);
            devloper.log('✅ KVAH image added to request (compressed) - Field: kvah_image, Filename: ${kvahMultipartFile.filename}, Size: ${kvahBytes.length}, Type: ${kvahMultipartFile.contentType}', name: 'StoreMeterReadingBloc');
          } catch (e) {
            devloper.log('❌ Error adding KVAH image: $e', name: 'StoreMeterReadingBloc');
          }
        } else {
          devloper.log('⚠️ No KVAH image to attach', name: 'StoreMeterReadingBloc');
        }

        // Log request details
        devloper.log('📦 Total files in request: ${request.files.length}', name: 'StoreMeterReadingBloc');
        devloper.log('📝 Total fields: ${request.fields.length}', name: 'StoreMeterReadingBloc');
        for (var entry in request.fields.entries) {
          devloper.log('📝 Field: ${entry.key} = ${entry.value}', name: 'StoreMeterReadingBloc');
        }
        for (var file in request.files) {
          devloper.log('📎 File - Field: ${file.field}, Name: ${file.filename}, Size: ${file.length} bytes, Type: ${file.contentType}', name: 'StoreMeterReadingBloc');
        }

        // Send request
        devloper.log('🚀 Sending multipart request to server...', name: 'StoreMeterReadingBloc');
        devloper.log('📡 Target URL: ${ApiUrls.storeReadingInsert}', name: 'StoreMeterReadingBloc');

        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);

        devloper.log('🟢 API Response Status Code: ${response.statusCode}', name: 'StoreMeterReadingBloc');
        devloper.log('🟢 API Response Body: ${response.body}', name: 'StoreMeterReadingBloc');

        // Parse response
        if (response.statusCode == 200) {
          final jsonData = json.decode(response.body);

          if (jsonData['status'] == true) {
            devloper.log('✅ Meter reading submitted successfully!', name: 'StoreMeterReadingBloc');
            devloper.log('📝 Inserted ID: ${jsonData['data']?['id'] ?? 'N/A'}', name: 'StoreMeterReadingBloc');
            emit(StoreMeterReadingSuccess(jsonData));
          } else {
            final errorMessage = jsonData['message'] ?? 'Failed to submit meter reading';
            devloper.log('❌ API Error: $errorMessage', name: 'StoreMeterReadingBloc');
            emit(StoreMeterReadingFailure(errorMessage));
          }
        } else {
          devloper.log('❌ HTTP Error: Status code ${response.statusCode}', name: 'StoreMeterReadingBloc');
          emit(StoreMeterReadingFailure('Server error: ${response.statusCode}'));
        }
      } catch (e) {
        devloper.log('❌ Exception in submitMeterReading: $e', name: 'StoreMeterReadingBloc');
        devloper.log('❌ Stack trace: ${StackTrace.current}', name: 'StoreMeterReadingBloc');
        emit(StoreMeterReadingFailure('Network error: ${e.toString()}'));
      }
    }
  }
