import 'package:flutter_test/flutter_test.dart';
import 'package:saradrive/utils/validators.dart';

void main() {
  group('Validators Unit Tests', () {
    test('Email Validator - returns error for empty email', () {
      final result = Validators.validateEmail('');
      expect(result, 'Email is required');
    });

    test('Email Validator - returns error for invalid email', () {
      final result = Validators.validateEmail('invalid-email');
      expect(result, 'Enter a valid email address');
    });

    test('Email Validator - returns null for valid email', () {
      final result = Validators.validateEmail('test@example.com');
      expect(result, isNull);
    });

    test('Password Validator - returns error for empty password', () {
      final result = Validators.validatePassword('');
      expect(result, 'Password is required');
    });

    test('Password Validator - returns error for short password', () {
      final result = Validators.validatePassword('12345');
      expect(result, 'Password must be at least 6 characters long');
    });

    test('Password Validator - returns null for valid password', () {
      final result = Validators.validatePassword('123456');
      expect(result, isNull);
    });
  });
}
