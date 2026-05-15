import 'dart:async';

import 'package:flutter/material.dart';

import '../models/portfolio_models.dart';
import 'portfolio_backend.dart';
import 'portfolio_content.dart';

class EditablePortfolioStore extends ChangeNotifier {
  EditablePortfolioStore({this.backend})
    : name = PortfolioContent.name,
      headline = PortfolioContent.headline,
      summary = PortfolioContent.summary,
      location = PortfolioContent.location,
      title = PortfolioContent.title,
      phone = PortfolioContent.phone,
      email = PortfolioContent.email,
      profileAsset = PortfolioContent.profileAsset,
      linkedIn = PortfolioContent.linkedIn,
      github = PortfolioContent.github,
      codeChef = PortfolioContent.codeChef,
      heroTags = List<String>.from(PortfolioContent.heroTags),
      stats = List<PortfolioStat>.from(PortfolioContent.stats),
      focusAreas = List<FocusArea>.from(PortfolioContent.focusAreas),
      projects = List<ProjectItem>.from(PortfolioContent.projects),
      experience = List<ExperienceItem>.from(PortfolioContent.experience),
      skillCategories = List<SkillCategory>.from(
        PortfolioContent.skillCategories,
      ),
      achievements = List<AchievementItem>.from(PortfolioContent.achievements),
      contactActions = List<ContactAction>.from(
        PortfolioContent.contactActions,
      ),
      educationTitle = PortfolioContent.educationTitle,
      educationSchool = PortfolioContent.educationSchool,
      educationPeriod = PortfolioContent.educationPeriod,
      educationResult = PortfolioContent.educationResult;

  final PortfolioBackend? backend;

  String name;
  String headline;
  String summary;
  String location;
  String title;
  String phone;
  String email;
  String profileAsset;
  String linkedIn;
  String github;
  String codeChef;
  List<String> heroTags;
  List<PortfolioStat> stats;
  List<FocusArea> focusAreas;
  List<ProjectItem> projects;
  List<ExperienceItem> experience;
  List<SkillCategory> skillCategories;
  List<AchievementItem> achievements;
  List<ContactAction> contactActions;
  String educationTitle;
  String educationSchool;
  String educationPeriod;
  String educationResult;

  Future<void> loadRemote() async {
    final remote = await backend?.loadPortfolioContent();
    if (remote == null) {
      return;
    }

    _applyMap(remote);
    notifyListeners();
  }

  void updateProfile({
    required String name,
    required String title,
    required String headline,
    required String summary,
    required String location,
    required String phone,
    required String email,
    required String linkedIn,
    required String github,
    required String codeChef,
    required String educationTitle,
    required String educationSchool,
    required String educationPeriod,
    required String educationResult,
  }) {
    this.name = name.trim();
    this.title = title.trim();
    this.headline = headline.trim();
    this.summary = summary.trim();
    this.location = location.trim();
    this.phone = phone.trim();
    this.email = email.trim();
    this.linkedIn = linkedIn.trim();
    this.github = github.trim();
    this.codeChef = codeChef.trim();
    this.educationTitle = educationTitle.trim();
    this.educationSchool = educationSchool.trim();
    this.educationPeriod = educationPeriod.trim();
    this.educationResult = educationResult.trim();
    _commit();
  }

  void updateProfileAsset(String asset) {
    profileAsset = asset;
    _commit();
  }

  void updateHeroTags(List<String> tags) {
    heroTags = tags.where((tag) => tag.trim().isNotEmpty).toList();
    _commit();
  }

  void upsertStat(int? index, PortfolioStat item) {
    stats = _upsert(stats, index, item);
    _commit();
  }

  void deleteStat(int index) {
    stats = _delete(stats, index);
    _commit();
  }

  void upsertProject(int? index, ProjectItem item) {
    projects = _upsert(projects, index, item);
    _commit();
  }

  void deleteProject(int index) {
    projects = _delete(projects, index);
    _commit();
  }

  void upsertExperience(int? index, ExperienceItem item) {
    experience = _upsert(experience, index, item);
    _commit();
  }

  void deleteExperience(int index) {
    experience = _delete(experience, index);
    _commit();
  }

  void upsertSkillCategory(int? index, SkillCategory item) {
    skillCategories = _upsert(skillCategories, index, item);
    _commit();
  }

  void deleteSkillCategory(int index) {
    skillCategories = _delete(skillCategories, index);
    _commit();
  }

  void upsertAchievement(int? index, AchievementItem item) {
    achievements = _upsert(achievements, index, item);
    _commit();
  }

  void deleteAchievement(int index) {
    achievements = _delete(achievements, index);
    _commit();
  }

  void upsertContactAction(int? index, ContactAction item) {
    contactActions = _upsert(contactActions, index, item);
    _commit();
  }

  void deleteContactAction(int index) {
    contactActions = _delete(contactActions, index);
    _commit();
  }

  void resetAll() {
    name = PortfolioContent.name;
    headline = PortfolioContent.headline;
    summary = PortfolioContent.summary;
    location = PortfolioContent.location;
    title = PortfolioContent.title;
    phone = PortfolioContent.phone;
    email = PortfolioContent.email;
    profileAsset = PortfolioContent.profileAsset;
    linkedIn = PortfolioContent.linkedIn;
    github = PortfolioContent.github;
    codeChef = PortfolioContent.codeChef;
    heroTags = List<String>.from(PortfolioContent.heroTags);
    stats = List<PortfolioStat>.from(PortfolioContent.stats);
    focusAreas = List<FocusArea>.from(PortfolioContent.focusAreas);
    projects = List<ProjectItem>.from(PortfolioContent.projects);
    experience = List<ExperienceItem>.from(PortfolioContent.experience);
    skillCategories = List<SkillCategory>.from(
      PortfolioContent.skillCategories,
    );
    achievements = List<AchievementItem>.from(PortfolioContent.achievements);
    contactActions = List<ContactAction>.from(PortfolioContent.contactActions);
    educationTitle = PortfolioContent.educationTitle;
    educationSchool = PortfolioContent.educationSchool;
    educationPeriod = PortfolioContent.educationPeriod;
    educationResult = PortfolioContent.educationResult;
    _commit();
  }

  Map<String, Object?> toJson() {
    return {
      'name': name,
      'headline': headline,
      'summary': summary,
      'location': location,
      'title': title,
      'phone': phone,
      'email': email,
      'profileAsset': profileAsset,
      'linkedIn': linkedIn,
      'github': github,
      'codeChef': codeChef,
      'heroTags': heroTags,
      'stats': stats.map(_statToJson).toList(),
      'projects': projects.map(_projectToJson).toList(),
      'experience': experience.map(_experienceToJson).toList(),
      'skillCategories': skillCategories.map(_skillToJson).toList(),
      'achievements': achievements.map(_achievementToJson).toList(),
      'contactActions': contactActions.map(_contactToJson).toList(),
      'educationTitle': educationTitle,
      'educationSchool': educationSchool,
      'educationPeriod': educationPeriod,
      'educationResult': educationResult,
    };
  }

  void _applyMap(Map<String, Object?> json) {
    name = _string(json['name'], name);
    headline = _string(json['headline'], headline);
    summary = _string(json['summary'], summary);
    location = _string(json['location'], location);
    title = _string(json['title'], title);
    phone = _string(json['phone'], phone);
    email = _string(json['email'], email);
    profileAsset = _string(json['profileAsset'], profileAsset);
    linkedIn = _string(json['linkedIn'], linkedIn);
    github = _string(json['github'], github);
    codeChef = _string(json['codeChef'], codeChef);
    heroTags = _stringList(json['heroTags'], heroTags);
    stats = _list(json['stats'], _statFromJson, stats);
    projects = _list(json['projects'], _projectFromJson, projects);
    experience = _list(json['experience'], _experienceFromJson, experience);
    skillCategories = _list(
      json['skillCategories'],
      _skillFromJson,
      skillCategories,
    );
    achievements = _list(
      json['achievements'],
      _achievementFromJson,
      achievements,
    );
    contactActions = _list(
      json['contactActions'],
      _contactFromJson,
      contactActions,
    );
    educationTitle = _string(json['educationTitle'], educationTitle);
    educationSchool = _string(json['educationSchool'], educationSchool);
    educationPeriod = _string(json['educationPeriod'], educationPeriod);
    educationResult = _string(json['educationResult'], educationResult);
  }

  void _commit() {
    notifyListeners();
    unawaited(
      (backend?.savePortfolioContent(toJson()) ?? Future<void>.value())
          .catchError((_) {}),
    );
  }

  List<T> _upsert<T>(List<T> items, int? index, T item) {
    final next = List<T>.from(items);
    if (index == null || index < 0 || index >= next.length) {
      next.add(item);
    } else {
      next[index] = item;
    }
    return next;
  }

  List<T> _delete<T>(List<T> items, int index) {
    if (index < 0 || index >= items.length) {
      return items;
    }
    return List<T>.from(items)..removeAt(index);
  }

  String _string(Object? value, String fallback) {
    return value is String && value.trim().isNotEmpty ? value : fallback;
  }

  List<String> _stringList(Object? value, List<String> fallback) {
    if (value is! List) {
      return fallback;
    }
    return value
        .whereType<String>()
        .where((item) => item.trim().isNotEmpty)
        .toList();
  }

  List<T> _list<T>(
    Object? value,
    T Function(Map<String, Object?> json) mapper,
    List<T> fallback,
  ) {
    if (value is! List) {
      return fallback;
    }
    final parsed = value
        .whereType<Map>()
        .map((item) => mapper(Map<String, Object?>.from(item)))
        .toList();
    return parsed.isEmpty ? fallback : parsed;
  }

  Map<String, Object?> _statToJson(PortfolioStat item) => {
    'value': item.value,
    'label': item.label,
    'detail': item.detail,
  };

  PortfolioStat _statFromJson(Map<String, Object?> json) => PortfolioStat(
    value: _string(json['value'], ''),
    label: _string(json['label'], ''),
    detail: _string(json['detail'], ''),
  );

  Map<String, Object?> _projectToJson(ProjectItem item) => {
    'id': item.id,
    'title': item.title,
    'category': item.category,
    'timeline': item.timeline,
    'description': item.description,
    'contribution': item.contribution,
    'highlights': item.highlights,
    'stack': item.stack,
  };

  ProjectItem _projectFromJson(Map<String, Object?> json) => ProjectItem(
    id: _string(json['id'], DateTime.now().microsecondsSinceEpoch.toString()),
    title: _string(json['title'], ''),
    category: _string(json['category'], ''),
    timeline: _string(json['timeline'], ''),
    description: _string(json['description'], ''),
    contribution: _string(json['contribution'], ''),
    highlights: _stringList(json['highlights'], const []),
    stack: _stringList(json['stack'], const []),
  );

  Map<String, Object?> _experienceToJson(ExperienceItem item) => {
    'role': item.role,
    'company': item.company,
    'period': item.period,
    'location': item.location,
    'summary': item.summary,
    'highlights': item.highlights,
    'url': item.url,
  };

  ExperienceItem _experienceFromJson(Map<String, Object?> json) =>
      ExperienceItem(
        role: _string(json['role'], ''),
        company: _string(json['company'], ''),
        period: _string(json['period'], ''),
        location: _string(json['location'], ''),
        summary: _string(json['summary'], ''),
        highlights: _stringList(json['highlights'], const []),
        url: json['url'] is String ? json['url']! as String : null,
      );

  Map<String, Object?> _skillToJson(SkillCategory item) => {
    'title': item.title,
    'summary': item.summary,
    'items': item.items,
  };

  SkillCategory _skillFromJson(Map<String, Object?> json) => SkillCategory(
    title: _string(json['title'], ''),
    summary: _string(json['summary'], ''),
    items: _stringList(json['items'], const []),
  );

  Map<String, Object?> _achievementToJson(AchievementItem item) => {
    'value': item.value,
    'label': item.label,
  };

  AchievementItem _achievementFromJson(Map<String, Object?> json) =>
      AchievementItem(
        value: _string(json['value'], ''),
        label: _string(json['label'], ''),
      );

  Map<String, Object?> _contactToJson(ContactAction item) => {
    'title': item.title,
    'subtitle': item.subtitle,
    'url': item.url,
  };

  ContactAction _contactFromJson(Map<String, Object?> json) => ContactAction(
    title: _string(json['title'], ''),
    subtitle: _string(json['subtitle'], ''),
    url: _string(json['url'], ''),
    icon: Icons.link_rounded,
  );
}

class PortfolioScope extends InheritedNotifier<EditablePortfolioStore> {
  const PortfolioScope({
    required EditablePortfolioStore store,
    required super.child,
    super.key,
  }) : super(notifier: store);

  static EditablePortfolioStore of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<PortfolioScope>();
    assert(scope?.notifier != null, 'PortfolioScope is missing.');
    return scope!.notifier!;
  }

  static EditablePortfolioStore read(BuildContext context) {
    final element = context
        .getElementForInheritedWidgetOfExactType<PortfolioScope>();
    final scope = element?.widget as PortfolioScope?;
    assert(scope?.notifier != null, 'PortfolioScope is missing.');
    return scope!.notifier!;
  }
}
