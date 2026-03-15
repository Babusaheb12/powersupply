part of 'site_list_bloc.dart';

@immutable
sealed class SiteListEvent {}

final class FetchSiteListEvent extends SiteListEvent {}
