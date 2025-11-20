import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jobportal/provider/auth_viewmodel.dart';

import 'textfield.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool _agreedToTerms = false;

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
                authViewModel.signupFormKey.currentState?.reset();
                Navigator.pop(context);
              },
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: authViewModel.signupFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    const Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF13005A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Sign up to explore amazing job opportunities',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Full Name Field
                    CustomTextField(
                      label: 'Full Name',
                      controller: authViewModel.signupNameController,
                      validator: authViewModel.validateName,
                      keyboardType: TextInputType.name,
                      enabled: !authViewModel.isSendingOtp,
                      prefixIcon: Icons.person_outline,
                      hint: 'John Doe',
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 18),

                    // Email Field
                    CustomTextField(
                      label: 'Email Address',
                      controller: authViewModel.signupEmailController,
                      validator: authViewModel.validateEmail,
                      keyboardType: TextInputType.emailAddress,
                      enabled: !authViewModel.isSendingOtp,
                      prefixIcon: Icons.email_outlined,
                      hint: 'enter@example.com',
                    ),
                    const SizedBox(height: 18),

                    // Mobile Number Field
                    CustomTextField(
                      label: 'Mobile Number',
                      controller: authViewModel.signupMobileController,
                      validator: authViewModel.validateMobile,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      enabled: !authViewModel.isSendingOtp,
                      prefixIcon: Icons.phone_outlined,
                      hint: '9876543210',
                    ),
                    const SizedBox(height: 20),

                    // Terms & Conditions Checkbox
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: _agreedToTerms,
                          activeColor: const Color(0xFF13005A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _agreedToTerms = value ?? false;
                            });
                          },
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 13,
                                ),
                                children: [
                                  const TextSpan(
                                    text: 'I agree to the ',
                                  ),
                                  TextSpan(
                                    text: 'Terms & Conditions',
                                    style: const TextStyle(
                                      color: Color(0xFF13005A),
                                      fontWeight: FontWeight.w600,
                                      decoration:
                                          TextDecoration.underline,
                                    ),
                                    // Add tap handler here
                                  ),
                                  const TextSpan(
                                    text: ' and ',
                                  ),
                                  TextSpan(
                                    text: 'Privacy Policy',
                                    style: const TextStyle(
                                      color: Color(0xFF13005A),
                                      fontWeight: FontWeight.w600,
                                      decoration:
                                          TextDecoration.underline,
                                    ),
                                    // Add tap handler here
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Sign Up Button
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
                        onPressed: (authViewModel.isSendingOtp ||
                                !_agreedToTerms)
                            ? null
                            : () async {
                                await authViewModel.sendSignupOtp();
                                if (authViewModel.errorMessage == null &&
                                    context.mounted) {
                                  Navigator.pushNamed(context, '/otp');
                                }
                              },
                        child: authViewModel.isSendingOtp
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation(
                                      Colors.white),
                                ),
                              )
                            : const Text(
                                'CREATE ACCOUNT',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Google Sign Up Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // TODO: Implement Google Sign Up
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Google Sign Up coming soon!'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: Image.asset(
                          'assets/icons/google.png',
                          height: 24,
                          width: 24,
                        ),
                        label: const Text(
                          'SIGN UP WITH GOOGLE',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
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
                    ),

                    const SizedBox(height: 24),

                    // Sign In Link
                    Center(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const Text(
                            "Already have an account? ",
                            style: TextStyle(color: Colors.black54),
                          ),
                          GestureDetector(
                            onTap: () {
                              authViewModel.signupFormKey.currentState
                                  ?.reset();
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'Sign in',
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
                        child: _buildErrorWidget(
                            authViewModel.errorMessage!),
                      ),

                    // Success Message
                    if (authViewModel.successMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: _buildSuccessWidget(
                            authViewModel.successMessage!),
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
          Icon(
            Icons.error_outline,
            color: Colors.red.shade600,
            size: 22,
          ),
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