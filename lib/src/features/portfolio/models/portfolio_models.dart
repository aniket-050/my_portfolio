import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum PortfolioSection { home, about, work, experience, skills, contact }

PortfolioSection? portfolioSectionFromAnchor(String anchor) {
  for (final section in PortfolioSection.values) {
    if (section.anchor == anchor) {
      return section;
    }
  }

  return null;
}

extension PortfolioSectionX on PortfolioSection {
  String get label => switch (this) {
    PortfolioSection.home => 'Home',
    PortfolioSection.about => 'About',
    PortfolioSection.work => 'Projects',
    PortfolioSection.experience => 'Experience',
    PortfolioSection.skills => 'Skills',
    PortfolioSection.contact => 'Contact',
  };

  String get anchor => switch (this) {
    PortfolioSection.home => 'home',
    PortfolioSection.about => 'about',
    PortfolioSection.work => 'projects',
    PortfolioSection.experience => 'experience',
    PortfolioSection.skills => 'skills',
    PortfolioSection.contact => 'contact',
  };
}

class PortfolioStat extends Equatable {
  const PortfolioStat({
    required this.value,
    required this.label,
    required this.detail,
  });

  final String value;
  final String label;
  final String detail;

  PortfolioStat copyWith({String? value, String? label, String? detail}) {
    return PortfolioStat(
      value: value ?? this.value,
      label: label ?? this.label,
      detail: detail ?? this.detail,
    );
  }

  @override
  List<Object?> get props => [value, label, detail];
}

class FocusArea extends Equatable {
  const FocusArea({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;

  @override
  List<Object?> get props => [title, description, icon];
}

class ExperienceItem extends Equatable {
  const ExperienceItem({
    required this.role,
    required this.company,
    required this.period,
    required this.location,
    required this.summary,
    required this.highlights,
    this.url,
  });

  final String role;
  final String company;
  final String period;
  final String location;
  final String summary;
  final List<String> highlights;
  final String? url;

  ExperienceItem copyWith({
    String? role,
    String? company,
    String? period,
    String? location,
    String? summary,
    List<String>? highlights,
    String? url,
  }) {
    return ExperienceItem(
      role: role ?? this.role,
      company: company ?? this.company,
      period: period ?? this.period,
      location: location ?? this.location,
      summary: summary ?? this.summary,
      highlights: highlights ?? this.highlights,
      url: url ?? this.url,
    );
  }

  @override
  List<Object?> get props => [
    role,
    company,
    period,
    location,
    summary,
    highlights,
    url,
  ];
}

class ProjectItem extends Equatable {
  const ProjectItem({
    required this.id,
    required this.title,
    required this.category,
    required this.timeline,
    required this.description,
    required this.contribution,
    required this.highlights,
    required this.stack,
  });

  final String id;
  final String title;
  final String category;
  final String timeline;
  final String description;
  final String contribution;
  final List<String> highlights;
  final List<String> stack;

  ProjectItem copyWith({
    String? id,
    String? title,
    String? category,
    String? timeline,
    String? description,
    String? contribution,
    List<String>? highlights,
    List<String>? stack,
  }) {
    return ProjectItem(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      timeline: timeline ?? this.timeline,
      description: description ?? this.description,
      contribution: contribution ?? this.contribution,
      highlights: highlights ?? this.highlights,
      stack: stack ?? this.stack,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    category,
    timeline,
    description,
    contribution,
    highlights,
    stack,
  ];
}

class SkillCategory extends Equatable {
  const SkillCategory({
    required this.title,
    required this.summary,
    required this.items,
  });

  final String title;
  final String summary;
  final List<String> items;

  SkillCategory copyWith({
    String? title,
    String? summary,
    List<String>? items,
  }) {
    return SkillCategory(
      title: title ?? this.title,
      summary: summary ?? this.summary,
      items: items ?? this.items,
    );
  }

  @override
  List<Object?> get props => [title, summary, items];
}

class AchievementItem extends Equatable {
  const AchievementItem({required this.value, required this.label});

  final String value;
  final String label;

  AchievementItem copyWith({String? value, String? label}) {
    return AchievementItem(
      value: value ?? this.value,
      label: label ?? this.label,
    );
  }

  @override
  List<Object?> get props => [value, label];
}

class ContactAction extends Equatable {
  const ContactAction({
    required this.title,
    required this.subtitle,
    required this.url,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final String url;
  final IconData icon;

  ContactAction copyWith({
    String? title,
    String? subtitle,
    String? url,
    IconData? icon,
  }) {
    return ContactAction(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      url: url ?? this.url,
      icon: icon ?? this.icon,
    );
  }

  @override
  List<Object?> get props => [title, subtitle, url, icon];
}
