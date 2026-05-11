import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum PortfolioSection { home, about, services, works, blogs, contact }

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
    PortfolioSection.services => 'Services',
    PortfolioSection.works => 'Works',
    PortfolioSection.blogs => 'Blogs',
    PortfolioSection.contact => 'Contact',
  };

  String get anchor => switch (this) {
    PortfolioSection.home => 'home',
    PortfolioSection.about => 'about',
    PortfolioSection.services => 'services',
    PortfolioSection.works => 'works',
    PortfolioSection.blogs => 'blogs',
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

  @override
  List<Object?> get props => [title, summary, items];
}

class AchievementItem extends Equatable {
  const AchievementItem({required this.value, required this.label});

  final String value;
  final String label;

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

  @override
  List<Object?> get props => [title, subtitle, url, icon];
}
