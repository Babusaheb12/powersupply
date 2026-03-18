part of 'store_reading_bloc.dart';

@immutable
sealed class StoreReadingEvent {}

final class FetchStoreReadingsEvent extends StoreReadingEvent {
  final String userId;

  FetchStoreReadingsEvent({required this.userId});
}
