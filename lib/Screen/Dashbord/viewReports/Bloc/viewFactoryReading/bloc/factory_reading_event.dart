part of 'factory_reading_bloc.dart';

@immutable
sealed class FactoryReadingEvent {}

/// Fetches factory/site reading difference for the given [siteId].
final class FetchFactoryReadingEvent extends FactoryReadingEvent {
  final String siteId;

  FetchFactoryReadingEvent({required this.siteId});
}
