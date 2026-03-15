part of 'factory_reading_bloc.dart';

@immutable
sealed class FactoryReadingState {}

final class FactoryReadingInitial extends FactoryReadingState {}

final class FactoryReadingLoading extends FactoryReadingState {}

final class FactoryReadingSuccess extends FactoryReadingState {
  /// API response: { "site_id": int, "data": [ { "current_reading": {...}, "difference": {...}, "power_factor": ... } ] }
  final Map<String, dynamic> data;

  FactoryReadingSuccess(this.data);
}

final class FactoryReadingFailure extends FactoryReadingState {
  final String message;

  FactoryReadingFailure(this.message);
}

final class FactoryReadingNoInternet extends FactoryReadingState {}
