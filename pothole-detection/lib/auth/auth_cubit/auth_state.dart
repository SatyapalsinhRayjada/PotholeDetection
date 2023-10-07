part of 'auth_cubit.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState({
    required User? user,
    required String? phone,
    required bool isLoading,
    required String? otp,
    required String? verificationId,
  }) = _AuthState;

  factory AuthState.initial() => AuthState(
        user: null,
        otp: null,
        isLoading: false,
        phone: null,
        verificationId: null,
      );
}
