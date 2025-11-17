import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:jobportal/api/api_response.dart';
import 'package:jobportal/api/auth_api_service.dart';
import 'package:jobportal/provider/api_client.dart';


class AuthViewModel extends ChangeNotifier {
  // Form Keys
  final loginFormKey = GlobalKey<FormState>();
  final signupFormKey = GlobalKey<FormState>();

  // Login Screen Controllers
  final TextEditingController loginMobileController = TextEditingController();
  final TextEditingController loginOtpController = TextEditingController();
  bool _rememberMeLogin = false;
  bool _showPasswordLogin = false;

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

  // API Service
  final AuthApiService _authApiService = ApiClient().authApiService;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get rememberMeLogin => _rememberMeLogin;
  bool get showPasswordLogin => _showPasswordLogin;
  bool get rememberMeSignup => _rememberMeSignup;

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

  void toggleShowPasswordLogin() {
    _showPasswordLogin = !_showPasswordLogin;
    notifyListeners();
  }

  void toggleRememberMeSignup(bool? value) {
    _rememberMeSignup = value ?? false;
    notifyListeners();
  }

  Future<void> login(BuildContext context) async {
    // Validate the form
    if (loginFormKey.currentState?.validate() != true) {
      return;
    }

    _setLoading(true);
    _setErrorMessage(null);

    try {
      // The backend expects an email for login. Assuming the mobile controller is used for email.
      final response = await _authApiService.loginVerifyOtp({
        'email': loginMobileController.text,
        'otp': loginOtpController.text,
      });

      print('Login successful: ${response.message}');
      // TODO: Handle successful login:
      // 1. Save the user data (response.user) to a user provider/state management.
      // 2. Securely store the JWT token (when you implement it).
      // 3. Navigate to the home screen.
      // Navigator.pushReplacementNamed(context, '/home');
    } on DioException catch (e) {
      _handleError(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signup(BuildContext context) async {
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
      // Navigate to an OTP screen for signup verification, passing the email.
      Navigator.pushNamed(
        context,
        '/signup-otp',
        arguments: signupEmailController.text,
      );
    } on DioException catch (e) {
      _handleError(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> sendOtpForPasswordReset(BuildContext context) async {
    // Assuming the user has entered their email in the loginMobileController
    if (loginMobileController.text.isEmpty) {
      _setErrorMessage("Please enter your email to reset the password.");
      return;
    }

    _setLoading(true);
    _setErrorMessage(null);

    try {
      final response = await _authApiService.loginSendOtp({
        'email': loginMobileController.text,
      });
      print('Password Reset OTP Sent: ${response.message}');
      // Navigate to OTP verification screen, passing the email
      Navigator.pushNamed(
        context,
        '/otp',
        arguments: loginMobileController.text,
      );
    } on DioException catch (e) {
      _handleError(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> verifyOtpForPasswordReset(
    BuildContext context,
    String email,
  ) async {
    _setLoading(true);
    _setErrorMessage(null);

    try {
      // This uses the same verification endpoint as login
      final response = await _authApiService.loginVerifyOtp({
        'email': email,
        'otp': otpVerificationController.text,
      });
      print('OTP Verified: ${response.message}');
      // TODO: Navigate to a "Create New Password" screen
      Navigator.pop(context); // For now, just pop back
    } on DioException catch (e) {
      _handleError(e);
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
        'An unexpected network error occurred. Please try again.',
      );
    }
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
    super.dispose();
  }
}
