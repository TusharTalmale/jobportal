import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/auth_viewmodel.dart';
import '../../widgets/custom_text_field.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Use Consumer to listen to AuthViewModel changes
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F8FC),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: authViewModel.signupFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    const Text(
                      'Create an Account',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF13005A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor',
                      style: TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 32),
                    CustomTextField(
                      label: 'Full name',
                      controller: authViewModel.signupNameController,
                      validator: authViewModel.validateName,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Email',
                      controller: authViewModel.signupEmailController,
                      validator: authViewModel.validateEmail,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Mobile Number',
                      controller: authViewModel.signupMobileController,
                      validator: authViewModel.validateMobile,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Checkbox(
                          value: authViewModel.rememberMeSignup,
                          activeColor: const Color(0xFF13005A),
                          onChanged: authViewModel.toggleRememberMeSignup,
                        ),
                        const Text('Remember me'),
                        const Spacer(),
                        // TextButton(
                        //   onPressed: () {},
                        //   child: const Text(
                        //     'Forgot Password ?',
                        //     style: TextStyle(color: Colors.black54),
                        //   ),
                        // ),
                      ],
                    ),
                    const SizedBox(height: 10),
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
                                : () => authViewModel.sendSignupOtp(context),
                        child:
                            authViewModel.isLoading
                                ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                                : const Text('SIGN UP'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: Image.asset(
                          'assets/icons/google.png',
                          height: 20,
                        ),
                        label: const Text('SIGN UP WITH GOOGLE'),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: const Color(0xFFECEAFF),
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const Text("Already have an account? "),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Text(
                              'Sign in',
                              style: TextStyle(
                                color: Color(0xFFFCA61F),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (authViewModel.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Center(
                          child: Text(
                            authViewModel.errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
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
}
