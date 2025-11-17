import 'package:flutter/material.dart';
import 'package:jobportal/widgets/custom_text_field.dart';
import 'package:provider/provider.dart';
import '../../provider/auth_viewmodel.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Retrieve the email argument passed from the previous screen.
    // This is crucial for knowing which user's OTP to verify.
    final String email = ModalRoute.of(context)!.settings.arguments as String;

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
                    'Confirm OTP?',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF13005A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'To reset your password, you need your email or mobile number that can be authenticated',
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
                              : () => authViewModel.verifyOtpForPasswordReset(
                                context,
                                email,
                              ),
                      child:
                          authViewModel.isLoading
                              ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                              : const Text('VERIFY OTP'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFFECEAFF),
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'BACK TO LOGIN',
                        style: TextStyle(color: Color(0xFF13005A)),
                      ),
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
