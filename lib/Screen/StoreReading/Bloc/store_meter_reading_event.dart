part of 'store_meter_reading_bloc.dart';

@immutable
sealed class StoreMeterReadingEvent {}


final class MeterReadingEvent extends StoreMeterReadingEvent {
  final String userId;
  final String siteId;
  final String location;
  final String dateTime;
  final String kwhReading;
  final String kvahReading;
  final dynamic kwhImage;
  final dynamic kvahImage;

   MeterReadingEvent({
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
