import 'package:flutter/material.dart';

import '../models/portfolio_models.dart';

abstract final class PortfolioContent {
  static const String name = 'Aniket Parihar';
  static const String headline =
      'Flutter engineer building products around maps, motion and scale.';
  static const String summary =
      'I design and ship production Flutter applications with strong ownership across UI, business logic, state management and API integration. My core strengths are Google Maps, GIS workflows, geofencing, live location tracking and responsive product experiences.';
  static const String location = 'Raipur, Chhattisgarh, India';
  static const String title = 'Software Engineer (Flutter)';
  static const String phone = '+91 87705 61223';
  static const String email = 'aniketparihar.0505@gmail.com';
  static const String profileAsset = 'assets/images/aniket_profile.jpeg';
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
      value: '02+',
      label: 'Years in Production',
      detail: 'Shipping business-critical mobile experiences since 2023.',
    ),
    PortfolioStat(
      value: '85%',
      label: 'Ownership',
      detail: 'Hands-on contribution on multiple production Flutter projects.',
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

  static const List<ProjectItem> projects = [
    ProjectItem(
      id: 'gharkasathi',
      title: 'GharKaSathi',
      category: 'Real estate + home services',
      timeline: 'Lead Flutter contribution • 70-80%',
      description:
          'A property and services platform covering buy, sell, rent and lease journeys with location-aware discovery at the center.',
      contribution:
          'Built high-ownership Flutter modules, property discovery flows and service booking journeys.',
      highlights: [
        'GIS-based property visualisation with accurate location tagging',
        'Partner tracking and service-area mapping for live operations',
        'Real-time booking flows spanning property and home services',
      ],
      stack: ['Flutter', 'Google Maps', 'GIS', 'REST APIs'],
    ),
    ProjectItem(
      id: 'attendance',
      title: 'Attendance Management Application',
      category: 'Location-based workforce system',
      timeline: 'Production feature ownership',
      description:
          'Attendance tracking designed around verified presence, movement context and role-based operational visibility.',
      contribution:
          'Implemented geofenced attendance, live employee tracking and secure role-driven workflows.',
      highlights: [
        'Punch-in and punch-out powered by geofencing rules',
        'Live location tracking integrated into workforce visibility',
        'Real-time attendance status updates for multiple user roles',
      ],
      stack: ['Flutter', 'Geofencing', 'Google Maps SDK', 'RBAC'],
    ),
    ProjectItem(
      id: 'fixq',
      title: 'FixQ',
      category: 'Quotation workflow platform',
      timeline: 'Flutter + Laravel collaboration',
      description:
          'A quotation management product with dashboards, approval pipelines and pricing-focused workflows.',
      contribution:
          'Delivered frontend flows, pricing logic integration and robust REST-backed approval journeys.',
      highlights: [
        'Dashboard and quotation builder modules',
        'Authentication, pricing logic and approval pipeline support',
        'Role-aware experiences for complex quotation operations',
      ],
      stack: ['Flutter', 'Laravel', 'REST APIs', 'Business Logic'],
    ),
    ProjectItem(
      id: 'digikraft',
      title: 'Digikraft Product Suite',
      category: 'Exam, grocery, LMS and e-commerce',
      timeline: 'May 2024 - Present',
      description:
          'A multi-product Flutter delivery stream spanning assessment, commerce and learning use cases.',
      contribution:
          'Contributed across UI, state handling and API-connected flows for multiple consumer and enterprise apps.',
      highlights: [
        'Secure authentication and role-driven dashboards',
        'Payment-enabled workflows and real-time operational features',
        'Cross-product delivery across exam, grocery, LMS and e-commerce apps',
      ],
      stack: ['Flutter', 'Payments', 'Dashboards', 'API Integration'],
    ),
  ];

  static const List<ExperienceItem> experience = [
    ExperienceItem(
      role: 'Mobile Application Developer',
      company: 'Digikraft Social',
      period: 'May 2024 - Present',
      location: 'Raipur, India',
      summary:
          'Contributing 70-85% of Flutter development across exam, grocery, attendance, LMS and e-commerce products.',
      highlights: [
        'Implemented Google Maps, GIS tracking, geofencing and live location monitoring',
        'Built secure authentication, real-time dashboards and payment-enabled workflows',
        'Worked across multiple production apps while maintaining UX quality and delivery speed',
      ],
      url: 'https://demo.digikraftsocial.com/',
    ),
    ExperienceItem(
      role: 'Flutter Developer',
      company: 'Fixing Dots',
      period: 'Jun 2023 - May 2024',
      location: 'Raipur, India',
      summary:
          'Delivered 60-70% of Flutter UI and business logic for a quotation management platform backed by Laravel APIs.',
      highlights: [
        'Built dashboards, quotation workflows and role-based access modules',
        'Collaborated on API integration, data verification and reusable component systems',
        'Supported a complex quotation product with production-ready workflows',
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
    AchievementItem(
      value: '100+',
      label: 'Coding problems solved across platforms',
    ),
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
      title: 'Call',
      subtitle: phone,
      url: 'tel:+918770561223',
      icon: Icons.call_outlined,
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
