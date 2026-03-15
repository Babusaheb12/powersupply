part of 'login_bloc.dart';

class LoginEvent {}

class LoginSubmitted extends LoginEvent {
  final String phone;
  final String password;

  LoginSubmitted({required this.phone, required this.password});
}
