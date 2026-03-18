part of 'view_storereading_image_bloc.dart';

@immutable
sealed class ViewStorereadingImageEvent {}

final class FetchStoreReadingImageEvent extends ViewStorereadingImageEvent {
  final String siteId;

  FetchStoreReadingImageEvent({required this.siteId});
}
