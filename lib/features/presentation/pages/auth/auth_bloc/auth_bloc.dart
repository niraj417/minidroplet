/*
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/services/firebase_service.dart';
import '../../../../../core/utils/validators.dart';
import '../../../../../injections/dependency_injection.dart';
import 'auth_event.dart';
import 'auth_state.dart';

// auth_bloc.dart
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<AuthLoginEvent>(_onLogin);
    on<AuthRegisterEvent>(_onRegister);
    on<AuthLogoutEvent>(_onLogout);
    on<AuthEmailChanged>(_onEmailChanged);
    on<AuthPasswordChanged>(_onPasswordChanged);
  }
  // final _firebaseService = locator<FirebaseService>();

  Future<void> _onLogin(AuthLoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _firebaseService.signInWithEmail(
        event.email,
        event.password,
      );
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthFailure('Login failed'));
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));

      // Transition back to a valid form state after failure
      final currentFormState = state is AuthFormState
          ? (state as AuthFormState)
          : AuthFormState();

      emit(currentFormState.copyWith(
        email: event.email,
        password: event.password,
        isEmailValid: Validator.validateEmail(event.email) == null,
        isPasswordValid: Validator.validatePassword(event.password) == null,
      ));
    }
  }

  Future<void> _onRegister(
      AuthRegisterEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _firebaseService.registerWithEmail(
        event.email,
        event.password,
      );
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthFailure('Registration failed'));
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onLogout(AuthLogoutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _firebaseService.signOut();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }
  void _onEmailChanged(AuthEmailChanged event, Emitter<AuthState> emit) {
    final isEmailValid = Validator.validateEmail(event.email) == null;
    final currentFormState = state is AuthFormState
        ? (state as AuthFormState)
        : AuthFormState();

    emit(currentFormState.copyWith(
      email: event.email,
      isEmailValid: isEmailValid,
    ));

    print("Email changed: ${event.email}, isEmailValid: $isEmailValid");
  }

  void _onPasswordChanged(AuthPasswordChanged event, Emitter<AuthState> emit) {
    final isPasswordValid = Validator.validatePassword(event.password) == null;
    final currentFormState = state is AuthFormState
        ? (state as AuthFormState)
        : AuthFormState();

    emit(currentFormState.copyWith(
      password: event.password,
      isPasswordValid: isPasswordValid,
    ));

    print("Password changed: ${event.password}, isPasswordValid: $isPasswordValid");
  }

}*/
