import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../../Api/Api_url.dart';

part 'site_list_event.dart';
part 'site_list_state.dart';

class SiteListBloc extends Bloc<SiteListEvent, SiteListState> {
  SiteListBloc() : super(SiteListInitial()) {
    on<FetchSiteListEvent>(_onFetchSiteList);
  }

  Future<void> _onFetchSiteList(
    FetchSiteListEvent event,
    Emitter<SiteListState> emit,
  ) async {
    emit(SiteListLoading());

    try {
      print('🔵 API Request: ${ApiUrls.siteList}');
      
      final response = await http.get(Uri.parse(ApiUrls.siteList));

      print('🟢 API Response Status Code: ${response.statusCode}');
      print('🟢 API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        
        if (jsonData['status'] == true) {
          final List<dynamic> data = jsonData['data'];
          final sites = data.map((item) => Map<String, dynamic>.from(item)).toList();
          
          print('✅ Site list fetched successfully. Total sites: ${sites.length}');
          emit(SiteListLoaded(sites));
        } else {
          final errorMessage = jsonData['message'] ?? 'Failed to fetch site list';
          print('❌ API Error: $errorMessage');
          emit(SiteListError(errorMessage));
        }
      } else {
        print('❌ HTTP Error: Status code ${response.statusCode}');
        emit(SiteListError('Failed to fetch site list: ${response.statusCode}'));
      }
    } catch (e) {
      print('❌ Exception: $e');
      emit(SiteListError('Network error: ${e.toString()}'));
    }
  }
}
