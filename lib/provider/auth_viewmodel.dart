import 'package:dio/dio.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:jobportal/api/api_response.dart';
import 'package:jobportal/api/auth_api_service.dart';
import 'package:jobportal/provider/api_client.dart';
import 'package:jobportal/services/local_storage_service.dart';

class AuthViewModel extends ChangeNotifier {
  // Form Keys
  final loginFormKey = GlobalKey<FormState>();
  final signupFormKey = GlobalKey<FormState>();

  // Login Screen Controllers
  final TextEditingController loginMobileController = TextEditingController();
  final TextEditingController loginOtpController = TextEditingController();
  bool _rememberMeLogin = false;

  // Signup Screen Controllers
  final TextEditingController signupNameController = TextEditingController();
  final TextEditingController signupEmailController = TextEditingController();
  final TextEditingController signupMobileController = TextEditingController();
  bool _rememberMeSignup = false;

  // OTP Screen Controller (for forgot password)
  final TextEditingController otpVerificationController =
      TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  int? _currentUserId;
  String? _emailForVerification;
  String? _currentUserEmail;
  String? _currentUserEmail;
  String _currentUserType = 'user';

  // Timer for OTP resend
  Timer? _otpTimer;
  int _otpResendSeconds = 30;

  // API Service
  final AuthApiService _authApiService = ApiClient().authApiService;
  final LocalStorageService _storageService = LocalStorageService();

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get rememberMeLogin => _rememberMeLogin;
  bool get rememberMeSignup => _rememberMeSignup;
  int? get currentUserId => _currentUserId;
  String? get currentUserEmail => _currentUserEmail;
  String? get currentUserType => _currentUserType;
  bool get isUserLoggedIn => _storageService.isLoggedIn();
  int get otpResendSeconds => _otpResendSeconds;
  bool get isOtpTimerActive => _otpTimer?.isActive ?? false;

  void _setLoading(bool value) {
    if (_isLoading == value) return;
    _isLoading = value;
    notifyListeners();
  }

  void _setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void toggleRememberMeLogin(bool? value) {
    _rememberMeLogin = value ?? false;
    notifyListeners();
  }

  void toggleRememberMeSignup(bool? value) {
    _rememberMeSignup = value ?? false;
    notifyListeners();
  }

  /// Initialize the viewmodel - should be called once at app startup
  Future<void> initializeAuth() async {
    try {
      // Check if user was previously logged in
      if (_storageService.isLoggedIn()) {
        _currentUserId = _storageService.getUserId();
        _currentUserEmail = _storageService.getUserEmail();
        _currentUserType = _storageService.getUserType() ?? 'user';
        notifyListeners();
      }
    } catch (e) {
      print('Error initializing auth: $e');
    }
  }

  /// Send OTP for login
  Future<void> sendLoginOtp(BuildContext context) async {
    if (loginMobileController.text.isEmpty) {
      _setErrorMessage("Please enter your email.");
      return;
    }

    _setLoading(true);
    _setErrorMessage(null);

    try {
      final response = await _authApiService.loginSendOtp({
        'email': loginMobileController.text,
      });

      print('Login OTP Sent: ${response.message}');
      _setErrorMessage(null);
      notifyListeners();
    } on DioException catch (e) {
      _handleError(e);
    } finally {
      _setLoading(false);
    }
  }

  /// Verify login OTP and perform login
  Future<void> login(BuildContext context) async {
    // Validate the form
    if (loginFormKey.currentState?.validate() != true) {
      return;
    }

    _setLoading(true);
    _setErrorMessage(null);

    try {
      final response = await _authApiService.loginVerifyOtp({
        'email': loginMobileController.text,
        'otp': loginOtpController.text,
      });

      print('Login successful: ${response.message}');

      // Save user data to local storage
      final userData = response.user.toJson();
      await _storageService.saveUserData(userData);

      // Save specific user info
      _currentUserId = response.user.id;
      _currentUserEmail = response.user.email;
      _currentUserType = response.user.userType;

      await _storageService.saveUserId(response.user.id);
      await _storageService.saveUserEmail(response.user.email);
      await _storageService.saveUserName(response.user.fullName);
      await _storageService.saveUserType(_currentUserType);

      // Save remember me preference
      if (_rememberMeLogin) {
        await _storageService.setRememberMe(true);
        await _storageService.setSavedEmail(loginMobileController.text);
      }

      // Set login status
      await _storageService.setLoginStatus(true);

      notifyListeners();

      _clearLoginFields();

      // Navigate to home screen
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        _setErrorMessage(
          "The OTP you entered is incorrect. Please check and try again.",
        );
      } else {
        _handleError(e);
      }
    } finally {
      _setLoading(false);
    }
  }

  /// Send OTP for signup
  Future<void> sendSignupOtp(BuildContext context) async {
    // Validate the form
    if (signupFormKey.currentState?.validate() != true) {
      return;
    }

    _setLoading(true);
    _setErrorMessage(null);

    try {
      final response = await _authApiService.signupSendOtp({
        'email': signupEmailController.text,
        'fullName': signupNameController.text,
        'phoneNumber': signupMobileController.text,
      });

      print('Signup OTP Sent: ${response.message}');
      _emailForVerification = signupEmailController.text;
      _setErrorMessage(null);
      startOtpTimer(); // Start the timer on initial send

      // Navigate to OTP verification screen for signup
      if (context.mounted) {
        Navigator.pushNamed(
          context,
          '/otp',
          // No longer need to pass arguments
        );
      }
    } on DioException catch (e) {
      _handleError(e);
    } finally {
      _setLoading(false);
    }
  }

  /// Resend OTP for signup
  Future<void> resendSignupOtp() async {
    if (_emailForVerification == null) {
      _setErrorMessage("Email not found. Please go back and try again.");
      return;
    }

    _setLoading(true);
    _setErrorMessage(null);

    try {
      final response = await _authApiService.signupSendOtp({
        'email': _emailForVerification,
      });

      print('Signup OTP Resent: ${response.message}');
      startOtpTimer(); // Restart the timer
    } on DioException catch (e) {
      _handleError(e);
    } finally {
      _setLoading(false);
    }
  }

  /// Verify signup OTP and complete registration
  Future<void> verifySignupOtp(BuildContext context) async {
    _otpTimer?.cancel();
    _setLoading(true);
    _setErrorMessage(null);

    try {
      final response = await _authApiService.signupVerifyOtp({
        'email': _emailForVerification,
        'otp': otpVerificationController.text,
      });

      print('Signup verified: ${response.message}');

      // Save user data to local storage
      final userData = response.user.toJson();
      await _storageService.saveUserData(userData);

      // Save specific user info
      _currentUserId = response.user.id;
      _currentUserEmail = response.user.email;
      _currentUserType = response.user.userType;

      await _storageService.saveUserId(response.user.id);
      await _storageService.saveUserEmail(response.user.email);
      await _storageService.saveUserName(response.user.fullName);
      await _storageService.saveUserType(
        _currentUserType,
      ); // Save remember me preference
      if (_rememberMeSignup && _emailForVerification != null) {
        await _storageService.setRememberMe(true);
        await _storageService.setSavedEmail(signupEmailController.text);
      }

      // Set login status
      await _storageService.setLoginStatus(true);

      notifyListeners();

      _clearSignupFields();

      // Navigate to home screen
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        _setErrorMessage(
          "The OTP is incorrect or has expired. Please try again.",
        );
      } else {
        _handleError(e);
      }
    } finally {
      _setLoading(false);
    }
  }

  void _handleError(DioException e) {
    if (e.response != null && e.response?.data is Map) {
      final errorResponse = ErrorResponse.fromJson(e.response!.data);
      _setErrorMessage(errorResponse.error);
    } else {
      _setErrorMessage(
        'A network error occurred. Please check your connection and try again.',
      );
    }
  }

  void _clearLoginFields() {
    loginMobileController.clear();
    loginOtpController.clear();
    _emailForVerification = null;
  }

  void _clearSignupFields() {
    signupNameController.clear();
    signupEmailController.clear();
    signupMobileController.clear();
    otpVerificationController.clear();
    _emailForVerification = null;
  }

  // --- OTP Timer Methods ---
  void startOtpTimer() {
    _otpTimer?.cancel(); // Cancel any existing timer
    _otpResendSeconds = 30;
    _otpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_otpResendSeconds > 0) {
        _otpResendSeconds--;
      } else {
        timer.cancel();
      }
      notifyListeners();
    });
  }

  // --- Validators ---
  String? validateMobile(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mobile number is required.';
    }
    if (value.length != 10) {
      return 'Enter a valid 10-digit mobile number.';
    }
    return null;
  }

  String? validateOtp(String? value) {
    if (value == null || value.isEmpty) {
      return 'OTP is required.';
    }
    return null;
  }

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Full name is required.';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null ||
        value.isEmpty ||
        !value.contains('@') ||
        !value.contains('.')) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  @override
  void dispose() {
    loginMobileController.dispose();
    loginOtpController.dispose();
    signupNameController.dispose();
    signupEmailController.dispose();
    signupMobileController.dispose();
    otpVerificationController.dispose();
    _otpTimer?.cancel();
    super.dispose();
  }
}
