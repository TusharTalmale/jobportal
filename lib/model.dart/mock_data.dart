import 'package:jobportal/model.dart/company.dart';
import 'package:jobportal/model.dart/conversation.dart';
import 'package:jobportal/model.dart/message.dart';
import 'package:jobportal/model.dart/user_profile.dart';
import 'package:jobportal/screens/job/apply_job/apply_job_page.dart';

final Company googleCompanyData = Company(
  id: 1,
  companyName: 'Google Inc',
  followersCount:45,
  location: 'California',
  aboutCompany:
      'Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.\n\nAt vero eos et accusamus et iusto odio dignissimos ducimus qui blanditiis praesentium voluptatum deleniti atque corrupti quos dolores et quas.',
  website: 'https://www.google.com',
  companySize: '192,121 Employees',
  headOffice: 'Mountain View, California, USA',
  companyType: 'Multinational company',
  establishedSince: 1998,
  specialization:
      'Search technology, Web computing, Software and Online advertising',
  companyGallery: [
    'https://picsum.photos/id/10/400/300',
    'https://picsum.photos/id/11/400/300',
    'https://picsum.photos/id/12/400/300',
    'https://picsum.photos/id/13/400/300',
  ],
);

final Company appleCompanyData = Company(
  id: 2,
  companyName: 'Apple Inc',
  followersCount: 45,
  location: 'California',
  aboutCompany:
      'Apple Inc. is an American multinational technology company that specializes in consumer electronics, software and online services. Apple is the largest information technology company by revenue (totaling US\$365.8 billion in 2021)',
  website: 'https://www.apple.com',
  companySize: '154,000 Employees',
  headOffice: 'Cupertino, California, USA',
  companyType: 'Public Company',
  establishedSince: 5625,
  specialization: 'Hardware, Software, Services',
  companyGallery: [
    'https://picsum.photos/id/40/400/300',
    'https://picsum.photos/id/41/400/300',
    'https://picsum.photos/id/42/400/300',
  ],
);

final Company microsoftCompanyData = Company(
  id: 3,
  companyName: 'Microsoft Inc',
  followersCount: 45,
  location: 'Washington',
  aboutCompany:
      'Microsoft Corporation is an American multinational technology corporation which produces computer software, consumer electronics, personal computers, and related services.',
  website: 'https://www.microsoft.com',
  companySize: '221,000 Employees',
  headOffice: 'Redmond, Washington, USA',
  companyType: 'Public Company',
  establishedSince: 1355,
  specialization: 'Software, Cloud Computing, AI',
  companyGallery: [
    'https://picsum.photos/id/50/400/300',
    'https://picsum.photos/id/51/400/300',
    'https://picsum.photos/id/52/400/300',
  ],
);

final Company amazonCompanyData = Company(
  id: 4,
  companyName: 'Amazon',
  followersCount: 12,
  location: 'Washington',
  aboutCompany:
      'Amazon.com, Inc. is an American multinational technology company which focuses on e-commerce, cloud computing, digital streaming, and artificial intelligence.',
  website: 'https://www.amazon.com',
  companySize: '1,500,000+ Employees',
  headOffice: 'Seattle, Washington, USA',
  companyType: 'Public Company',
  establishedSince: 1738,
  specialization: 'E-commerce, AWS, Logistics, AI',
  companyGallery: [
    'https://picsum.photos/id/60/400/300',
    'https://picsum.photos/id/61/400/300',
    'https://picsum.photos/id/62/400/300',
  ],
);

final Company metaCompanyData = Company(
  id: 5,
  companyName: 'Meta',
  followersCount: 12,
  location: 'California',
  aboutCompany:
      'Meta Platforms, Inc., is an American multinational technology conglomerate based in Menlo Park, California. The company owns Facebook, Instagram, and WhatsApp, among other products and services.',
  website: 'https://about.meta.com',
  companySize: '77,800+ Employees',
  headOffice: 'Menlo Park, California, USA',
  companyType: 'Public Company',
  establishedSince: 2004,
  specialization: 'Social Networking, VR/AR, Advertising Technology',
  companyGallery: [
    'https://picsum.photos/id/70/400/300',
    'https://picsum.photos/id/71/400/300',
    'https://picsum.photos/id/72/400/300',
    'https://picsum.photos/id/73/400/300',
    'https://picsum.photos/id/74/400/300',
  ],
);

final Company netflixCompanyData = Company(
  id: 6,
  companyName: 'Netflix',
  followersCount: 12,
  location: 'California',
  aboutCompany:
      'Netflix, Inc. is an American subscription streaming service and production company. Launched on August 29, 1997, it offers a library of films and television series through distribution deals as well as its own productions, known as Netflix Originals.',
  website: 'https://www.netflix.com',
  companySize: '13,000+ Employees',
  headOffice: 'Los Gatos, California, USA',
  companyType: 'Public Company',
  establishedSince: 1992,
  specialization: 'Video Streaming, Content Production, Media',
  companyGallery: [
    'https://picsum.photos/id/80/400/300',
    'https://picsum.photos/id/81/400/300',
    'https://picsum.photos/id/82/400/300',
  ],
);

final Company spotifyCompanyData = Company(
  id: 7,
  companyName: 'Spotify',
  followersCount: 12,  location: 'Sweden',
  aboutCompany:
      'Spotify Technology S.A. is a Swedish audio streaming and media services provider. Founded in 2006, it is the world\'s largest music streaming service provider, with over 574 million monthly active users, including 220 million paying subscribers, as of September 2023.',
  website: 'https://www.spotify.com',
  companySize: '9,000+ Employees',
  headOffice: 'Stockholm, Sweden',
  companyType: 'Public Company',
  establishedSince: 1998,
  specialization: 'Music Streaming, Podcasts, Audio Content',
  companyGallery: [
    'https://picsum.photos/id/90/400/300',
    'https://picsum.photos/id/91/400/300',
    'https://picsum.photos/id/92/400/300',
    'https://picsum.photos/id/93/400/300',
    'https://picsum.photos/id/94/400/300',
  ],
);

final UploadedFile mockFile = UploadedFile(
  fileName: 'Jamet kudasi - CV - UI/UX Designer',
  fileSize: '867 Kb',
  date: '14 Feb 2022 at 11:30 am',
);

// ============= MOCK DATA for Conversations and Messages =============

final List<Conversation> mockConversations = [
  Conversation(
    id: 'conv1',
    companyName: 'Google',
    companyLogoUrl: 'assets/images/google_logo.png',
    companyData: googleCompanyData,
    lastMessage: 'Sure, please send your portfolio.',
    lastMessageTime: DateTime.now().subtract(const Duration(minutes: 5)),
    messages: [
      Message(
        id: 'msg1_1',
        sender: MessageSender.user,
        text: 'Hello, I\'m interested in the UI/UX Designer position.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
      ),
      Message(
        id: 'msg1_2',
        sender: MessageSender.company,
        text: 'Hi! Thanks for your interest. Could you tell us more about your experience?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 22)),
      ),
      Message(
        id: 'msg1_3',
        sender: MessageSender.user,
        text: 'I have 5 years of experience in mobile app design and prototyping.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
      ),
      Message(
        id: 'msg1_4',
        sender: MessageSender.company,
        text: 'That sounds great! Do you have a portfolio you can share?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 18)),
      ),
      Message(
        id: 'msg1_5',
        sender: MessageSender.user,
        text: 'Yes, I\'ll send it over shortly.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 17)),
      ),
      Message(
        id: 'msg1_6_reply',
        sender: MessageSender.user,
        type: MessageType.text,
        text: 'Here is my updated resume.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        repliedToMessageId: 'msg1_5', // Replying to "Yes, I'll send it over shortly."
      ),
      Message(
        id: 'msg1_7_file',
        sender: MessageSender.user,
        type: MessageType.file,
        fileName: 'My_Portfolio_2023.pdf',
        fileUrl: 'assets/files/My_Portfolio_2023.pdf', // Placeholder
        timestamp: DateTime.now().subtract(const Duration(minutes: 14)),
      ),
      Message(
        id: 'msg1_8_job',
        sender: MessageSender.user,
        type: MessageType.job,
        text: 'I am also interested in this position:',
        // jobData: mockJobs.firstWhere((job) => job.id == 4),
        timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
      ),
      Message(
        id: 'msg1_6',
        sender: MessageSender.company,
        text: 'Sure, please send your portfolio.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
    ],
  ),
  Conversation(
    id: 'conv2',
    companyName: 'Apple',
    companyLogoUrl: 'assets/images/apple_logo.png',
    companyData: appleCompanyData,
    lastMessage: 'We will review your application and get back to you.',
    lastMessageTime: DateTime.now().subtract(const Duration(hours: 2)),
    messages: [
      Message(
        id: 'msg2_1',
        sender: MessageSender.user,
        text: 'Good morning, I applied for the iOS Developer role.',
        timestamp: DateTime.now().subtract(const Duration(hours: 2, minutes: 30)),
      ),
      Message(
        id: 'msg2_2',
        sender: MessageSender.company,
        text: 'Hello! We received your application. What can we help you with?',
        timestamp: DateTime.now().subtract(const Duration(hours: 2, minutes: 25)),
      ),
      Message(
        id: 'msg2_3',
        sender: MessageSender.user,
        text: 'I just wanted to confirm if all my documents were received.',
        timestamp: DateTime.now().subtract(const Duration(hours: 2, minutes: 20)),
      ),
      Message(
        id: 'msg2_4',
        sender: MessageSender.company,
        text: 'Yes, everything looks complete. We will review your application and get back to you.',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ],
  ),
  Conversation(
    id: 'conv3',
    companyName: 'Microsoft',
    companyLogoUrl: 'assets/images/microsoft_logo.png',
    companyData: microsoftCompanyData,
    lastMessage: 'Thank you for your interest.',
    lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
    messages: [
      Message(
        id: 'msg3_1',
        sender: MessageSender.user,
        text: 'Hi, I\'m interested in the Cloud Architect position.',
        timestamp: DateTime.now().subtract(const Duration(days: 1, minutes: 30)),
      ),
      Message(
        id: 'msg3_2',
        sender: MessageSender.company,
        text: 'Hello! Please apply through our careers page.',
        timestamp: DateTime.now().subtract(const Duration(days: 1, minutes: 25)),
      ),
      Message(
        id: 'msg3_3',
        sender: MessageSender.user,
        text: 'I already did. I just wanted to ask about the typical project size.',
        timestamp: DateTime.now().subtract(const Duration(days: 1, minutes: 20)),
      ),
      Message(
        id: 'msg3_4',
        sender: MessageSender.company,
        text: 'Thank you for your interest.',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ],
  ),
];

// ============= MOCK DATA from saved_job_provider.dart =============


// ============= MOCK DATA from user_profile.dart =============
class MockProfileData {
  static UserProfile getMockUserProfile() {
    return UserProfile(
      id: 1 ,
      fullName: 'Brandone Louis',
      location: 'California, United states',
      email: 'brandonelouis@gmail.com',
      phoneNumber: '619 3456 7890',
      countryCode: '+1',
      gender: 'male',
      imageUrl: null,
      aboutMe:
          'Passionate UI/UX Designer with 5+ years of experience creating beautiful and functional digital experiences.',
      followers: 120000,
      following: 23000,
      workExperiences: [
        WorkExperience(
          id: '1',
          jobTitle: 'Manager',
          company: 'Amazon Inc',
          startDate: DateTime(2015, 1),
          endDate: DateTime(2022, 2),
          isCurrentPosition: false,
          description:
              'Managed cross-functional teams and led product initiatives.',
        ),
      ],
      educations: [
        Education(
          id: '1',
          levelOfEducation: 'Bachelor of Information Technology',
          institutionName: 'University of Oxford',
          fieldOfStudy: 'Information Technology',
          startDate: DateTime(2010, 9),
          endDate: DateTime(2013, 8),
          isCurrentPosition: false,
        ),
      ],
      languages: [
        Language(
          id: '1',
          name: 'Indonesian',
          oralLevel: 10,
          writtenLevel: 10,
          isFirstLanguage: true,
        ),
        Language(
          id: '2',
          name: 'English',
          oralLevel: 8,
          writtenLevel: 8,
          isFirstLanguage: false,
        ),
      ],
      skills: [
        'Leadership',
        'Teamwork',
        'Visioner',
        'Target oriented',
        'Consistent',
        'Good communication skills',
      ],
      appreciations: [
        Appreciation(
          id: '1',
          title: 'Young Scientist',
          organization: 'Wireless Symposium (RWS)',
          date: DateTime(2014),
        ),
      ],
      resumes: [
        Resume(
          id: '1',
          fileName: 'Jamet kudasi - CV - UI/UX Designer',
          size: '867 Kb',
          uploadDate: DateTime(2022, 2, 14, 11, 30),
        ),
      ],
    );
  }
}
