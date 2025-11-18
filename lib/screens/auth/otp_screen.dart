import 'package:flutter/material.dart';
import 'package:jobportal/widgets/custom_text_field.dart';
import 'package:provider/provider.dart';
import '../../provider/auth_viewmodel.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Confirm Your OTP',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF13005A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'We have sent an OTP to your email address. Please check your inbox to complete the verification.',
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Image.asset('assets/images/otp.png', height: 180),
                  ),
                  const SizedBox(height: 24),
                  CustomTextField(
                    label: 'OTP',
                    controller: authViewModel.otpVerificationController,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF13005A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed:
                          authViewModel.isLoading
                              ? null
                              : () => authViewModel.verifySignupOtp(context),
                      child:
                          authViewModel.isLoading
                              ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                              : const Text('VERIFY OTP'),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child:
                        authViewModel.isOtpTimerActive
                            ? Text(
                              'Resend OTP in ${authViewModel.otpResendSeconds}s',
                              style: const TextStyle(color: Colors.grey),
                            )
                            : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Didn't receive the code? ",
                                  style: TextStyle(color: Colors.black54),
                                ),
                                TextButton(
                                  onPressed:
                                      authViewModel.isLoading
                                          ? null
                                          : () =>
                                              authViewModel.resendSignupOtp(),
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text(
                                    'Resend OTP',
                                    style: TextStyle(
                                      color: Color(0xFF13005A),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
