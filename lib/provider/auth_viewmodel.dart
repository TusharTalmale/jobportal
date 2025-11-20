import 'package:dio/dio.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:jobportal/api/auth_api_service.dart';
import 'package:jobportal/model.dart/user_profile.dart';
import 'package:jobportal/provider/api_client.dart';
import 'package:jobportal/services/local_storage_service.dart';

class AuthViewModel extends ChangeNotifier {
  // Form Keys
  final loginFormKey = GlobalKey<FormState>();
  final signupFormKey = GlobalKey<FormState>();

  // Login Screen Controllers
  final TextEditingController loginEmailController = TextEditingController();
  final TextEditingController loginOtpController = TextEditingController();
  bool _rememberMeLogin = false;

  // Signup Screen Controllers
  final TextEditingController signupNameController = TextEditingController();
  final TextEditingController signupEmailController = TextEditingController();
  final TextEditingController signupMobileController = TextEditingController();
  bool _rememberMeSignup = false;

  // OTP Screen Controller
  final TextEditingController otpVerificationController =
      TextEditingController();

  // State Management
  bool _isLoading = false;
  bool _isSendingOtp = false;
  String? _errorMessage;
  String? _successMessage;

  // User Data
  UserProfile? _currentUser;
  String? _emailForVerification;
  bool _loginOtpSent = false;

  // OTP Timer
  Timer? _otpTimer;
  int _otpResendSeconds = 0;

  // Services
  late final AuthApiService _authApiService;
  final LocalStorageService _storageService = LocalStorageService();

  // Getters
  bool get isLoading => _isLoading;
  bool get isSendingOtp => _isSendingOtp;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  UserProfile? get currentUser => _currentUser;
  int get otpResendSeconds => _otpResendSeconds;
  bool get isOtpTimerActive => _otpTimer?.isActive ?? false;
  bool get loginOtpSent => _loginOtpSent;
  bool get rememberMeLogin => _rememberMeLogin;
  bool get rememberMeSignup => _rememberMeSignup;
  bool get isUserLoggedIn => _storageService.isLoggedIn();
  String? get emailForVerification => _emailForVerification;

  AuthViewModel() {
    _authApiService = ApiClient().authApiService;
  }

  // ========== Private State Management Methods ==========

  void _setLoading(bool value) {
    if (_isLoading == value) return;
    _isLoading = value;
    notifyListeners();
  }

  void _setSendingOtp(bool value) {
    if (_isSendingOtp == value) return;
    _isSendingOtp = value;
    notifyListeners();
  }

  void _setErrorMessage(String? message) {
    _errorMessage = message;
    _successMessage = null;
    notifyListeners();
  }

  void _setSuccessMessage(String? message) {
    _successMessage = message;
    _errorMessage = null;
    notifyListeners();
  }

  void _clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  // ========== Public State Management Methods ==========

  void toggleRememberMeLogin(bool? value) {
    _rememberMeLogin = value ?? false;
    notifyListeners();
  }

  void toggleRememberMeSignup(bool? value) {
    _rememberMeSignup = value ?? false;
    notifyListeners();
  }

  // ========== Authentication Methods ==========

  /// Initialize the viewmodel - call this once at app startup
  Future<void> initializeAuth() async {
    try {
      if (_storageService.isLoggedIn()) {
        final userData = _storageService.getUserData();
        if (userData != null) {
          try {
            _currentUser = UserProfile.fromJson(userData);
            notifyListeners();
          } catch (e) {
            print('Error parsing user profile: $e');
            await clearAuthData();
          }
        }
      }
    } catch (e) {
      print('Error initializing auth: $e');
    }
  }

  /// Send OTP for login
  Future<void> sendLoginOtp() async {
    if (loginEmailController.text.trim().isEmpty) {
      _setErrorMessage("Please enter your email address.");
      return;
    }

    _setSendingOtp(true);
    _clearMessages();

    try {
      final response = await _authApiService.loginSendOtp({
        'email': loginEmailController.text.trim(),
      });

      _loginOtpSent = true;
      _setSuccessMessage(response.message);
      startOtpTimer();
    } on DioException catch (e) {
      _handleDioError(e);
    } catch (e) {
      _setErrorMessage('An unexpected error occurred. Please try again.');
    } finally {
      _setSendingOtp(false);
    }
  }

  /// Verify login OTP and perform login
  Future<bool> loginWithOtp(context) async {
    if (loginFormKey.currentState?.validate() != true) {
      return false;
    }

    _setLoading(true);
    _clearMessages();

    try {
      final response = await _authApiService.loginVerifyOtp({
        'email': loginEmailController.text.trim(),
        'otp': loginOtpController.text.trim(),
      });
      // Save user data
      _currentUser = response.user;
      await _saveUserLocally(response.user);
print('LoginResponse: $response');  

      // Handle remember me
      if (_rememberMeLogin) {
        await _storageService.setRememberMe(true);
        await _storageService.setSavedEmail(loginEmailController.text.trim());
      }

      _setSuccessMessage('Login successful! Redirecting...');
      _clearLoginFields();

      return true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        _setErrorMessage('Invalid OTP. Please enter the correct OTP.');
      } else {
        _handleDioError(e);
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      _setErrorMessage('An unexpected error occurred. Please try again.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Send OTP for signup
  Future<void> sendSignupOtp() async {
    if (signupFormKey.currentState?.validate() != true) {
      return;
    }

    _setSendingOtp(true);
    _clearMessages();

    try {
      final response = await _authApiService.signupSendOtp({
        'email': signupEmailController.text.trim(),
        'fullName': signupNameController.text.trim(),
        'phoneNumber': signupMobileController.text.trim(),
      });

      _emailForVerification = signupEmailController.text.trim();
      _setSuccessMessage(response.message);
      startOtpTimer();
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        _setErrorMessage('Email already registered. Please login instead.');
      } else {
        _handleDioError(e);
      }
    } catch (e) {
      _setErrorMessage('Failed to send OTP. Please try again.');
    } finally {
      _setSendingOtp(false);
    }
  }

  /// Resend OTP for signup
  Future<void> resendSignupOtp() async {
    if (_emailForVerification == null) {
      _setErrorMessage('Email not found. Please go back and try again.');
      return;
    }

    _setSendingOtp(true);
    _clearMessages();

    try {
      final response = await _authApiService.signupSendOtp({
        'email': _emailForVerification,
        'fullName': signupNameController.text.trim(),
        'phoneNumber': signupMobileController.text.trim(),
      });

      _setSuccessMessage(response.message);
      startOtpTimer();
    } on DioException catch (e) {
      _handleDioError(e);
    } finally {
      _setSendingOtp(false);
    }
  }

  /// Verify signup OTP and complete registration
  Future<bool> verifySignupOtp() async {
    _otpTimer?.cancel();
    _setLoading(true);
    _clearMessages();

    try {
      final response = await _authApiService.signupVerifyOtp({
        'email': _emailForVerification,
        'otp': otpVerificationController.text.trim(),
      });

      // Save user data
      _currentUser = response.user;
      await _saveUserLocally(response.user);

      // Handle remember me
      if (_rememberMeSignup) {
        await _storageService.setRememberMe(true);
        await _storageService.setSavedEmail(_emailForVerification!);
      }

      _setSuccessMessage('Account created successfully!');
      _clearSignupFields();
      return true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        _setErrorMessage('Invalid or expired OTP. Please try again.');
      } else {
        _handleDioError(e);
      }
      return false;
    } catch (e) {
      _setErrorMessage('An unexpected error occurred. Please try again.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ========== Helper Methods ==========

  Future<void> _saveUserLocally(UserProfile user) async {
    try {
      await _storageService.saveUserData(user.toJson());
      await _storageService.saveUserId(user.id); // id is non-nullable
      if (user.email != null) await _storageService.saveUserEmail(user.email!);
      if (user.fullName != null) await _storageService.saveUserName(user.fullName!);
      await _storageService.saveUserType(user.userType ?? 'user');
      await _storageService.setLoginStatus(true);
    } catch (e) {
      print('Error saving user data locally: $e');
    }
  }

  void _handleDioError(DioException e) {
    String message = 'An error occurred. Please check your connection.';

    if (e.response != null) {
      if (e.response?.statusCode == 400) {
        message = e.response?.data['error'] ?? message;
      } else if (e.response?.statusCode == 401) {
        message = 'Unauthorized. Please try again.';
      } else if (e.response?.statusCode == 500) {
        message = 'Server error. Please try again later.';
      } else if (e.response?.statusCode == 429) {
        message = 'Too many attempts. Please wait before trying again.';
      }
    } else if (e.type == DioExceptionType.connectionTimeout) {
      message = 'Connection timeout. Please check your internet.';
    } else if (e.type == DioExceptionType.receiveTimeout) {
      message = 'Request timeout. Please try again.';
    }

    _setErrorMessage(message);
  }

  void _clearLoginFields() {
    loginEmailController.clear();
    loginOtpController.clear();
    _loginOtpSent = false;
  }

  void _clearSignupFields() {
    signupNameController.clear();
    signupEmailController.clear();
    signupMobileController.clear();
    otpVerificationController.clear();
    _emailForVerification = null;
  }

  void startOtpTimer() {
    _otpTimer?.cancel();
    _otpResendSeconds = 60;
    _otpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_otpResendSeconds > 0) {
        _otpResendSeconds--;
      } else {
        timer.cancel();
      }
      notifyListeners();
    });
  }

  Future<void> clearAuthData() async {
    _otpTimer?.cancel();
    await _storageService.clearAllData();
    _currentUser = null;
    _clearLoginFields();
    _clearSignupFields();
    _clearMessages();
    notifyListeners();
  }

  // ========== Validators ==========

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? validateOtp(String? value) {
    if (value == null || value.isEmpty) {
      return 'OTP is required';
    }
    if (value.length != 6) {
      return 'OTP must be 6 digits';
    }
    if (!value.isNumericOnly) {
      return 'OTP must contain only numbers';
    }
    return null;
  }

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Full name is required';
    }
    if (value.length < 3) {
      return 'Name must be at least 3 characters';
    }
    return null;
  }

  String? validateMobile(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mobile number is required';
    }
    if (value.length != 10) {
      return 'Enter a valid 10-digit mobile number';
    }
    if (!value.isNumericOnly) {
      return 'Mobile number must contain only digits';
    }
    return null;
  }

  @override
  void dispose() {
    loginEmailController.dispose();
    loginOtpController.dispose();
    signupNameController.dispose();
    signupEmailController.dispose();
    signupMobileController.dispose();
    otpVerificationController.dispose();
    _otpTimer?.cancel();
    super.dispose();
  }
}

extension StringExtension on String {
  bool get isNumericOnly => RegExp(r'^[0-9]+$').hasMatch(this);
}