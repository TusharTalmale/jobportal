import 'package:flutter/material.dart';
import 'package:jobportal/provider/chat_provider.dart';
import 'package:jobportal/services/local_storage_service.dart';
import 'package:jobportal/provider/network_provider.dart';
import 'package:jobportal/provider/job_provider.dart';
import 'package:jobportal/provider/job_application_provider.dart';
import 'package:jobportal/screens/conversation/inbox_screen.dart';
import 'package:jobportal/screens/job/find_job_page.dart';
import 'package:jobportal/screens/network/network_screen.dart';
import 'package:jobportal/screens/saved_job.dart';
import 'package:jobportal/utils/app_routes.dart';
import 'package:jobportal/screens/home_screen.dart';
import 'package:jobportal/provider/profile_provider.dart';
import 'package:jobportal/widgets/bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:jobportal/provider/auth_viewmodel.dart';
import 'package:device_preview/device_preview.dart';
import 'package:jobportal/utils/app_router.dart';

Future<void> main() async {
  // Ensure that Flutter bindings are initialized before calling async code.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the local storage service.
  await LocalStorageService().init();

  runApp(
    // DevicePreview(
    //   enabled: !kReleaseMode,
    //   builder: (context) =>
    const JobPortalApp(),
    // ),
  );
}

class JobPortalApp extends StatelessWidget {
  const JobPortalApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => JobProvider()),
        ChangeNotifierProvider(create: (_) => JobApplicationProvider()),
        ChangeNotifierProxyProvider<ProfileProvider, ChatProvider>(
          create: (_) => ChatProvider(),
          update: (_, profile, chat) {
            chat ??= ChatProvider();
            final userProfile = profile.profile;
            if (userProfile != null) {
              chat.init(userId: userProfile.id, type: 'user');
            }
            return chat;
          },
        ),
        ChangeNotifierProvider(create: (_) => NetworkProvider()),
      ],
      child: MaterialApp(
        useInheritedMediaQuery: true,
        locale: DevicePreview.locale(context),
        builder: DevicePreview.appBuilder,
        title: 'Job Portal',
        theme: ThemeData(fontFamily: 'DMSans', primarySwatch: Colors.blue),

        debugShowCheckedModeBanner: false,
        initialRoute: AppRoutes.authCheck,
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const HomeContent(),
    const NetworkScreen(),
    const JobListingScreen(),
    const InboxScreen(),
    const SavedJobsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FC),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
