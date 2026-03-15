part of 'show_in_reading_bloc.dart';

@immutable
sealed class ShowInReadingEvent {}

final class FetchReadingsEvent extends ShowInReadingEvent {
  final String userId;
  
  FetchReadingsEvent({required this.userId});
}
