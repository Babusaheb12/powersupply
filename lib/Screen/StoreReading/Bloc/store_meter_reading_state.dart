part of 'store_meter_reading_bloc.dart';

@immutable
sealed class StoreMeterReadingState {}

final class StoreMeterReadingInitial extends StoreMeterReadingState {}



final class StoreMeterReadingLoading extends StoreMeterReadingState {}

final class StoreMeterReadingSuccess extends StoreMeterReadingState {
  final Map<String, dynamic> responseData;

  StoreMeterReadingSuccess(this.responseData);
}

final class StoreMeterReadingFailure extends StoreMeterReadingState {
  final String message;

  StoreMeterReadingFailure(this.message);
}

final class StoreMeterReadingNoInternet extends StoreMeterReadingState {}
