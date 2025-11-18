import 'package:flutter/material.dart';
import 'package:jobportal/screens/auth/login_screen.dart';
import 'package:jobportal/model.dart/job.dart';
import 'package:jobportal/screens/auth/onboarding_screen.dart';
import 'package:jobportal/screens/auth/otp_screen.dart';
import 'package:jobportal/screens/auth/signup_screen.dart';
import 'package:jobportal/screens/conversation/inbox_screen.dart';
import 'package:jobportal/screens/chat_list_screen.dart';
import 'package:jobportal/screens/home_screen.dart';
import 'package:jobportal/screens/job/apply_job/apply_job_page.dart';
import 'package:jobportal/screens/job/find_job_page.dart';
import 'package:jobportal/screens/network/company_detail_screen.dart';
import 'package:jobportal/screens/job/job_detail_page.dart';
import 'package:jobportal/screens/network/network_screen.dart';
import 'package:jobportal/screens/profile/about_me_screen.dart';
import 'package:jobportal/screens/profile/appreciation_screen.dart';
import 'package:jobportal/screens/profile/education_screen.dart';
import 'package:jobportal/screens/profile/language_screen.dart';
import 'package:jobportal/screens/profile/profile_view_screen.dart';
import 'package:jobportal/screens/profile/resume_screen.dart';
import 'package:jobportal/screens/profile/skills_screen.dart';
import 'package:jobportal/screens/profile/work_experiance_screen.dart';
import 'package:jobportal/screens/saved_job.dart';
import 'package:jobportal/utils/app_routes.dart';
import 'package:jobportal/main.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Static routes (no arguments)
      case AppRoutes.main:
        return MaterialPageRoute(builder: (_) => const MainScreen());
      case AppRoutes.onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case AppRoutes.signup:
        return MaterialPageRoute(builder: (_) => const SignupScreen());
      case AppRoutes.otp:
        return MaterialPageRoute(builder: (_) => const OtpScreen());
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const HomeContent());
      case AppRoutes.profile:
        return MaterialPageRoute(builder: (_) => const ProfileViewScreen());
      case AppRoutes.network:
        return MaterialPageRoute(builder: (_) => const NetworkScreen());
      case AppRoutes.findJob:
        return MaterialPageRoute(builder: (_) => const JobListingScreen());
      case AppRoutes.inbox:
        return MaterialPageRoute(builder: (_) => const InboxScreen());
      case AppRoutes.chatList:
        return MaterialPageRoute(builder: (_) => const ChatListScreen());
      case AppRoutes.savedJobs:
        return MaterialPageRoute(builder: (_) => const SavedJobsScreen());
      case AppRoutes.aboutMe:
        return MaterialPageRoute(builder: (_) => const AboutMeScreen());
      case AppRoutes.skills:
        return MaterialPageRoute(builder: (_) => const SkillsScreen());
      case AppRoutes.resume:
        return MaterialPageRoute(builder: (_) => const ResumeScreen());

      // Routes with arguments
      case AppRoutes.apply:
        final job = settings.arguments as Job;
        return MaterialPageRoute(builder: (_) => ApplyJobPage(job: job));

      case AppRoutes.jobDetail:
        final jobId = settings.arguments as int;
        return MaterialPageRoute(builder: (_) => JobDetailsPage(jobId: jobId));

      case AppRoutes.companyDetails:
        final companyId = settings.arguments as int;
        return MaterialPageRoute(
          builder: (_) => CompanyDetailScreen(companyId: companyId),
        );

      case AppRoutes.workExperience:
      case AppRoutes.education:
      case AppRoutes.languages:
      case AppRoutes.appreciation:
        final arguments = settings.arguments as Map<String, dynamic>?;
        final index = arguments?['index'] as int?;
        if (settings.name == AppRoutes.workExperience)
          return MaterialPageRoute(
            builder: (_) => WorkExperienceScreenWrapper(index: index),
          );
        if (settings.name == AppRoutes.education)
          return MaterialPageRoute(
            builder: (_) => EducationScreenWrapper(index: index),
          );
        if (settings.name == AppRoutes.languages)
          return MaterialPageRoute(
            builder: (_) => LanguageScreenWrapper(index: index),
          );
        if (settings.name == AppRoutes.appreciation)
          return MaterialPageRoute(
            builder: (_) => AppreciationScreen(index: index),
          );
        break;
    }
    // Default case for unknown routes
    return MaterialPageRoute(
      builder:
          (_) => const Scaffold(body: Center(child: Text('Page not found'))),
    );
  }
}
