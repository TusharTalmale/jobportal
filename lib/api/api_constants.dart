class ApiConstants {
  // Replace with your actual base URL.
  // Use 10.0.2.2 for the Android emulator to connect to localhost.
  // For iOS simulator, use localhost or your machine's IP address.
  static const String baseUrl = "http://10.50.124.250:3000";

  // Auth Endpoints
  static const String signupSendOtp = "/api/signup/send-otp";
  static const String signupVerifyOtp = "/api/signup/verify-otp";
  static const String loginSendOtp = "/api/login/send-otp";
  static const String loginVerifyOtp = "/api/login/verify-otp";

  // Job Endpoints
  static const String jobs = "/api/Job"; // for GET all and POST
  static const String jobById = "/api/Job/{id}"; // for GET by id, PUT, DELETE

  // Company Endpoints
  static const String companies = "/api/company"; // for GET all and POST
  static const String companyById =
      "/api/company/{id}"; // for GET by id, PUT, DELETE
}
