class ApiUrls {
  // BASE URL
/// local url
//   static const baseUrl = 'https://thepehchan.shop/Nice/api/';

  /// live url
  static const baseUrl = 'https://acunec.com/websites/Power-ut/api/';

  //
//
  // add in google map key

  static const kGoogleApiKey = "AIzaSyCzU4XQ6D43-mEnHWZ5l3vobePxE6p2GRw";

  // end point
  static const login = '${baseUrl}login.php';
  static const siteList = '${baseUrl}site_list.php';
  static const siteReadingInsert = '${baseUrl}site_reading_insert.php';
  static const siteReadinglist= '${baseUrl}site_readings_list.php';  //
  static const ShowInReading = '${baseUrl}site_reading_difference.php'; 

  // store reading add api
  static const storeReadingInsert = '${baseUrl}month_reading_insert.php';
  static const storeReading = '${baseUrl}month_reading_list.php';
  static const storeReadingimg = '${baseUrl}month_reading_difference.php';

  /// logout
  static const logout = '${baseUrl}logout.php';

}