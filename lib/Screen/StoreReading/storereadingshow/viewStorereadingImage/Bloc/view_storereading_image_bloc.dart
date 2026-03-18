import 'dart:developer' as developer;
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../../../Api/Api_url.dart';
import '../../../../../../Api/ConnectivityService.dart';

part 'view_storereading_image_event.dart';
part 'view_storereading_image_state.dart';

class ViewStorereadingImageBloc extends Bloc<ViewStorereadingImageEvent, ViewStorereadingImageState> {
  ViewStorereadingImageBloc() : super(ViewStorereadingImageInitial()) {
    on<FetchStoreReadingImageEvent>(_onFetchStoreReadingImage);
  }

  Future<void> _onFetchStoreReadingImage(
    FetchStoreReadingImageEvent event,
    Emitter<ViewStorereadingImageState> emit,
  ) async {
    emit(ViewStorereadingImageLoading());

    try {
      // Check internet connectivity
      developer.log('🔵 Checking internet connectivity...', name: 'ViewStoreReadingImageBloc');
      final isConnected = await ConnectivityService.isConnected();

      if (!isConnected) {
        developer.log('❌ No internet connection', name: 'ViewStoreReadingImageBloc');
        emit(ViewStorereadingImageNoInternet());
        return;
      }

      developer.log('✅ Internet connection available', name: 'ViewStoreReadingImageBloc');
      developer.log('🔵 API Request URL: ${ApiUrls.storeReadingimg}', name: 'ViewStoreReadingImageBloc');
      developer.log('📤 Fetching store reading images for Site ID: ${event.siteId}', name: 'ViewStoreReadingImageBloc');

      // Prepare request with form data
      final requestBody = <String, String>{
        'site_id': event.siteId,
      };
      
      developer.log('📝 Request Headers: Content-Type: application/x-www-form-urlencoded', name: 'ViewStoreReadingImageBloc');
      developer.log('📝 Request Body: site_id=${event.siteId}', name: 'ViewStoreReadingImageBloc');

      final response = await http.post(
        Uri.parse(ApiUrls.storeReadingimg),
        headers: <String, String>{
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: requestBody,
      );

      developer.log('🟢 API Response Status Code: ${response.statusCode}', name: 'ViewStoreReadingImageBloc');
      developer.log('🟢 API Response Body: ${response.body}', name: 'ViewStoreReadingImageBloc');

      // Parse response
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['status'] == true) {
          developer.log('✅ Store reading images fetched successfully!', name: 'ViewStoreReadingImageBloc');
          final List<dynamic> readingsData = jsonData['data'] ?? [];
          developer.log('📊 Total readings received: ${readingsData.length}', name: 'ViewStoreReadingImageBloc');
          emit(ViewStorereadingImageSuccess(jsonData));
        } else {
          final errorMessage = jsonData['message'] ?? 'Failed to fetch store reading images';
          developer.log('❌ API Error: $errorMessage', name: 'ViewStoreReadingImageBloc');
          emit(ViewStorereadingImageFailure(errorMessage));
        }
      } else {
        developer.log('❌ HTTP Error: Status code ${response.statusCode}', name: 'ViewStoreReadingImageBloc');
        emit(ViewStorereadingImageFailure('Server error: ${response.statusCode}'));
      }
    } catch (e) {
      developer.log('❌ Exception in fetchStoreReadingImages: $e', name: 'ViewStoreReadingImageBloc');
      developer.log('❌ Stack trace: ${StackTrace.current}', name: 'ViewStoreReadingImageBloc');
      emit(ViewStorereadingImageFailure('Network error: ${e.toString()}'));
    }
  }
}
