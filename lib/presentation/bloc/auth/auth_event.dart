import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

class AuthRegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String businessName;
  final String? phone;

  const AuthRegisterRequested({
    required this.email,
    required this.password,
    required this.businessName,
    this.phone,
  });

  @override
  List<Object?> get props => [email, password, businessName, phone];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class AuthUpdateProfileRequested extends AuthEvent {
  final String? businessName;
  final String? phone;

  const AuthUpdateProfileRequested({
    this.businessName,
    this.phone,
  });

  @override
  List<Object?> get props => [businessName, phone];
}