import 'package:flutter/material.dart';

import '../models/portfolio_models.dart';

abstract final class PortfolioContent {
  static const String name = 'Aniket Parihar';
  static const String headline =
      'Flutter engineer shipping production apps with 60K+ Play Store installs.';
  static const String summary =
      'I design and ship production Flutter applications with strong ownership across UI, business logic, state management and API integration. 8 of my apps are live on Google Play, and my core strengths are Google Maps, GIS workflows, geofencing, live location tracking and responsive product experiences.';
  static const String location = 'Raipur, Chhattisgarh, India';
  static const String title = 'Software Engineer (Flutter)';
  static const String phone = '+91 87705 61223';
  static const String email = 'aniketparihar.0505@gmail.com';
  static const String profileAsset = 'assets/images/aniket_profile_cutout.png';
  static const String linkedIn =
      'https://www.linkedin.com/in/aniket-parihar-803955215/';
  static const String github = 'https://github.com/aniket-050';
  static const String codeChef = 'https://www.codechef.com/users/ani_0505';

  static const List<String> heroTags = [
    'Flutter',
    'BLoC',
    'Google Maps',
    'GIS',
    'Geofencing',
    'REST APIs',
  ];

  static const List<PortfolioStat> stats = [
    PortfolioStat(
      value: '08+',
      label: 'Apps Shipped',
      detail: 'Across real estate, education, attendance and commerce.',
    ),
    PortfolioStat(
      value: '03+',
      label: 'Years in Production',
      detail: 'Shipping business-critical mobile experiences since 2023.',
    ),
    PortfolioStat(
      value: '60K+',
      label: 'Play Store Installs',
      detail: 'Across live apps I built, extended or modernised.',
    ),
  ];

  static const List<FocusArea> focusAreas = [
    FocusArea(
      title: 'Location-first systems',
      description:
          'Google Maps integration, GIS-backed interfaces, geofencing and live tracking for real-world products.',
      icon: Icons.location_on_rounded,
    ),
    FocusArea(
      title: 'Product delivery',
      description:
          'From UI architecture to API integration, I build reliable flows that keep dashboards, payments and users in sync.',
      icon: Icons.auto_graph_rounded,
    ),
    FocusArea(
      title: 'Professional state management',
      description:
          'Comfortable with BLoC, Riverpod and clean component design for maintainable, scalable applications.',
      icon: Icons.account_tree_rounded,
    ),
  ];

  static const String _digikraftProjects =
      'https://digikraftsocial.com/feature';

  static const List<ProjectItem> projects = [
    ProjectItem(
      id: 'emilo',
      title: 'eMILO',
      category: 'Social networking app',
      timeline: 'Emilo Ventures Pvt Ltd • Current work',
      description:
          'A social media app that goes beyond the feed: friends, chat, posts, photos, videos and stories, plus Soft Corner, a private space made just for two.',
      contribution:
          'Building and shipping Flutter features at Emilo Ventures for a live consumer social app, from feed and media experiences to chat and privacy-focused flows.',
      highlights: [
        'Feed, stories, photo and video sharing in one social experience',
        'Friends, real-time chat and community features',
        'Soft Corner: private couple space with AI-powered mutual-crush matching',
      ],
      stack: ['Flutter', 'Social Feed', 'Real-time Chat', 'Media'],
      links: [
        ProjectLink(
          label: 'Google Play',
          url: 'https://play.google.com/store/apps/details?id=com.emilo.app',
        ),
      ],
      images: [
        'assets/images/projects/emilo_1.webp',
        'assets/images/projects/emilo_2.webp',
        'assets/images/projects/emilo_3.webp',
      ],
      iconAsset: 'assets/images/projects/emilo_icon.webp',
    ),
    ProjectItem(
      id: 'protestim',
      title: 'PROTestim',
      category: 'Government exam proctoring • Uzbekistan',
      timeline: 'Digikraft Social • Flutter + Riverpod',
      description:
          'An Uzbekistan-based government entrance exam platform where applicants take proctored tests that simulate the real exam and see which universities they can get into.',
      contribution:
          'Built the Flutter app at Digikraft Social using Riverpod for state management across exam sessions, results and university insights.',
      highlights: [
        'Proctored, timed test sessions that mirror the real entrance exam',
        'University rankings, required subjects and passing-score insights',
        'Parent view to follow an applicant\'s preparation and progress',
      ],
      stack: ['Flutter', 'Riverpod', 'REST APIs', 'Exam Proctoring'],
      links: [
        ProjectLink(
          label: 'Google Play',
          url: 'https://play.google.com/store/apps/details?id=uz.testim',
        ),
        ProjectLink(label: 'Digikraft projects', url: _digikraftProjects),
      ],
      images: [
        'assets/images/projects/protestim_1.webp',
        'assets/images/projects/protestim_2.webp',
        'assets/images/projects/protestim_3.webp',
      ],
      iconAsset: 'assets/images/projects/protestim_icon.webp',
      metric: '10K+ downloads',
    ),
    ProjectItem(
      id: 'flashforce',
      title: 'Flash Force',
      category: 'Field-force attendance & tracking',
      timeline: 'Production feature ownership',
      description:
          'An enterprise workforce attendance and sales-tracking app that helps organisations verify presence, follow field routes and report on productivity.',
      contribution:
          'Implemented geofenced attendance, live employee tracking and secure role-driven workflows.',
      highlights: [
        'Geofence-validated punch-in and punch-out',
        'Live location and route tracking with online and offline support',
        'Attendance reports, history and role-based dashboards',
      ],
      stack: ['Flutter', 'Geofencing', 'Google Maps SDK', 'RBAC'],
      links: [
        ProjectLink(
          label: 'Google Play',
          url:
              'https://play.google.com/store/apps/details?id=com.origainglobalcorp.flashforce',
        ),
        ProjectLink(
          label: 'Website',
          url: 'https://appwizz.in/flash-force/index.php',
        ),
      ],
      images: [
        'assets/images/projects/flashforce_1.webp',
        'assets/images/projects/flashforce_2.webp',
        'assets/images/projects/flashforce_3.webp',
      ],
      iconAsset: 'assets/images/projects/flashforce_icon.webp',
      metric: '500+ downloads',
    ),
    ProjectItem(
      id: 'attendance',
      title: 'Attendance Management App',
      category: 'Location-based workforce system',
      timeline: 'Digikraft Social • Flutter',
      description:
          'A mobile application for tracking and managing employee attendance efficiently, with swipe-to-check-in, team views and attendance insights for HR.',
      contribution:
          'Implemented geofenced attendance, live employee tracking and secure role-driven workflows.',
      highlights: [
        'Geofence-validated check-in and check-out',
        'Self and team attendance history with location context',
        'HR dashboard with present, on-leave and remote-work insights',
      ],
      stack: ['Flutter', 'Geofencing', 'Google Maps SDK', 'RBAC'],
      links: [
        ProjectLink(label: 'Digikraft projects', url: _digikraftProjects),
      ],
      images: ['assets/images/projects/attendance_mockup.jpg'],
    ),
    ProjectItem(
      id: 'gharkasathi',
      title: 'GharKaSathi',
      category: 'Real estate + home services',
      timeline: 'Lead Flutter developer',
      description:
          'Chhattisgarh\'s unified property and home platform: zero-brokerage real estate, turnkey construction, modular interiors and 30-minute home repairs across Raipur, Bhilai, Durg and Bilaspur.',
      contribution:
          'Built high-ownership Flutter modules, property discovery flows and service booking journeys.',
      highlights: [
        'GIS-based property visualisation with accurate location tagging',
        'Partner tracking and service-area mapping for live operations',
        'Real-time booking flows spanning property and home services',
      ],
      stack: ['Flutter', 'Google Maps', 'GIS', 'REST APIs'],
      links: [
        ProjectLink(label: 'Website', url: 'https://www.gharkasathi.com'),
      ],
      iconAsset: 'assets/images/projects/gharkasathi_icon.png',
    ),
    ProjectItem(
      id: 'competition-community',
      title: 'Competition Community',
      category: 'EdTech • React Native modernisation',
      timeline: 'Digikraft Social • Maintenance & migration',
      description:
          'A learning app for competitive exam preparation with structured lessons, topic-wise material and regular updates, used by 50K+ learners.',
      contribution:
          'Took over an outdated React Native codebase for maintenance and migrated it to the latest React Native version, bringing the app back to a running, releasable state.',
      highlights: [
        'Migrated the legacy codebase to the latest React Native version',
        'Updated all configuration, native build setup and dependency packages',
        'Resolved breaking changes and restored a stable, production-ready build',
      ],
      stack: ['React Native', 'JavaScript', 'Native Build Config', 'Upgrades'],
      links: [
        ProjectLink(
          label: 'Google Play',
          url: 'https://play.google.com/store/apps/details?id=com.cocomobile1',
        ),
        ProjectLink(label: 'Website', url: 'https://www.cocoraipur.com'),
      ],
      images: [
        'assets/images/projects/coco_1.webp',
        'assets/images/projects/coco_2.webp',
        'assets/images/projects/coco_3.webp',
      ],
      iconAsset: 'assets/images/projects/coco_icon.webp',
      metric: '50K+ downloads',
    ),
    ProjectItem(
      id: 'fixhr',
      title: 'FixHR',
      category: 'HR & attendance management',
      timeline: 'Fixing Dots • Flutter',
      description:
          'Mobile and web HR software for startups and growing businesses that simplifies attendance, leave and work-hour tracking.',
      contribution:
          'Worked on the Flutter app for attendance, leave and allowance workflows connected to the HR backend.',
      highlights: [
        'Attendance, leave and work-hour tracking for teams',
        'TA/DA allowance calculated from background location tracking',
        'Encrypted location data used only for allowance calculation',
      ],
      stack: ['Flutter', 'Background Location', 'REST APIs', 'HRMS'],
      links: [
        ProjectLink(
          label: 'Google Play',
          url: 'https://play.google.com/store/apps/details?id=com.fd.fixHR',
        ),
      ],
      images: [
        'assets/images/projects/fixhr_1.webp',
        'assets/images/projects/fixhr_2.webp',
        'assets/images/projects/fixhr_3.webp',
      ],
      iconAsset: 'assets/images/projects/fixhr_icon.webp',
      metric: '1K+ downloads',
    ),
    ProjectItem(
      id: 'fixq',
      title: 'FixQ',
      category: 'Quotation workflow platform',
      timeline: 'Fixing Dots • Flutter + Laravel',
      description:
          'A quotation management app for businesses to create branded price proposals, preview them and share them with clients as PDF, print, WhatsApp or email.',
      contribution:
          'Delivered frontend flows, pricing logic integration and robust REST-backed approval journeys.',
      highlights: [
        'Dashboard, client list and quotation builder modules',
        'PDF export, print and WhatsApp / email sharing',
        'Business branding with logo, address, colours and fonts',
      ],
      stack: ['Flutter', 'Laravel', 'REST APIs', 'PDF'],
      links: [
        ProjectLink(
          label: 'Google Play',
          url:
              'https://play.google.com/store/apps/details?id=com.fixingdots.htkc.fixq',
        ),
        ProjectLink(label: 'Website', url: 'https://fixq.app'),
      ],
      images: [
        'assets/images/projects/fixq_1.webp',
        'assets/images/projects/fixq_2.webp',
        'assets/images/projects/fixq_3.webp',
      ],
      iconAsset: 'assets/images/projects/fixq_icon.webp',
    ),
    ProjectItem(
      id: 'bbk',
      title: 'Bluebirds Kindergarten (BBK)',
      category: 'School management • Parent app',
      timeline: 'Fixing Dots • Laravel APIs + Flutter',
      description:
          'Kindergarten management software for parents and staff, with live classroom streaming, attendance, fees, timetable and daily activities across web, mobile and tablet.',
      contribution:
          'Implemented the REST APIs in Laravel and integrated them on the Flutter side, owning features end to end.',
      highlights: [
        'Live classroom streaming for parents',
        'Attendance, fees, school calendar, timetable and food curriculum',
        'Student ID cards, gallery, daily activities and notifications',
      ],
      stack: ['Flutter', 'Laravel', 'REST APIs', 'Full-stack'],
      links: [
        ProjectLink(
          label: 'Google Play',
          url:
              'https://play.google.com/store/apps/details?id=com.fixingdots.htkc.bbk_parent',
        ),
      ],
      images: [
        'assets/images/projects/bbk_1.webp',
        'assets/images/projects/bbk_2.webp',
        'assets/images/projects/bbk_3.webp',
      ],
      iconAsset: 'assets/images/projects/bbk_icon.webp',
    ),
    ProjectItem(
      id: 'mbc',
      title: 'My Baby Connect (MBC)',
      category: 'School management • Admin app',
      timeline: 'Fixing Dots • Laravel APIs + Flutter',
      description:
          'Admin app for a kindergarten management platform to run classrooms, staff, students, fees and parent communication from one place.',
      contribution:
          'Implemented the REST APIs in Laravel and integrated them on the Flutter side, owning features end to end.',
      highlights: [
        'Student, staff, attendance and fee management',
        'Timetable, curriculum, food menu and school calendar',
        'Live classroom streaming and parent notifications',
      ],
      stack: ['Flutter', 'Laravel', 'REST APIs', 'Full-stack'],
      links: [
        ProjectLink(
          label: 'Google Play',
          url:
              'https://play.google.com/store/apps/details?id=com.fixingdots.htkc.mbc_admin',
        ),
      ],
      images: [
        'assets/images/projects/mbc_1.webp',
        'assets/images/projects/mbc_2.webp',
        'assets/images/projects/mbc_3.webp',
      ],
      iconAsset: 'assets/images/projects/mbc_icon.webp',
    ),
    ProjectItem(
      id: 'grocery',
      title: 'Grocery App',
      category: 'Grocery e-commerce',
      timeline: 'Digikraft Social • Flutter',
      description:
          'A mobile app for online grocery shopping with category browsing, special offers and a quick checkout.',
      contribution:
          'Built the Flutter shopping experience, from catalogue and cart to checkout and payment flows.',
      highlights: [
        'Category browsing, search and special offers',
        'Cart, delivery address and order summary',
        'Payment-enabled checkout',
      ],
      stack: ['Flutter', 'E-commerce', 'Payments', 'REST APIs'],
      links: [
        ProjectLink(label: 'Digikraft projects', url: _digikraftProjects),
      ],
      images: ['assets/images/projects/grocery_mockup.jpg'],
    ),
  ];

  static const List<ExperienceItem> experience = [
    ExperienceItem(
      role: 'Flutter Developer',
      company: 'Emilo Ventures Pvt Ltd',
      period: 'Jun 2026 - Present',
      location: 'India',
      summary:
          'Building eMILO, a live social networking app on Google Play, with Flutter.',
      highlights: [
        'Shipping feed, stories, photo and video sharing features',
        'Working on friends, real-time chat and community experiences',
        'Contributing to Soft Corner, a private couple space with AI-powered matching',
      ],
      url: 'https://play.google.com/store/apps/details?id=com.emilo.app',
    ),
    ExperienceItem(
      role: 'Mobile Application Developer',
      company: 'Digikraft Social',
      period: 'May 2024 - Jun 2026',
      location: 'Raipur, India',
      summary:
          'Led Flutter development across exam proctoring, grocery, attendance, LMS and e-commerce products, including PROTestim (10K+ downloads).',
      highlights: [
        'Built PROTestim, a government exam proctoring app for Uzbekistan, with Flutter and Riverpod',
        'Implemented Google Maps, GIS tracking, geofencing and live location monitoring',
        'Migrated Competition Community (50K+ downloads) from an outdated codebase to the latest React Native',
        'Built secure authentication, real-time dashboards and payment-enabled workflows',
      ],
      url: 'https://demo.digikraftsocial.com/',
    ),
    ExperienceItem(
      role: 'Flutter Developer',
      company: 'Fixing Dots',
      period: 'Jun 2023 - May 2024',
      location: 'Raipur, India',
      summary:
          'Delivered Flutter UI, business logic and Laravel APIs for FixQ, FixHR and the BBK / My Baby Connect school platforms.',
      highlights: [
        'Built dashboards, quotation workflows and role-based access modules for FixQ',
        'Implemented Laravel REST APIs and integrated them in Flutter for BBK and MBC',
        'Collaborated on API integration, data verification and reusable component systems',
      ],
      url: 'https://fixingdots.com/',
    ),
  ];

  static const List<SkillCategory> skillCategories = [
    SkillCategory(
      title: 'Mobile & architecture',
      summary:
          'Production Flutter development with structured state and scalable code organisation.',
      items: [
        'Flutter',
        'BLoC Pattern',
        'Riverpod',
        'GetX',
        'Clean Architecture',
        'MVVM / MVC',
      ],
    ),
    SkillCategory(
      title: 'Maps, GIS & real-time',
      summary:
          'Strong practical experience in products that depend on place, movement and operational visibility.',
      items: [
        'Google Maps SDK',
        'GIS Concepts',
        'Geofencing',
        'Live Location Tracking',
        'Real-Time Systems',
      ],
    ),
    SkillCategory(
      title: 'Backend collaboration',
      summary:
          'Comfortable delivering complete user flows in API-driven products with secure access control.',
      items: [
        'REST APIs',
        'Laravel',
        'Authentication',
        'Role-Based Access Control',
        'Performance Optimisation',
      ],
    ),
    SkillCategory(
      title: 'Languages & tooling',
      summary:
          'Practical tooling for shipping, testing and collaborating in real-world product teams.',
      items: [
        'Dart',
        'JavaScript',
        'C / C++',
        'Git & GitHub',
        'Postman',
        'Thunder Client',
      ],
    ),
  ];

  static const List<AchievementItem> achievements = [
    AchievementItem(
      value: '4th',
      label: 'Rank in overall CSE branch till 8th semester',
    ),
    AchievementItem(value: '8', label: 'Apps live on Google Play'),
    AchievementItem(value: '8.14', label: 'B.Tech CGPA from CSVTU'),
  ];

  static const List<ContactAction> contactActions = [
    ContactAction(
      title: 'Email',
      subtitle: email,
      url: 'mailto:aniketparihar.0505@gmail.com',
      icon: Icons.mail_outline_rounded,
    ),
    ContactAction(
      title: 'LinkedIn',
      subtitle: 'aniket-parihar-803955215',
      url: linkedIn,
      icon: Icons.work_outline_rounded,
    ),
    ContactAction(
      title: 'GitHub',
      subtitle: 'aniket-050',
      url: github,
      icon: Icons.code_rounded,
    ),
    ContactAction(
      title: 'CodeChef',
      subtitle: 'ani_0505',
      url: codeChef,
      icon: Icons.emoji_events_outlined,
    ),
  ];

  static const String educationTitle =
      'Bachelor of Technology (Computer Science)';
  static const String educationSchool =
      'Chhattisgarh Swami Vivekanand Technical University';
  static const String educationPeriod = '2019 - 2023';
  static const String educationResult = 'CGPA: 8.14';
}
