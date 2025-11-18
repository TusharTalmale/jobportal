class ApiConstants {
  static const String baseUrl = "http://10.98.73.250:3000";

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

  // Post & Comment Endpoints
  static const String posts = "/api/posts";
  static const String postById = "/api/posts/{postId}";
  static const String companyPosts = "/api/company/{companyId}/posts";
  static const String togglePostLike = "/api/posts/{postId}/toggle-like";
  static const String postComments = "/api/posts/{postId}/comments";
  static const String commentReplies = "/api/comments/{commentId}/replies";
  static const String toggleCommentLike =
      "/api/comments/{commentId}/toggle-like";
  static const String deleteComment = "/api/comments/{commentId}";

  // Chat Endpoints
  static const String chatBase = "/api/chat";
  static const String chatConversations =
      "/api/chat"; // GET with ?userId, POST to find/create
  static const String chatMessages = "/api/chat/{conversationId}/messages";
  static const String chatMarkRead = "/api/chat/{conversationId}/messages/read";
}
