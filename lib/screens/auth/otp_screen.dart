import 'package:flutter/material.dart';
import 'package:jobportal/utils/app_routes.dart';
import 'package:provider/provider.dart';
import 'package:jobportal/provider/auth_viewmodel.dart';

import 'textfield.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  late FocusNode _otpFocusNode;

  @override
  void initState() {
    super.initState();
    _otpFocusNode = FocusNode();
    // Auto-focus OTP field for better UX
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _otpFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _otpFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F8FC),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF13005A)),
              onPressed: () {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  authViewModel.loginFormKey.currentState?.reset();
                });
                Navigator.of(context).pop();
              },
            ),
            title: const Text(
              'Verify OTP',
              style: TextStyle(
                color: Color(0xFF13005A),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),

                    // Illustration/Icon
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: const Color(0xFFECEAFF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.mark_email_read_outlined,
                        size: 50,
                        color: Color(0xFF13005A),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Title
                    const Text(
                      'Verify Your Email',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF13005A),
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 12),

                    // Email Display
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                            height: 1.5,
                          ),
                          children: [
                            const TextSpan(
                              text: 'We\'ve sent a 6-digit OTP to\n',
                            ),
                            TextSpan(
                              text:
                                  authViewModel.emailForVerification ??
                                  'your email',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF13005A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // OTP Input Field
                    CustomTextField(
                      label: 'Enter OTP',
                      controller: authViewModel.otpVerificationController,
                      validator: authViewModel.validateOtp,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      prefixIcon: Icons.lock_outline,
                      hint: '000000',
                      focusNode: _otpFocusNode,
                      textAlign: TextAlign.center,
                      textStyle: const TextStyle(
                        fontSize: 22,
                        letterSpacing: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Verify Button
                    SizedBox(
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
                                  final success =
                                      await authViewModel.verifySignupOtp();
                                  if (success && context.mounted) {
                                    Navigator.pushReplacementNamed(
                                      context,
                                      AppRoutes.main,
                                    );
                                  }
                                },
                        child:
                            authViewModel.isLoading
                                ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation(
                                      Colors.white,
                                    ),
                                  ),
                                )
                                : const Text(
                                  'VERIFY OTP',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Resend OTP Section
                    _buildResendSection(context, authViewModel),

                    const SizedBox(height: 24),

                    // Error Message
                    if (authViewModel.errorMessage != null)
                      _buildErrorWidget(authViewModel.errorMessage!),

                    // Success Message
                    if (authViewModel.successMessage != null)
                      _buildSuccessWidget(authViewModel.successMessage!),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildResendSection(
    BuildContext context,
    AuthViewModel authViewModel,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          const Text(
            'Didn\'t receive the OTP?',
            style: TextStyle(color: Colors.black54, fontSize: 14),
          ),
          const SizedBox(height: 12),
          if (authViewModel.isOtpTimerActive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade300),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.schedule_outlined,
                    color: Colors.orange.shade700,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Resend OTP in ${authViewModel.otpResendSeconds}s',
                    style: TextStyle(
                      color: Colors.orange.shade700,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF13005A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(
                      color: Color(0xFF13005A),
                      width: 1.5,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed:
                    authViewModel.isSendingOtp
                        ? null
                        : () => authViewModel.resendSignupOtp(),
                icon: const Icon(Icons.mail_outline, size: 18),
                label: Text(
                  authViewModel.isSendingOtp ? 'Sending...' : 'Resend OTP',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
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
