part of 'store_reading_bloc.dart';

@immutable
sealed class StoreReadingState {}

final class StoreReadingInitial extends StoreReadingState {}

final class StoreReadingLoading extends StoreReadingState {}

final class StoreReadingSuccess extends StoreReadingState {
  final Map<String, dynamic> responseData;

  StoreReadingSuccess(this.responseData);
}

final class StoreReadingFailure extends StoreReadingState {
  final String message;

  StoreReadingFailure(this.message);
}

final class StoreReadingNoInternet extends StoreReadingState {}
