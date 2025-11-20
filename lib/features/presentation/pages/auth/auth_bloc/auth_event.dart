abstract class AuthEvent {}

class AuthLoginEvent extends AuthEvent {
  final String email;
  final String password;

  AuthLoginEvent(this.email, this.password);
}

class AuthRegisterEvent extends AuthEvent {
  final String email;
  final String password;

  AuthRegisterEvent(this.email, this.password);
}

class AuthLogoutEvent extends AuthEvent {}

class AuthEmailChanged extends AuthEvent {
  final String email;

  AuthEmailChanged(this.email);
}

class AuthPasswordChanged extends AuthEvent {
  final String password;

  AuthPasswordChanged(this.password);
}