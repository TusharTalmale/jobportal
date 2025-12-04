import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jobportal/provider/auth_viewmodel.dart';

import 'textfield.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  void initState() {
    super.initState();
    // Pre-fill email if remember me was enabled
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   final authViewModel = context.read<AuthViewModel>();
    //   if (authViewModel._storageService.getRememberMe()) {
    //     final savedEmail = authViewModel._storageService.getSavedEmail();
    //     if (savedEmail != null) {
    //       authViewModel.loginEmailController.text = savedEmail;
    //       authViewModel.toggleRememberMeLogin(true);
    //     }
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F8FC),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: authViewModel.loginFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    // Header
                    const Text(
                      'Welcome Back',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF13005A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Sign in to your account to continue your journey',
                      style: TextStyle(color: Colors.black54, fontSize: 14),
                    ),
                    const SizedBox(height: 40),

                    // Email Input Field
                    CustomTextField(
                      label: 'Email Address',
                      controller: authViewModel.loginEmailController,
                      validator: authViewModel.validateEmail,
                      keyboardType: TextInputType.emailAddress,
                      enabled:
                          !authViewModel.loginOtpSent &&
                          !authViewModel.isSendingOtp,
                      prefixIcon: Icons.email_outlined,
                      hint: 'enter@example.com',
                    ),
                    const SizedBox(height: 24),

                    // Get OTP Button or OTP Input
                    if (!authViewModel.loginOtpSent)
                      _buildGetOtpButton(context, authViewModel)
                    else
                      Column(
                        children: [
                          CustomTextField(
                            label: 'Enter 6-digit OTP',
                            controller: authViewModel.loginOtpController,
                            validator: authViewModel.validateOtp,
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            prefixIcon: Icons.lock_outline,
                            hint: '000000',
                            textAlign: TextAlign.center,
                            textStyle: const TextStyle(
                              fontSize: 18,
                              letterSpacing: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildOtpResendSection(context, authViewModel),
                        ],
                      ),

                    const SizedBox(height: 16),

                    // Remember Me Checkbox
                    Row(
                      children: [
                        Checkbox(
                          value: authViewModel.rememberMeLogin,
                          activeColor: const Color(0xFF13005A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          onChanged: authViewModel.toggleRememberMeLogin,
                        ),
                        const Text(
                          'Remember me',
                          style: TextStyle(color: Colors.black87),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Login/Submit Button
                    if (authViewModel.loginOtpSent)
                      _buildLoginButton(context, authViewModel),

                    const SizedBox(height: 16),

                    // Google Sign In Button
                    _buildGoogleSignInButton(context),

                    const SizedBox(height: 24),

                    // Sign Up Link
                    Center(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account? ",
                            style: TextStyle(color: Colors.black54),
                          ),
                          GestureDetector(
                            onTap: () {
                              authViewModel.loginFormKey.currentState?.reset();
                              Navigator.pushNamed(context, '/signup');
                            },
                            child: const Text(
                              'Sign up here',
                              style: TextStyle(
                                color: Color(0xFFFCA61F),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Error Message
                    if (authViewModel.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: _buildErrorWidget(authViewModel.errorMessage!),
                      ),

                    // Success Message
                    if (authViewModel.successMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: _buildSuccessWidget(
                          authViewModel.successMessage!,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGetOtpButton(BuildContext context, AuthViewModel authViewModel) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF13005A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 2,
        ),
        onPressed:
            authViewModel.isSendingOtp
                ? null
                : () => authViewModel.sendLoginOtp(),
        icon:
            authViewModel.isSendingOtp
                ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
                : const Icon(Icons.mail_outline, size: 20),
        label: Text(
          authViewModel.isSendingOtp ? 'Sending OTP...' : 'Get OTP',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildOtpResendSection(
    BuildContext context,
    AuthViewModel authViewModel,
  ) {
    return Center(
      child:
          authViewModel.isOtpTimerActive
              ? Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade300),
                ),
                child: Text(
                  'Resend OTP in ${authViewModel.otpResendSeconds}s',
                  style: TextStyle(
                    color: Colors.orange.shade700,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              )
              : TextButton(
                onPressed:
                    authViewModel.isSendingOtp
                        ? null
                        : () => authViewModel.sendLoginOtp(),
                child: const Text(
                  'Didn\'t receive OTP? Resend',
                  style: TextStyle(
                    color: Color(0xFF13005A),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
    );
  }

  Widget _buildLoginButton(BuildContext context, AuthViewModel authViewModel) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF13005A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 2,
        ),
        onPressed:
            authViewModel.isLoading
                ? null
                : () async {
                  final success = await authViewModel.loginWithOtp(context);
                  if (success && context.mounted) {
                    Navigator.pushReplacementNamed(context, '/main');
                  }
                },
        child:
            authViewModel.isLoading
                ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
                : const Text(
                  'LOGIN',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
      ),
    );
  }

  Widget _buildGoogleSignInButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          // TODO: Implement Google Sign In
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Google Sign In coming soon!'),
              duration: Duration(seconds: 2),
            ),
          );
        },
        icon: Image.asset('assets/icons/google.png', height: 24, width: 24),
        label: const Text(
          'CONTINUE WITH GOOGLE',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: const Color(0xFFECEAFF),
          side: BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          foregroundColor: const Color(0xFF13005A),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        border: Border.all(color: Colors.red.shade300, width: 1.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade600, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessWidget(String message) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        border: Border.all(color: Colors.green.shade300, width: 1.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            color: Colors.green.shade600,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.green.shade700,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
