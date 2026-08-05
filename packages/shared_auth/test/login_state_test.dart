import 'package:flutter_test/flutter_test.dart';
import 'package:shared_auth/shared_auth.dart';

void main() {
  group('LoginState', () {
    test('defaults are sensible', () {
      const state = LoginState();
      expect(state.isLoading, isFalse);
      expect(state.phone, '');
      expect(state.otpSent, isFalse);
      expect(state.resendCooldown, 0);
      expect(state.countryCode, '+971');
      expect(state.method, AuthMethod.sms);
    });

    test('copyWith updates only provided fields', () {
      const state = LoginState();
      final updated = state.copyWith(phone: '501234567', countryCode: '+966');
      expect(updated.phone, '501234567');
      expect(updated.countryCode, '+966');
      expect(updated.email, '');
      expect(updated.isLoading, isFalse);
    });

    test('error clears when not provided to copyWith', () {
      final state = const LoginState().copyWith(error: 'boom');
      expect(state.error, 'boom');
      final cleared = state.copyWith();
      expect(cleared.error, isNull);
    });
  });

  group('AuthState', () {
    test('authenticated carries role and token', () {
      const auth = AuthAuthenticated(role: UserRole.advisor, token: 't0k3n');
      expect(auth.role, UserRole.advisor);
      expect(auth.token, 't0k3n');
    });

    test('error carries message', () {
      const err = AuthError('failed');
      expect(err.message, 'failed');
    });
  });

  group('Country options', () {
    test('UAE is the first (default) country', () {
      expect(PhoneInputField.countries.first.code, '+971');
      expect(PhoneInputField.countries.first.expectedLength, 9);
    });

    test('all countries have unique codes', () {
      final codes = PhoneInputField.countries.map((c) => c.code).toSet();
      expect(codes.length, PhoneInputField.countries.length);
    });
  });
}
