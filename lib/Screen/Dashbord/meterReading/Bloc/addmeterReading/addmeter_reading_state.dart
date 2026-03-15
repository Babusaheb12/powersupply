part of 'addmeter_reading_bloc.dart';

@immutable
sealed class AddmeterReadingState {}

final class AddmeterReadingInitial extends AddmeterReadingState {}

final class AddmeterReadingLoading extends AddmeterReadingState {}

final class AddmeterReadingSuccess extends AddmeterReadingState {
  final Map<String, dynamic> responseData;
  
  AddmeterReadingSuccess(this.responseData);
}

final class AddmeterReadingFailure extends AddmeterReadingState {
  final String message;
  
  AddmeterReadingFailure(this.message);
}

final class AddmeterReadingNoInternet extends AddmeterReadingState {}
