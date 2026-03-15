part of 'login_bloc.dart';

class LoginState {}

final class LoginInitial extends LoginState {}

final class LoginLoading extends LoginState {}

final class LoginSuccess extends LoginState {
  final Map<String, dynamic> userData;

  LoginSuccess({required this.userData});
}

final class LoginFailure extends LoginState {
  final String error;

  LoginFailure({required this.error});
}
