part of 'view_storereading_image_bloc.dart';

@immutable
sealed class ViewStorereadingImageState {}

final class ViewStorereadingImageInitial extends ViewStorereadingImageState {}

final class ViewStorereadingImageLoading extends ViewStorereadingImageState {}

final class ViewStorereadingImageSuccess extends ViewStorereadingImageState {
  final Map<String, dynamic> responseData;

  ViewStorereadingImageSuccess(this.responseData);
}

final class ViewStorereadingImageFailure extends ViewStorereadingImageState {
  final String message;

  ViewStorereadingImageFailure(this.message);
}

final class ViewStorereadingImageNoInternet extends ViewStorereadingImageState {}
