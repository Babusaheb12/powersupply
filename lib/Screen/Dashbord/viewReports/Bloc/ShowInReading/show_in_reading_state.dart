part of 'show_in_reading_bloc.dart';

@immutable
sealed class ShowInReadingState {}

final class ShowInReadingInitial extends ShowInReadingState {}

final class ShowInReadingLoading extends ShowInReadingState {}

final class ShowInReadingSuccess extends ShowInReadingState {
  final List<Map<String, dynamic>> readings;
  
  ShowInReadingSuccess(this.readings);
}

final class ShowInReadingFailure extends ShowInReadingState {
  final String message;
  
  ShowInReadingFailure(this.message);
}

final class ShowInReadingNoInternet extends ShowInReadingState {}
