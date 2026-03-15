import 'dart:convert';
import 'dart:developer' as developer;

import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../../../../Api/Api_url.dart';
import '../../../../../Api/shared_preference.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    try {
      // Emit loading state
      emit(LoginLoading());

      // Check network connectivity
      developer.log('📡 Checking network connectivity...', name: 'LoginBloc');
      final connectivityResult = await Connectivity().checkConnectivity();
      final isConnected = connectivityResult != ConnectivityResult.none;
      
      if (!isConnected) {
        developer.log('❌ No internet connection', name: 'LoginBloc');
        emit(LoginFailure(error: 'No internet connection. Please check your network.'));
        return;
      }

      developer.log('✅ Network connected', name: 'LoginBloc');

      // Prepare API request
      developer.log('🔗 API URL: $ApiUrls.login', name: 'LoginBloc');
      
      developer.log('📤 Login Request - Phone: ${event.phone}, Password: ${event.password}', 
          name: 'LoginBloc');

      // Make API call with form-data
      final response = await http.post(
        Uri.parse(ApiUrls.login),
        body: {
          'phone': event.phone,
          'password': event.password,  // Changed from 'Password' to 'password' (lowercase)
        },
      );

      // Log response
      developer.log('📥 API Response Status: ${response.statusCode}', name: 'LoginBloc');
      developer.log('📥 API Response Body: ${response.body}', name: 'LoginBloc');

      // Handle response
      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final responseData = json.decode(response.body);
          
          developer.log('✅ Decoded Response: $responseData', name: 'LoginBloc');

          // Check if login was successful based on API response structure
          if (responseData is Map<String, dynamic>) {
            // Check the status field from API response
            final status = responseData['status'];
            
            if (status == true || status == 'true' || responseData.containsKey('token')) {
              // Login successful
              // Extract user data from 'data' field if it exists, otherwise use the whole response
              Map<String, dynamic> userData;
              
              if (responseData.containsKey('data') && responseData['data'] is Map<String, dynamic>) {
                userData = responseData['data'];
              } else {
                userData = responseData;
              }
              
              // Save user data using Prefs helper
              await Prefs.saveUserData(userData);

              developer.log('✅ User data saved to SharedPreferences', name: 'LoginBloc');
              developer.log('🎉 Login Successful!', name: 'LoginBloc');
              
              emit(LoginSuccess(userData: userData));
            } else {
              // Login failed - API returned status: false
              final message = responseData['message'] ?? 'Login failed';
              developer.log('❌ Login failed: $message', name: 'LoginBloc');
              emit(LoginFailure(error: message));
            }
          } else {
            developer.log('⚠️ Unexpected response format', name: 'LoginBloc');
            emit(LoginFailure(error: 'Unexpected response format from server'));
          }
        } catch (e) {
          developer.log('❌ Error parsing response: $e', name: 'LoginBloc');
          emit(LoginFailure(error: 'Failed to parse server response: $e'));
        }
      } else {
        developer.log('❌ Login failed with status: ${response.statusCode}', name: 'LoginBloc');
        emit(LoginFailure(error: 'Login failed. Status: ${response.statusCode}'));
      }
    } catch (e) {
      developer.log('❌ Exception occurred: $e', name: 'LoginBloc');
      emit(LoginFailure(error: 'An error occurred: $e'));
    }
  }
}
