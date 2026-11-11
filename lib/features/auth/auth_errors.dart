import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

const String emailAlreadyRegisteredMessage =
    'An account with this email already exists. Please log in instead.';

const String _invalidCredentials = 'Incorrect email or password.';

const String incorrectCurrentPasswordMessage = 'Incorrect current password.';

const String _samePassword =
    'New password must be different from the current one.';

const String _reauthenticationNeeded =
    'Your session needs a fresh sign-in before the password can be changed.';

const String _emailNotConfirmed =
    'Please confirm your email address before logging in.';

const String _weakPassword =
    'Password is too weak. Use at least 8 characters with letters, numbers '
    'and a symbol.';

const String _network =
    'Could not reach the server. Check your connection and try again.';

const String _unknown = 'Something went wrong. Please try again.';

String authErrorMessage(Object error) {
  if (error is AuthWeakPasswordException) {
    final reasons = error.reasons;
    return reasons.isEmpty
        ? _weakPassword
        : '$_weakPassword (${reasons.join(', ')})';
  }

  if (error is AuthRetryableFetchException || error is TimeoutException) {
    return _network;
  }

  if (error is AuthException) {
    final code = error.code;
    final message = error.message.toLowerCase();

    if (code == ErrorCode.emailExists.code ||
        code == ErrorCode.userAlreadyExists.code ||
        message.contains('already registered')) {
      return emailAlreadyRegisteredMessage;
    }
    if (code == ErrorCode.emailNotConfirmed.code) return _emailNotConfirmed;
    if (code == ErrorCode.samePassword.code ||
        message.contains('different from the old password')) {
      return _samePassword;
    }
    if (code == ErrorCode.reauthenticationNeeded.code) {
      return _reauthenticationNeeded;
    }
    if (message.contains('invalid login credentials')) {
      return _invalidCredentials;
    }
    if (code == ErrorCode.overRequestRateLimit.code ||
        code == ErrorCode.overEmailSendRateLimit.code) {
      return 'Too many attempts. Please wait a moment and try again.';
    }
    if (_looksLikeNetwork(error)) return _network;

    return error.message;
  }

  return _looksLikeNetwork(error) ? _network : _unknown;
}

bool isInvalidCredentials(Object error) {
  if (error is! AuthException) return false;
  return error.code == 'invalid_credentials' ||
      error.message.toLowerCase().contains('invalid login credentials');
}

bool _looksLikeNetwork(Object error) {
  final message = error.toString();
  return message.contains('SocketException') ||
      message.contains('ClientException') ||
      message.contains('Failed host lookup') ||
      message.contains('Connection refused') ||
      message.contains('timed out');
}