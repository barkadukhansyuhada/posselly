import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  
  const Failure(this.message);
  
  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  final int? statusCode;
  
  const ServerFailure({
    required String message,
    this.statusCode,
  }) : super(message);
  
  @override
  List<Object> get props => [message, statusCode ?? 0];
}

class AuthFailure extends Failure {
  const AuthFailure(String message) : super(message);
}

class CacheFailure extends Failure {
  const CacheFailure(String message) : super(message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(String message) : super(message);
}

class ValidationFailure extends Failure {
  final Map<String, String>? errors;
  
  const ValidationFailure({
    required String message,
    this.errors,
  }) : super(message);
  
  @override
  List<Object> get props => [message, errors ?? {}];
}

class PdfGenerationFailure extends Failure {
  const PdfGenerationFailure(String message) : super(message);
}

class KeyboardServiceFailure extends Failure {
  const KeyboardServiceFailure(String message) : super(message);
}