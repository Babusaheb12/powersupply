part of 'site_list_bloc.dart';

@immutable
sealed class SiteListState {}

final class SiteListInitial extends SiteListState {}

final class SiteListLoading extends SiteListState {}

final class SiteListLoaded extends SiteListState {
  final List<Map<String, dynamic>> sites;
  
  SiteListLoaded(this.sites);
}

final class SiteListError extends SiteListState {
  final String message;
  
  SiteListError(this.message);
}
