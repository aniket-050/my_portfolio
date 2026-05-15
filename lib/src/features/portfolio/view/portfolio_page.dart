import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/utils/breakpoints.dart';
import '../../../core/widgets/reveal_on_scroll.dart';
import '../bloc/portfolio_bloc.dart';
import '../data/editable_portfolio_store.dart';
import '../models/portfolio_models.dart';

class PortfolioPage extends StatefulWidget {
  const PortfolioPage({super.key});

  @override
  State<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
  late final ScrollController _scrollController;
  late final Map<PortfolioSection, GlobalKey> _sectionKeys;
  double _scrollProgress = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_handleScroll);
    _sectionKeys = {
      for (final section in PortfolioSection.values)
        section: GlobalKey(debugLabel: section.anchor),
    };
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleScroll();
      final section = portfolioSectionFromAnchor(Uri.base.fragment);
      if (section != null && mounted) {
        context.read<PortfolioBloc>().add(PortfolioSectionRequested(section));
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients || !mounted) {
      return;
    }

    final maxScrollExtent = _scrollController.position.maxScrollExtent;
    final double nextProgress = maxScrollExtent <= 0
        ? 0.0
        : (_scrollController.offset / maxScrollExtent)
              .clamp(0.0, 1.0)
              .toDouble();

    if ((nextProgress - _scrollProgress).abs() < 0.002) {
      return;
    }

    setState(() {
      _scrollProgress = nextProgress;
    });
  }

  Future<void> _scrollToSection(PortfolioSection section) async {
    final targetContext = _sectionKeys[section]?.currentContext;
    if (targetContext == null) {
      return;
    }

    await Scrollable.ensureVisible(
      targetContext,
      alignment: 0.02,
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeInOutCubicEmphasized,
    );
  }

  void _activateSection(PortfolioSection section) {
    context.read<PortfolioBloc>().add(PortfolioSectionActivated(section));
  }

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    late final bool launched;

    try {
      launched = await launchUrl(
        uri,
        webOnlyWindowName: uri.scheme.startsWith('http') ? '_blank' : null,
      );
    } on Exception {
      launched = false;
    }

    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Unable to open ${uri.toString()}'),
        ),
      );
    }
  }

  Future<void> _openResume() async {
    await _launch(
      Uri.base.resolve('resume/Aniket_Parihar_Resume.pdf').toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final horizontalPadding = Breakpoints.horizontalPadding(width);
        final compactHeader = width < 1180;

        return BlocConsumer<PortfolioBloc, PortfolioState>(
          listenWhen: (previous, current) =>
              previous.scrollRequestId != current.scrollRequestId,
          listener: (context, state) =>
              _scrollToSection(state.requestedSection),
          builder: (context, state) {
            return Scaffold(
              body: Stack(
                children: [
                  const Positioned.fill(child: _BackgroundGlow()),
                  SafeArea(
                    bottom: false,
                    child: SelectionArea(
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(
                              horizontalPadding,
                              18,
                              horizontalPadding,
                              12,
                            ),
                            child: _PortfolioHeader(
                              availableWidth: width - (horizontalPadding * 2),
                              activeSection: state.activeSection,
                              isMenuOpen: state.isMenuOpen,
                              isMobile: compactHeader,
                              onMenuToggle: () {
                                context.read<PortfolioBloc>().add(
                                  const PortfolioMenuToggled(),
                                );
                              },
                              onResumeTap: _openResume,
                              onSectionTap: (section) {
                                context.read<PortfolioBloc>().add(
                                  PortfolioSectionRequested(section),
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: horizontalPadding,
                            ),
                            child: _ScrollProgressBar(
                              progress: _scrollProgress,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: SingleChildScrollView(
                              controller: _scrollController,
                              physics: const BouncingScrollPhysics(),
                              child: Center(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 1320,
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(
                                      horizontalPadding,
                                      6,
                                      horizontalPadding,
                                      40,
                                    ),
                                    child: Column(
                                      children: [
                                        _ViewportAwareSection(
                                          sectionKey:
                                              _sectionKeys[PortfolioSection
                                                  .home]!,
                                          section: PortfolioSection.home,
                                          onVisible: _activateSection,
                                          child: _HomePanel(
                                            onProjectsTap: () {
                                              context.read<PortfolioBloc>().add(
                                                const PortfolioSectionRequested(
                                                  PortfolioSection.work,
                                                ),
                                              );
                                            },
                                            onContactTap: () {
                                              context.read<PortfolioBloc>().add(
                                                const PortfolioSectionRequested(
                                                  PortfolioSection.contact,
                                                ),
                                              );
                                            },
                                            onResumeTap: _openResume,
                                            onLaunch: _launch,
                                          ),
                                        ),
                                        _ViewportAwareSection(
                                          sectionKey:
                                              _sectionKeys[PortfolioSection
                                                  .about]!,
                                          section: PortfolioSection.about,
                                          onVisible: _activateSection,
                                          child: const _AboutPanel(),
                                        ),
                                        _ViewportAwareSection(
                                          sectionKey:
                                              _sectionKeys[PortfolioSection
                                                  .work]!,
                                          section: PortfolioSection.work,
                                          onVisible: _activateSection,
                                          child: _ProjectsPanel(
                                            hoveredProjectId:
                                                state.hoveredProjectId,
                                          ),
                                        ),
                                        _ViewportAwareSection(
                                          sectionKey:
                                              _sectionKeys[PortfolioSection
                                                  .experience]!,
                                          section: PortfolioSection.experience,
                                          onVisible: _activateSection,
                                          child: _ExperiencePanel(
                                            onLaunch: _launch,
                                          ),
                                        ),
                                        _ViewportAwareSection(
                                          sectionKey:
                                              _sectionKeys[PortfolioSection
                                                  .skills]!,
                                          section: PortfolioSection.skills,
                                          onVisible: _activateSection,
                                          child: const _SkillsPanel(),
                                        ),
                                        _ViewportAwareSection(
                                          sectionKey:
                                              _sectionKeys[PortfolioSection
                                                  .contact]!,
                                          section: PortfolioSection.contact,
                                          onVisible: _activateSection,
                                          child: _ContactPanel(
                                            onLaunch: _launch,
                                            onResumeTap: _openResume,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _BackgroundGlow extends StatelessWidget {
  const _BackgroundGlow();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppPalette.canvas,
            Colors.white,
            AppPalette.canvas.withValues(alpha: 0.96),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: -160,
            top: 80,
            child: _BlurCircle(
              size: 360,
              colors: const [AppPalette.sky, AppPalette.cobalt],
            ),
          ),
          Positioned(
            right: -90,
            top: 420,
            child: _BlurCircle(
              size: 260,
              colors: const [AppPalette.coral, AppPalette.magenta],
            ),
          ),
          Positioned(
            left: 200,
            bottom: -90,
            child: _BlurCircle(
              size: 300,
              colors: const [AppPalette.amber, AppPalette.coral],
            ),
          ),
        ],
      ),
    );
  }
}

class _BlurCircle extends StatelessWidget {
  const _BlurCircle({required this.size, required this.colors});

  final double size;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: colors
                .map((color) => color.withValues(alpha: 0.48))
                .toList(),
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.first.withValues(alpha: 0.18),
              blurRadius: 100,
              spreadRadius: 30,
            ),
          ],
        ),
      ),
    );
  }
}

class _PortfolioHeader extends StatelessWidget {
  const _PortfolioHeader({
    required this.availableWidth,
    required this.activeSection,
    required this.isMenuOpen,
    required this.isMobile,
    required this.onMenuToggle,
    required this.onResumeTap,
    required this.onSectionTap,
  });

  final double availableWidth;
  final PortfolioSection activeSection;
  final bool isMenuOpen;
  final bool isMobile;
  final VoidCallback onMenuToggle;
  final VoidCallback onResumeTap;
  final ValueChanged<PortfolioSection> onSectionTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final compactBrand = availableWidth < 430;
    final navItems = PortfolioSection.values
        .map(
          (section) => _HeaderNavButton(
            section: section,
            isActive: activeSection == section,
            onTap: () => onSectionTap(section),
          ),
        )
        .toList();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      padding: EdgeInsets.all(isMobile ? 14 : 18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppPalette.line),
        boxShadow: [
          BoxShadow(
            color: AppPalette.ink.withValues(alpha: 0.06),
            blurRadius: 32,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Flexible(child: _BrandLockup(compact: compactBrand)),
              const Spacer(),
              if (!isMobile) ...[
                Wrap(spacing: 6, children: navItems),
                const SizedBox(width: 14),
                FilledButton.icon(
                  onPressed: onResumeTap,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppPalette.ink,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  icon: const Icon(Icons.download_rounded, size: 18),
                  label: const Text('Resume'),
                ),
              ] else
                IconButton(
                  onPressed: onMenuToggle,
                  style: IconButton.styleFrom(
                    backgroundColor: AppPalette.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: Icon(
                    isMenuOpen ? Icons.close_rounded : Icons.menu_rounded,
                    color: AppPalette.ink,
                  ),
                ),
            ],
          ),
          if (isMobile && isMenuOpen) ...[
            const SizedBox(height: 16),
            Column(
              children: [
                for (final item in navItems) ...[
                  SizedBox(width: double.infinity, child: item),
                  const SizedBox(height: 8),
                ],
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: onResumeTap,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppPalette.ink,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    icon: const Icon(Icons.download_rounded, size: 18),
                    label: Text(
                      'Download Resume',
                      style: theme.textTheme.labelLarge,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ScrollProgressBar extends StatelessWidget {
  const _ScrollProgressBar({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: Container(
        height: 6,
        color: AppPalette.line,
        child: Align(
          alignment: Alignment.centerLeft,
          child: AnimatedFractionallySizedBox(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            widthFactor: progress == 0 ? 0.02 : progress,
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppPalette.accentGradient,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandLockup extends StatelessWidget {
  const _BrandLockup({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final content = PortfolioScope.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: AppPalette.accentGradient,
            borderRadius: BorderRadius.circular(18),
          ),
          alignment: Alignment.center,
          child: Text(
            'AP',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        if (!compact) ...[
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  content.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'Flutter • BLoC • GIS',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppPalette.ink.withValues(alpha: 0.62),
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _HeaderNavButton extends StatelessWidget {
  const _HeaderNavButton({
    required this.section,
    required this.isActive,
    required this.onTap,
  });

  final PortfolioSection section;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: isActive ? Colors.white : AppPalette.ink,
        backgroundColor: isActive ? AppPalette.cobalt : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isActive ? AppPalette.cobalt : AppPalette.line,
          ),
        ),
      ),
      child: Text(section.label),
    );
  }
}

class _ViewportAwareSection extends StatelessWidget {
  const _ViewportAwareSection({
    required this.sectionKey,
    required this.section,
    required this.onVisible,
    required this.child,
  });

  final GlobalKey sectionKey;
  final PortfolioSection section;
  final ValueChanged<PortfolioSection> onVisible;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 26),
      child: VisibilityDetector(
        key: Key('viewport-${section.anchor}'),
        onVisibilityChanged: (info) {
          if (info.visibleFraction > 0.26) {
            onVisible(section);
          }
        },
        child: Container(key: sectionKey, child: child),
      ),
    );
  }
}

class _HomePanel extends StatelessWidget {
  const _HomePanel({
    required this.onProjectsTap,
    required this.onContactTap,
    required this.onResumeTap,
    required this.onLaunch,
  });

  final VoidCallback onProjectsTap;
  final VoidCallback onContactTap;
  final VoidCallback onResumeTap;
  final ValueChanged<String> onLaunch;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 1160;

        return Container(
          padding: EdgeInsets.all(stacked ? 16 : 22),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: AppPalette.line),
            boxShadow: [
              BoxShadow(
                color: AppPalette.ink.withValues(alpha: 0.05),
                blurRadius: 40,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: stacked
              ? Column(
                  children: [
                    RevealOnScroll(
                      child: _HeroCanvas(
                        onProjectsTap: onProjectsTap,
                        onContactTap: onContactTap,
                        onResumeTap: onResumeTap,
                      ),
                    ),
                    const SizedBox(height: 18),
                    RevealOnScroll(
                      delay: const Duration(milliseconds: 120),
                      child: _SidebarRail(onLaunch: onLaunch, dense: true),
                    ),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: RevealOnScroll(
                        child: _SidebarRail(onLaunch: onLaunch),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 9,
                      child: RevealOnScroll(
                        delay: const Duration(milliseconds: 120),
                        child: _HeroCanvas(
                          onProjectsTap: onProjectsTap,
                          onContactTap: onContactTap,
                          onResumeTap: onResumeTap,
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _SidebarRail extends StatelessWidget {
  const _SidebarRail({required this.onLaunch, this.dense = false});

  final ValueChanged<String> onLaunch;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final content = PortfolioScope.of(context);

    return Container(
      padding: EdgeInsets.all(dense ? 18 : 22),
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Portfolio / 2026',
            style: theme.textTheme.labelLarge?.copyWith(
              color: AppPalette.cobalt,
            ),
          ),
          const SizedBox(height: 12),
          Text(content.name, style: theme.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            content.title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppPalette.ink.withValues(alpha: 0.72),
            ),
          ),
          const SizedBox(height: 8),
          Text(content.location, style: theme.textTheme.bodyMedium),
          SizedBox(height: dense ? 16 : 22),
          if (dense)
            LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 720;
                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    SizedBox(
                      width: compact
                          ? constraints.maxWidth
                          : (constraints.maxWidth - 16) / 2,
                      child: const _InfoStrip(
                        title: 'Professional focus',
                        body:
                            'Scalable Flutter interfaces, location-driven systems, strong API integration and polished interaction design.',
                      ),
                    ),
                    SizedBox(
                      width: compact
                          ? constraints.maxWidth
                          : (constraints.maxWidth - 16) / 2,
                      child: _InfoStrip(
                        title: 'Academic foundation',
                        body:
                            '${content.educationTitle} • ${content.educationResult}',
                      ),
                    ),
                  ],
                );
              },
            )
          else ...[
            _InfoStrip(
              title: 'Professional focus',
              body:
                  'Scalable Flutter interfaces, location-driven systems, strong API integration and polished interaction design.',
            ),
            const SizedBox(height: 16),
            _InfoStrip(
              title: 'Academic foundation',
              body: '${content.educationTitle} • ${content.educationResult}',
            ),
          ],
          SizedBox(height: dense ? 18 : 22),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _MiniActionChip(
                label: 'LinkedIn',
                icon: Icons.work_outline_rounded,
                onTap: () => onLaunch(content.linkedIn),
              ),
              _MiniActionChip(
                label: 'GitHub',
                icon: Icons.code_rounded,
                onTap: () => onLaunch(content.github),
              ),
              _MiniActionChip(
                label: 'CodeChef',
                icon: Icons.emoji_events_outlined,
                onTap: () => onLaunch(content.codeChef),
              ),
            ],
          ),
          SizedBox(height: dense ? 20 : 26),
          if (!dense)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppPalette.line),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Highlights', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 14),
                  for (final item in content.achievements)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.value,
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: AppPalette.cobalt,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item.label,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _InfoStrip extends StatelessWidget {
  const _InfoStrip({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.labelLarge?.copyWith(
            color: AppPalette.ink.withValues(alpha: 0.56),
          ),
        ),
        const SizedBox(height: 6),
        Text(body, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}

class _MiniActionChip extends StatelessWidget {
  const _MiniActionChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppPalette.line),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppPalette.ink),
            const SizedBox(width: 8),
            Text(label),
          ],
        ),
      ),
    );
  }
}

class _HeroCanvas extends StatelessWidget {
  const _HeroCanvas({
    required this.onProjectsTap,
    required this.onContactTap,
    required this.onResumeTap,
  });

  final VoidCallback onProjectsTap;
  final VoidCallback onContactTap;
  final VoidCallback onResumeTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 760;

        return Container(
          padding: EdgeInsets.all(stacked ? 20 : 30),
          decoration: BoxDecoration(
            gradient: AppPalette.heroGradient,
            borderRadius: BorderRadius.circular(34),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: -60,
                bottom: -90,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
              ),
              Positioned(
                right: stacked ? -18 : 8,
                top: stacked ? -24 : -34,
                child: const _OrbitalShape(),
              ),
              if (stacked)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HeroCopyBlock(
                      onProjectsTap: onProjectsTap,
                      onContactTap: onContactTap,
                      onResumeTap: onResumeTap,
                    ),
                    const SizedBox(height: 24),
                    const Center(child: _HeroVisualPanel()),
                  ],
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 7,
                      child: _HeroCopyBlock(
                        onProjectsTap: onProjectsTap,
                        onContactTap: onContactTap,
                        onResumeTap: onResumeTap,
                      ),
                    ),
                    const SizedBox(width: 24),
                    const Expanded(
                      flex: 5,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: _HeroVisualPanel(),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

class _HeroCopyBlock extends StatelessWidget {
  const _HeroCopyBlock({
    required this.onProjectsTap,
    required this.onContactTap,
    required this.onResumeTap,
  });

  final VoidCallback onProjectsTap;
  final VoidCallback onContactTap;
  final VoidCallback onResumeTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final content = PortfolioScope.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _GlassPill(
              icon: Icons.circle,
              text: 'Production Flutter',
              iconColor: AppPalette.amber,
            ),
            _GlassPill(
              icon: Icons.location_on_rounded,
              text: 'Maps & GIS',
              iconColor: AppPalette.sky,
            ),
          ],
        ),
        const SizedBox(height: 28),
        LayoutBuilder(
          builder: (context, constraints) {
            final compactHeadline = constraints.maxWidth < 480;
            return Text(
              content.headline,
              style:
                  (compactHeadline
                          ? theme.textTheme.headlineLarge
                          : theme.textTheme.displaySmall)
                      ?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        height: 1.04,
                        letterSpacing: compactHeadline ? -1.0 : -1.8,
                      ),
            );
          },
        ),
        const SizedBox(height: 18),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Text(
            content.summary,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.82),
            ),
          ),
        ),
        const SizedBox(height: 26),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            FilledButton.icon(
              onPressed: onProjectsTap,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppPalette.ink,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 18,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              icon: const Icon(Icons.north_east_rounded),
              label: const Text('View Projects'),
            ),
            OutlinedButton.icon(
              onPressed: onResumeTap,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(color: Colors.white.withValues(alpha: 0.22)),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 18,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              icon: const Icon(Icons.download_rounded),
              label: const Text('Download Resume'),
            ),
            TextButton.icon(
              onPressed: onContactTap,
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 16,
                ),
              ),
              icon: const Icon(Icons.mail_outline_rounded),
              label: const Text('Let\'s connect'),
            ),
          ],
        ),
        const SizedBox(height: 30),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: content.heroTags
              .map((tag) => _TagChip(label: tag))
              .toList(),
        ),
        const SizedBox(height: 32),
        LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 600;
            return Wrap(
              spacing: 14,
              runSpacing: 14,
              children: [
                for (final stat in content.stats)
                  SizedBox(
                    width: compact ? constraints.maxWidth : 210,
                    child: _HeroStatCard(stat: stat),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _HeroVisualPanel extends StatefulWidget {
  const _HeroVisualPanel();

  @override
  State<_HeroVisualPanel> createState() => _HeroVisualPanelState();
}

class _HeroVisualPanelState extends State<_HeroVisualPanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setHovered(bool value) {
    if (_isHovered == value || !mounted) {
      return;
    }

    setState(() {
      _isHovered = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final content = PortfolioScope.of(context);

    return MouseRegion(
      onEnter: (_) => _setHovered(true),
      onExit: (_) => _setHovered(false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()..translate(0.0, _isHovered ? -10.0 : 0.0),
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: _isHovered ? 0.14 : 0.1),
          borderRadius: BorderRadius.circular(34),
          border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
          boxShadow: [
            BoxShadow(
              color: AppPalette.ink.withValues(alpha: _isHovered ? 0.24 : 0.16),
              blurRadius: _isHovered ? 34 : 24,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: const [
                _HeroSurfaceChip(
                  icon: Icons.verified_rounded,
                  label: 'Open to impactful Flutter roles',
                ),
                _HeroSurfaceChip(
                  icon: Icons.auto_graph_rounded,
                  label: 'BLoC + GIS',
                  compact: true,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: 6,
                    top: 34,
                    child: Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppPalette.sky.withValues(alpha: 0.28),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 14,
                    bottom: 120,
                    child: Container(
                      width: 62,
                      height: 62,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppPalette.coral.withValues(alpha: 0.26),
                      ),
                    ),
                  ),
                  Positioned(
                    top: -28,
                    right: -14,
                    child: IgnorePointer(
                      child: Opacity(
                        opacity: 0.52,
                        child: Transform.scale(
                          scale: 0.62,
                          child: const _OrbitalShape(),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedBuilder(
                          animation: _controller,
                          builder: (context, child) {
                            final hoverOffset = _isHovered ? -4.0 : 0.0;
                            final floatOffset =
                                math.sin(_controller.value * math.pi * 2) * 8;

                            return Transform.translate(
                              offset: Offset(0, hoverOffset + floatOffset),
                              child: child,
                            );
                          },
                          child: const _HeroImageFrame(),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: AppPalette.line),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                content.name,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                content.title,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(color: AppPalette.cobalt),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'UI polish, structured state management and location-focused product delivery.',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: AppPalette.ink.withValues(
                                        alpha: 0.72,
                                      ),
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Positioned(
                    left: -6,
                    top: 12,
                    child: _HeroMetricPill(value: '08+', label: 'Apps shipped'),
                  ),
                  const Positioned(
                    right: -6,
                    bottom: 106,
                    child: _HeroMetricPill(
                      value: '85%',
                      label: 'Hands-on ownership',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final tileWidth = constraints.maxWidth < 360
                    ? constraints.maxWidth
                    : (constraints.maxWidth - 12) / 2;

                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    SizedBox(
                      width: tileWidth,
                      child: const _HeroDetailTile(
                        icon: Icons.work_outline_rounded,
                        title: 'Current role',
                        subtitle: 'Mobile Application Developer',
                      ),
                    ),
                    SizedBox(
                      width: tileWidth,
                      child: const _HeroDetailTile(
                        icon: Icons.location_on_outlined,
                        title: 'Base',
                        subtitle: 'Raipur, India',
                      ),
                    ),
                    SizedBox(
                      width: constraints.maxWidth,
                      child: const _HeroDetailTile(
                        icon: Icons.route_rounded,
                        title: 'Core strengths',
                        subtitle:
                            'Flutter architecture, Google Maps, GIS, geofencing and robust product UX.',
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroImageFrame extends StatelessWidget {
  const _HeroImageFrame();

  @override
  Widget build(BuildContext context) {
    final content = PortfolioScope.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            AppPalette.sky.withValues(alpha: 0.7),
            AppPalette.coral.withValues(alpha: 0.52),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppPalette.ink.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: AspectRatio(
        aspectRatio: 0.78,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppPalette.sky.withValues(alpha: 0.44),
                      Colors.white,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              _PortfolioProfileImage(source: content.profileAsset),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 92,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        AppPalette.ink.withValues(alpha: 0.22),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileFallback extends StatelessWidget {
  const _ProfileFallback();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 96,
        height: 96,
        decoration: BoxDecoration(
          gradient: AppPalette.accentGradient,
          borderRadius: BorderRadius.circular(32),
        ),
        alignment: Alignment.center,
        child: Text(
          'AP',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _PortfolioProfileImage extends StatelessWidget {
  const _PortfolioProfileImage({required this.source});

  final String source;

  @override
  Widget build(BuildContext context) {
    final isRemote = source.startsWith('http') || source.startsWith('data:');
    final image = isRemote
        ? Image.network(
            source,
            fit: BoxFit.contain,
            alignment: Alignment.bottomCenter,
            filterQuality: FilterQuality.high,
            errorBuilder: (context, error, stackTrace) {
              return const _ProfileFallback();
            },
          )
        : Image.asset(
            source,
            fit: BoxFit.contain,
            alignment: Alignment.bottomCenter,
            filterQuality: FilterQuality.high,
            errorBuilder: (context, error, stackTrace) {
              return const _ProfileFallback();
            },
          );

    return image;
  }
}

class _HeroSurfaceChip extends StatelessWidget {
  const _HeroSurfaceChip({
    required this.icon,
    required this.label,
    this.compact = false,
  });

  final IconData icon;
  final String label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 12 : 14,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroMetricPill extends StatelessWidget {
  const _HeroMetricPill({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppPalette.line),
        boxShadow: [
          BoxShadow(
            color: AppPalette.ink.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              color: AppPalette.cobalt,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppPalette.ink.withValues(alpha: 0.66),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroDetailTile extends StatelessWidget {
  const _HeroDetailTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.72),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrbitalShape extends StatefulWidget {
  const _OrbitalShape();

  @override
  State<_OrbitalShape> createState() => _OrbitalShapeState();
}

class _OrbitalShapeState extends State<_OrbitalShape>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 220,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.rotate(
            angle: _controller.value * math.pi * 2,
            child: child,
          );
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 188,
              height: 188,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(70),
                border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
              ),
            ),
            Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                gradient: AppPalette.highlightGradient,
                borderRadius: BorderRadius.circular(44),
              ),
            ),
            Positioned(
              top: 18,
              right: 24,
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppPalette.amber,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassPill extends StatelessWidget {
  const _GlassPill({
    required this.icon,
    required this.text,
    required this.iconColor,
  });

  final IconData icon;
  final String text;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 8),
          Text(
            text,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Colors.white.withValues(alpha: 0.86),
        ),
      ),
    );
  }
}

class _HeroStatCard extends StatelessWidget {
  const _HeroStatCard({required this.stat});

  final PortfolioStat stat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            stat.value,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            stat.label,
            style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            stat.detail,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.72),
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutPanel extends StatelessWidget {
  const _AboutPanel();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 960;

        return Container(
          padding: EdgeInsets.all(stacked ? 20 : 30),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: AppPalette.line),
          ),
          child: stacked
              ? Column(
                  children: [
                    const RevealOnScroll(child: _AboutContent()),
                    const SizedBox(height: 24),
                    RevealOnScroll(
                      delay: const Duration(milliseconds: 100),
                      child: const _RibbonArtwork(),
                    ),
                  ],
                )
              : Row(
                  children: [
                    const Expanded(
                      flex: 6,
                      child: RevealOnScroll(child: _AboutContent()),
                    ),
                    const SizedBox(width: 22),
                    Expanded(
                      flex: 5,
                      child: RevealOnScroll(
                        delay: const Duration(milliseconds: 100),
                        child: const _RibbonArtwork(),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _AboutContent extends StatelessWidget {
  const _AboutContent();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final content = PortfolioScope.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionIntro(
          eyebrow: 'About me',
          title:
              'Building useful interfaces for teams, field operations and real users.',
          description:
              'My work sits at the intersection of UI quality, product delivery and operational clarity. I enjoy turning complex requirements into responsive Flutter experiences that feel trustworthy and easy to use.',
        ),
        const SizedBox(height: 22),
        Text(
          'Recent work has focused on maps, GIS-backed products, geofenced attendance systems, role-based access and dashboards where data needs to stay reliable in motion. I have contributed across architecture, implementation and production readiness while maintaining a strong focus on UX polish.',
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: 26),
        LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 580;
            return Wrap(
              spacing: 14,
              runSpacing: 14,
              children: [
                for (int index = 0; index < content.focusAreas.length; index++)
                  SizedBox(
                    width: compact ? constraints.maxWidth : 250,
                    child: RevealOnScroll(
                      delay: Duration(milliseconds: 80 * (index + 1)),
                      child: _FocusCard(area: content.focusAreas[index]),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _RibbonArtwork extends StatelessWidget {
  const _RibbonArtwork();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.08,
      child: Container(
        decoration: BoxDecoration(
          color: AppPalette.surface,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: 34,
              left: 32,
              child: Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppPalette.sky.withValues(alpha: 0.46),
                ),
              ),
            ),
            Positioned(
              right: 36,
              bottom: 44,
              child: Container(
                width: 104,
                height: 104,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppPalette.coral.withValues(alpha: 0.32),
                ),
              ),
            ),
            Transform.rotate(
              angle: -0.42,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  gradient: AppPalette.accentGradient,
                  borderRadius: BorderRadius.circular(54),
                ),
              ),
            ),
            Transform.rotate(
              angle: 0.48,
              child: Container(
                width: 180,
                height: 78,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.88),
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
            ),
            Positioned(
              bottom: 26,
              left: 24,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppPalette.line),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      color: AppPalette.cobalt,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Text('Motion-led UI'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FocusCard extends StatelessWidget {
  const _FocusCard({required this.area});

  final FocusArea area;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppPalette.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: AppPalette.highlightGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Icon(area.icon, color: Colors.white),
          ),
          const SizedBox(height: 14),
          Text(area.title, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(area.description, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _ProjectsPanel extends StatelessWidget {
  const _ProjectsPanel({required this.hoveredProjectId});

  final String? hoveredProjectId;

  @override
  Widget build(BuildContext context) {
    final content = PortfolioScope.of(context);

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppPalette.ink,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const RevealOnScroll(
            child: _SectionIntro(
              eyebrow: 'Selected work',
              title:
                  'Production projects shaped by maps, dashboards and complex workflows.',
              description:
                  'These projects reflect the mix of UI ownership, API integration and operational thinking that runs through my Flutter work.',
              light: true,
            ),
          ),
          const SizedBox(height: 26),
          LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = constraints.maxWidth < 760
                  ? constraints.maxWidth
                  : (constraints.maxWidth - 16) / 2;

              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  for (int index = 0; index < content.projects.length; index++)
                    SizedBox(
                      width: cardWidth,
                      child: RevealOnScroll(
                        delay: Duration(milliseconds: 70 * (index + 1)),
                        child: _ProjectCard(
                          project: content.projects[index],
                          isHovered:
                              hoveredProjectId == content.projects[index].id,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({required this.project, required this.isHovered});

  final ProjectItem project;
  final bool isHovered;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bloc = context.read<PortfolioBloc>();

    return MouseRegion(
      onEnter: (_) => bloc.add(PortfolioProjectHovered(project.id)),
      onExit: (_) => bloc.add(const PortfolioProjectHovered(null)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        transform: Matrix4.identity()..translate(0.0, isHovered ? -10.0 : 0.0),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: AppPalette.cobalt.withValues(
                alpha: isHovered ? 0.22 : 0.08,
              ),
              blurRadius: isHovered ? 28 : 18,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: AppPalette.accentGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                project.category,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(project.title, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              project.timeline,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppPalette.cobalt,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            Text(project.description, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppPalette.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                project.contribution,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppPalette.ink.withValues(alpha: 0.82),
                ),
              ),
            ),
            const SizedBox(height: 18),
            for (final highlight in project.highlights)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Icon(
                        Icons.circle,
                        size: 8,
                        color: AppPalette.coral,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(highlight, style: theme.textTheme.bodyMedium),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: project.stack
                  .map(
                    (tech) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppPalette.line),
                      ),
                      child: Text(tech),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExperiencePanel extends StatelessWidget {
  const _ExperiencePanel({required this.onLaunch});

  final ValueChanged<String> onLaunch;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: AppPalette.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const RevealOnScroll(
            child: _SectionIntro(
              eyebrow: 'Experience',
              title:
                  'Shipping across multi-product teams while staying close to implementation detail.',
              description:
                  'My recent roles have involved meaningful ownership across product surfaces, data-connected user journeys and reusable Flutter systems.',
            ),
          ),
          const SizedBox(height: 28),
          LayoutBuilder(
            builder: (context, constraints) {
              final stacked = constraints.maxWidth < 980;

              return stacked
                  ? Column(
                      children: [
                        RevealOnScroll(
                          child: _ExperienceTimeline(onLaunch: onLaunch),
                        ),
                        const SizedBox(height: 22),
                        const RevealOnScroll(
                          delay: Duration(milliseconds: 120),
                          child: _EducationCard(),
                        ),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 8,
                          child: RevealOnScroll(
                            child: _ExperienceTimeline(onLaunch: onLaunch),
                          ),
                        ),
                        const SizedBox(width: 20),
                        const Expanded(
                          flex: 4,
                          child: RevealOnScroll(
                            delay: Duration(milliseconds: 120),
                            child: _EducationCard(),
                          ),
                        ),
                      ],
                    );
            },
          ),
        ],
      ),
    );
  }
}

class _ExperienceTimeline extends StatelessWidget {
  const _ExperienceTimeline({required this.onLaunch});

  final ValueChanged<String> onLaunch;

  @override
  Widget build(BuildContext context) {
    final content = PortfolioScope.of(context);

    return Column(
      children: [
        for (int index = 0; index < content.experience.length; index++)
          Padding(
            padding: EdgeInsets.only(
              bottom: index == content.experience.length - 1 ? 0 : 18,
            ),
            child: _ExperienceCard(
              item: content.experience[index],
              isLast: index == content.experience.length - 1,
              onLaunch: onLaunch,
            ),
          ),
      ],
    );
  }
}

class _ExperienceCard extends StatelessWidget {
  const _ExperienceCard({
    required this.item,
    required this.isLast,
    required this.onLaunch,
  });

  final ExperienceItem item;
  final bool isLast;
  final ValueChanged<String> onLaunch;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 28,
          child: Column(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: const BoxDecoration(
                  color: AppPalette.cobalt,
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 180,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  color: AppPalette.line,
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppPalette.surface,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: AppPalette.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(item.role, style: theme.textTheme.titleLarge),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(item.period),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${item.company} • ${item.location}',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppPalette.cobalt,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                Text(item.summary, style: theme.textTheme.bodyLarge),
                const SizedBox(height: 18),
                for (final highlight in item.highlights)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 6),
                          child: Icon(
                            Icons.circle,
                            size: 8,
                            color: AppPalette.success,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            highlight,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (item.url != null) ...[
                  const SizedBox(height: 10),
                  TextButton.icon(
                    onPressed: () => onLaunch(item.url!),
                    style: TextButton.styleFrom(
                      foregroundColor: AppPalette.ink,
                      padding: EdgeInsets.zero,
                    ),
                    icon: const Icon(Icons.north_east_rounded),
                    label: Text('Visit ${item.company}'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _EducationCard extends StatelessWidget {
  const _EducationCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final content = PortfolioScope.of(context);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppPalette.cobalt, AppPalette.violet],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Education',
            style: theme.textTheme.labelLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.82),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content.educationTitle,
            style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 10),
          Text(
            content.educationSchool,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.82),
            ),
          ),
          const SizedBox(height: 16),
          _MetricRow(
            label: 'Period',
            value: content.educationPeriod,
            light: true,
          ),
          const SizedBox(height: 12),
          _MetricRow(
            label: 'Result',
            value: content.educationResult,
            light: true,
          ),
          const SizedBox(height: 26),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Ranked 4th overall in the CSE branch till the 8th semester and built strong fundamentals in programming, networks, operating systems and databases.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SkillsPanel extends StatelessWidget {
  const _SkillsPanel();

  @override
  Widget build(BuildContext context) {
    final content = PortfolioScope.of(context);

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: AppPalette.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const RevealOnScroll(
            child: _SectionIntro(
              eyebrow: 'Toolkit',
              title: 'The technologies and habits behind the work.',
              description:
                  'I lean toward pragmatic tooling, maintainable state and interfaces that can grow without becoming fragile.',
            ),
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 760;
              final skillCardWidth = compact
                  ? constraints.maxWidth
                  : (constraints.maxWidth - 16) / 2;

              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  for (
                    int index = 0;
                    index < content.skillCategories.length;
                    index++
                  )
                    SizedBox(
                      width: skillCardWidth,
                      child: RevealOnScroll(
                        delay: Duration(milliseconds: 90 * (index + 1)),
                        child: _SkillCard(
                          category: content.skillCategories[index],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 22),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              for (final achievement in content.achievements)
                SizedBox(
                  width: 250,
                  child: RevealOnScroll(
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppPalette.surface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppPalette.line),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            achievement.value,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  color: AppPalette.cobalt,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(achievement.label),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SkillCard extends StatelessWidget {
  const _SkillCard({required this.category});

  final SkillCategory category;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppPalette.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(category.title, style: theme.textTheme.titleLarge),
          const SizedBox(height: 10),
          Text(category.summary, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: category.items
                .map(
                  (item) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(item),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _ContactPanel extends StatelessWidget {
  const _ContactPanel({required this.onLaunch, required this.onResumeTap});

  final ValueChanged<String> onLaunch;
  final VoidCallback onResumeTap;

  @override
  Widget build(BuildContext context) {
    final content = PortfolioScope.of(context);

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: AppPalette.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RevealOnScroll(
            child: Container(
              padding: const EdgeInsets.all(26),
              decoration: BoxDecoration(
                gradient: AppPalette.accentGradient,
                borderRadius: BorderRadius.circular(32),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final stacked = constraints.maxWidth < 900;
                  return stacked
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _ContactLead(),
                            const SizedBox(height: 22),
                            _ContactActionsBar(
                              onLaunch: onLaunch,
                              onResumeTap: onResumeTap,
                            ),
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Expanded(flex: 6, child: _ContactLead()),
                            const SizedBox(width: 18),
                            Expanded(
                              flex: 4,
                              child: _ContactActionsBar(
                                onLaunch: onLaunch,
                                onResumeTap: onResumeTap,
                              ),
                            ),
                          ],
                        );
                },
              ),
            ),
          ),
          const SizedBox(height: 22),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 760;
              final tileWidth = compact
                  ? constraints.maxWidth
                  : (constraints.maxWidth - 32) / 3;

              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  for (
                    int index = 0;
                    index < content.contactActions.length;
                    index++
                  )
                    SizedBox(
                      width: tileWidth,
                      child: RevealOnScroll(
                        delay: Duration(milliseconds: 70 * (index + 1)),
                        child: _ContactTile(
                          action: content.contactActions[index],
                          onTap: () =>
                              onLaunch(content.contactActions[index].url),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          Text(
            'Built in Flutter Web with BLoC state management and responsive motion-led sections.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppPalette.ink.withValues(alpha: 0.56),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactLead extends StatelessWidget {
  const _ContactLead();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contact',
          style: theme.textTheme.labelLarge?.copyWith(
            color: Colors.white.withValues(alpha: 0.84),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Let\'s build thoughtful Flutter products with strong UX and reliable execution.',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: Colors.white,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'If you need a Flutter engineer comfortable with maps, live systems, production workflows and maintainable state management, I\'m easy to reach.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: Colors.white.withValues(alpha: 0.84),
          ),
        ),
      ],
    );
  }
}

class _ContactActionsBar extends StatelessWidget {
  const _ContactActionsBar({required this.onLaunch, required this.onResumeTap});

  final ValueChanged<String> onLaunch;
  final VoidCallback onResumeTap;

  @override
  Widget build(BuildContext context) {
    final content = PortfolioScope.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FilledButton.icon(
          onPressed: () => onLaunch('mailto:${content.email}'),
          style: FilledButton.styleFrom(
            backgroundColor: AppPalette.ink,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          icon: const Icon(Icons.mail_outline_rounded),
          label: const Text('Email Me'),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: onResumeTap,
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: BorderSide(color: Colors.white.withValues(alpha: 0.4)),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          icon: const Icon(Icons.download_rounded),
          label: const Text('Open Resume'),
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: () => Navigator.of(context).pushNamed('/contact-us'),
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          ),
          icon: const Icon(Icons.contact_mail_rounded),
          label: const Text('Open Contact Page'),
        ),
      ],
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({required this.action, required this.onTap});

  final ContactAction action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Ink(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppPalette.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppPalette.line),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: AppPalette.highlightGradient,
                borderRadius: BorderRadius.circular(18),
              ),
              alignment: Alignment.center,
              child: Icon(action.icon, color: Colors.white),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(action.title, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(action.subtitle, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
            const Icon(Icons.north_east_rounded, color: AppPalette.ink),
          ],
        ),
      ),
    );
  }
}

class _SectionIntro extends StatelessWidget {
  const _SectionIntro({
    required this.eyebrow,
    required this.title,
    required this.description,
    this.light = false,
  });

  final String eyebrow;
  final String title;
  final String description;
  final bool light;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headlineColor = light ? Colors.white : AppPalette.ink;
    final bodyColor = light
        ? Colors.white.withValues(alpha: 0.78)
        : AppPalette.ink.withValues(alpha: 0.72);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow.toUpperCase(),
          style: theme.textTheme.labelLarge?.copyWith(
            color: light ? AppPalette.sky : AppPalette.cobalt,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 12),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Text(
            title,
            style: theme.textTheme.headlineLarge?.copyWith(
              color: headlineColor,
              height: 1.08,
            ),
          ),
        ),
        const SizedBox(height: 12),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Text(
            description,
            style: theme.textTheme.bodyLarge?.copyWith(color: bodyColor),
          ),
        ),
      ],
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({
    required this.label,
    required this.value,
    this.light = false,
  });

  final String label;
  final String value;
  final bool light;

  @override
  Widget build(BuildContext context) {
    final color = light ? Colors.white : AppPalette.ink;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: color.withValues(alpha: 0.7)),
        ),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: color),
        ),
      ],
    );
  }
}
