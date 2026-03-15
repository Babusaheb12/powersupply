part of 'addmeter_reading_bloc.dart';

@immutable
sealed class AddmeterReadingEvent {}

final class SubmitMeterReadingEvent extends AddmeterReadingEvent {
  final String userId;
  final String siteId;
  final String location;
  final String dateTime;
  final String kwhReading;
  final String kvahReading;
  final dynamic kwhImage;
  final dynamic kvahImage;
  
  SubmitMeterReadingEvent({
    required this.userId,
    required this.siteId,
    required this.location,
    required this.dateTime,
    required this.kwhReading,
    required this.kvahReading,
    this.kwhImage,
    this.kvahImage,
  });
}
