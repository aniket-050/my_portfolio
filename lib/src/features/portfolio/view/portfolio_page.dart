import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../core/utils/breakpoints.dart';
import '../../../core/widgets/reveal_on_scroll.dart';
import '../bloc/portfolio_bloc.dart';
import '../data/portfolio_content.dart';
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
    _scrollController = ScrollController()..addListener(_handleScroll);
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
    if (!_scrollController.hasClients ||
        !_scrollController.position.hasContentDimensions ||
        !mounted) {
      return;
    }

    final maxScrollExtent = _scrollController.position.maxScrollExtent;
    final nextProgress = maxScrollExtent <= 0
        ? 0.0
        : (_scrollController.offset / maxScrollExtent)
              .clamp(0.0, 1.0)
              .toDouble();

    if ((nextProgress - _scrollProgress).abs() < 0.002) {
      return;
    }

    setState(() => _scrollProgress = nextProgress);
  }

  Future<void> _scrollToSection(PortfolioSection section) async {
    final targetContext = _sectionKeys[section]?.currentContext;
    if (targetContext == null) {
      return;
    }

    await Scrollable.ensureVisible(
      targetContext,
      alignment: 0,
      duration: const Duration(milliseconds: 850),
      curve: Curves.easeInOutCubic,
    );
  }

  void _requestSection(PortfolioSection section) {
    context.read<PortfolioBloc>().add(PortfolioSectionRequested(section));
  }

  void _activateSection(PortfolioSection section) {
    context.read<PortfolioBloc>().add(PortfolioSectionActivated(section));
  }

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    final launched = await launchUrl(
      uri,
      webOnlyWindowName: uri.scheme.startsWith('http') ? '_blank' : null,
    );

    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to open ${uri.toString()}')),
      );
    }
  }

  Future<void> _openResume() {
    return _launch(
      Uri.base.resolve('resume/Aniket_Parihar_Resume.pdf').toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PortfolioBloc, PortfolioState>(
      listenWhen: (previous, current) =>
          previous.scrollRequestId != current.scrollRequestId,
      listener: (context, state) => _scrollToSection(state.requestedSection),
      builder: (context, state) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final isDesktop = width >= 980;

            return Scaffold(
              backgroundColor: _ProPalette.stage,
              body: SafeArea(
                bottom: false,
                child: Stack(
                  children: [
                    if (isDesktop)
                      Row(
                        children: [
                          SizedBox(
                            width: 292,
                            child: _DesktopSidebar(
                              activeSection: state.activeSection,
                              onSectionTap: _requestSection,
                              onResumeTap: _openResume,
                              onLaunch: _launch,
                            ),
                          ),
                          Expanded(child: _scrollablePages(isDesktop: true)),
                        ],
                      )
                    else
                      _scrollablePages(
                        isDesktop: false,
                        header: _MobileHeader(
                          isMenuOpen: state.isMenuOpen,
                          onMenuTap: () => context.read<PortfolioBloc>().add(
                            const PortfolioMenuToggled(),
                          ),
                        ),
                      ),
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 0,
                      child: LinearProgressIndicator(
                        value: _scrollProgress,
                        minHeight: 3,
                        backgroundColor: Colors.transparent,
                        color: _ProPalette.orange,
                      ),
                    ),
                    if (!isDesktop && state.isMenuOpen)
                      _MobileMenu(
                        activeSection: state.activeSection,
                        onSectionTap: _requestSection,
                        onResumeTap: _openResume,
                        onLaunch: _launch,
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _scrollablePages({required bool isDesktop, Widget? header}) {
    return SingleChildScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          if (header != null) header,
          _TrackedSection(
            section: PortfolioSection.home,
            sectionKey: _sectionKeys[PortfolioSection.home]!,
            onVisible: _activateSection,
            child: _PageFrame(
              number: '01',
              label: 'Home',
              tint: _ProPalette.paper,
              showLabel: false,
              maxContentWidth: 1420,
              child: _HomeSection(
                onContactTap: () => _requestSection(PortfolioSection.contact),
                onResumeTap: _openResume,
                onLaunch: _launch,
              ),
            ),
          ),
          _TrackedSection(
            section: PortfolioSection.about,
            sectionKey: _sectionKeys[PortfolioSection.about]!,
            onVisible: _activateSection,
            child: _PageFrame(
              number: '02',
              label: 'About',
              tint: _ProPalette.paper,
              showLabel: false,
              maxContentWidth: 1208,
              edgeToEdgeDesktop: true,
              contentAlignment: Alignment.topLeft,
              child: _AboutSection(onResumeTap: _openResume),
            ),
          ),
          _TrackedSection(
            section: PortfolioSection.services,
            sectionKey: _sectionKeys[PortfolioSection.services]!,
            onVisible: _activateSection,
            child: const _PageFrame(
              number: '03',
              label: 'Services',
              tint: _ProPalette.paper,
              showLabel: false,
              maxContentWidth: 1208,
              edgeToEdgeDesktop: true,
              contentAlignment: Alignment.topLeft,
              child: _ServicesSection(),
            ),
          ),
          _TrackedSection(
            section: PortfolioSection.works,
            sectionKey: _sectionKeys[PortfolioSection.works]!,
            onVisible: _activateSection,
            child: const _PageFrame(
              number: '04',
              label: 'Works',
              tint: _ProPalette.paper,
              showLabel: false,
              maxContentWidth: 1208,
              edgeToEdgeDesktop: true,
              contentAlignment: Alignment.topLeft,
              child: _WorksSection(),
            ),
          ),
          _TrackedSection(
            section: PortfolioSection.blogs,
            sectionKey: _sectionKeys[PortfolioSection.blogs]!,
            onVisible: _activateSection,
            child: const _PageFrame(
              number: '05',
              label: 'Blog',
              tint: _ProPalette.canvas,
              child: _BlogSection(),
            ),
          ),
          _TrackedSection(
            section: PortfolioSection.contact,
            sectionKey: _sectionKeys[PortfolioSection.contact]!,
            onVisible: _activateSection,
            child: _PageFrame(
              number: '06',
              label: 'Contact',
              tint: _ProPalette.paper,
              child: _ContactSection(onLaunch: _launch),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrackedSection extends StatelessWidget {
  const _TrackedSection({
    required this.section,
    required this.sectionKey,
    required this.onVisible,
    required this.child,
  });

  final PortfolioSection section;
  final GlobalKey sectionKey;
  final ValueChanged<PortfolioSection> onVisible;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('section-${section.anchor}'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.34) {
          onVisible(section);
        }
      },
      child: Container(key: sectionKey, child: child),
    );
  }
}

class _DesktopSidebar extends StatelessWidget {
  const _DesktopSidebar({
    required this.activeSection,
    required this.onSectionTap,
    required this.onResumeTap,
    required this.onLaunch,
  });

  final PortfolioSection activeSection;
  final ValueChanged<PortfolioSection> onSectionTap;
  final VoidCallback onResumeTap;
  final ValueChanged<String> onLaunch;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      color: _ProPalette.ink,
      padding: const EdgeInsets.fromLTRB(30, 36, 30, 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _BrandBlock(),
          const SizedBox(height: 36),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                for (final section in PortfolioSection.values)
                  _NavButton(
                    section: section,
                    isActive: section == activeSection,
                    onTap: () => onSectionTap(section),
                  ),
                const SizedBox(height: 32),
                const Divider(color: Colors.white24),
                const SizedBox(height: 22),
                _SidebarInfo(
                  label: 'Location',
                  value: PortfolioContent.location,
                  icon: Icons.location_on_outlined,
                ),
                const SizedBox(height: 16),
                _SidebarInfo(
                  label: 'Email',
                  value: PortfolioContent.email,
                  icon: Icons.mail_outline,
                  onTap: () => onLaunch('mailto:${PortfolioContent.email}'),
                ),
              ],
            ),
          ),
          _GradientButton(label: 'Download CV', onTap: onResumeTap),
          const SizedBox(height: 20),
          Row(
            children: [
              _SocialIcon(
                icon: Icons.work_outline,
                onTap: () => onLaunch(PortfolioContent.linkedIn),
              ),
              const SizedBox(width: 10),
              _SocialIcon(
                icon: Icons.code,
                onTap: () => onLaunch(PortfolioContent.github),
              ),
              const SizedBox(width: 10),
              _SocialIcon(
                icon: Icons.emoji_events_outlined,
                onTap: () => onLaunch(PortfolioContent.codeChef),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Copyright 2026\nAniket Parihar',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.55),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandBlock extends StatelessWidget {
  const _BrandBlock();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                gradient: _ProPalette.hotGradient,
                shape: BoxShape.circle,
              ),
              child: Text(
                'A',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Aniket',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.4,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          'Flutter portfolio built around maps, motion and production delivery.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white.withValues(alpha: 0.66),
          ),
        ),
      ],
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.section,
    required this.isActive,
    required this.onTap,
  });

  final PortfolioSection section;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isActive ? Colors.white.withValues(alpha: 0.1) : null,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isActive
                ? Colors.white.withValues(alpha: 0.16)
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: isActive ? 26 : 8,
              height: 3,
              decoration: BoxDecoration(
                gradient: isActive ? _ProPalette.hotGradient : null,
                color: isActive ? null : Colors.white24,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(width: 14),
            Text(
              section.label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: isActive ? FontWeight.w900 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarInfo extends StatelessWidget {
  const _SidebarInfo({
    required this.label,
    required this.value,
    required this.icon,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white70, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.48),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.78),
                    height: 1.45,
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

class _MobileHeader extends StatelessWidget {
  const _MobileHeader({required this.isMenuOpen, required this.onMenuTap});

  final bool isMenuOpen;
  final VoidCallback onMenuTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _ProPalette.ink,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      child: Row(
        children: [
          const _MobileMark(),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              PortfolioContent.name,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          IconButton(
            onPressed: onMenuTap,
            color: Colors.white,
            icon: Icon(isMenuOpen ? Icons.close_rounded : Icons.menu_rounded),
          ),
        ],
      ),
    );
  }
}

class _MobileMark extends StatelessWidget {
  const _MobileMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        gradient: _ProPalette.hotGradient,
        shape: BoxShape.circle,
      ),
      child: const Text(
        'A',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
      ),
    );
  }
}

class _MobileMenu extends StatelessWidget {
  const _MobileMenu({
    required this.activeSection,
    required this.onSectionTap,
    required this.onResumeTap,
    required this.onLaunch,
  });

  final PortfolioSection activeSection;
  final ValueChanged<PortfolioSection> onSectionTap;
  final VoidCallback onResumeTap;
  final ValueChanged<String> onLaunch;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      top: 72,
      child: Material(
        color: _ProPalette.ink.withValues(alpha: 0.96),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 26, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final section in PortfolioSection.values)
                _MobileNavButton(
                  section: section,
                  isActive: section == activeSection,
                  onTap: () => onSectionTap(section),
                ),
              const Spacer(),
              _GradientButton(label: 'Download CV', onTap: onResumeTap),
              const SizedBox(height: 18),
              Wrap(
                spacing: 12,
                children: [
                  _SocialIcon(
                    icon: Icons.work_outline,
                    onTap: () => onLaunch(PortfolioContent.linkedIn),
                  ),
                  _SocialIcon(
                    icon: Icons.code,
                    onTap: () => onLaunch(PortfolioContent.github),
                  ),
                  _SocialIcon(
                    icon: Icons.emoji_events_outlined,
                    onTap: () => onLaunch(PortfolioContent.codeChef),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MobileNavButton extends StatelessWidget {
  const _MobileNavButton({
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
        foregroundColor: Colors.white,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(vertical: 13),
      ),
      child: Row(
        children: [
          Text(
            section.label.toUpperCase(),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (isActive) ...[
            const SizedBox(width: 12),
            Container(
              width: 34,
              height: 5,
              decoration: BoxDecoration(
                gradient: _ProPalette.hotGradient,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PageFrame extends StatelessWidget {
  const _PageFrame({
    required this.number,
    required this.label,
    required this.child,
    this.tint = _ProPalette.canvas,
    this.showLabel = true,
    this.maxContentWidth = 1180,
    this.edgeToEdgeDesktop = false,
    this.contentAlignment = Alignment.center,
  });

  final String number;
  final String label;
  final Color tint;
  final Widget child;
  final bool showLabel;
  final double maxContentWidth;
  final bool edgeToEdgeDesktop;
  final AlignmentGeometry contentAlignment;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final height = MediaQuery.sizeOf(context).height;
    final isMobile = Breakpoints.isMobile(width);
    final horizontalPadding = edgeToEdgeDesktop && !isMobile
        ? 0.0
        : Breakpoints.horizontalPadding(width);

    return Container(
      width: double.infinity,
      color: tint,
      constraints: BoxConstraints(minHeight: math.max(680, height - 24)),
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: isMobile ? 54 : 76,
      ),
      child: Align(
        alignment: contentAlignment,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxContentWidth),
          child: SizedBox(
            width: double.infinity,
            child: RevealOnScroll(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showLabel) ...[
                    _PageLabel(number: number, label: label),
                    SizedBox(height: isMobile ? 26 : 42),
                  ],
                  child,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PageLabel extends StatelessWidget {
  const _PageLabel({required this.number, required this.label});

  final String number;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          number,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: _ProPalette.orange,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(width: 12),
        Container(width: 44, height: 2, color: _ProPalette.ink),
        const SizedBox(width: 12),
        Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: _ProPalette.muted,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.6,
          ),
        ),
      ],
    );
  }
}

class _HomeSection extends StatelessWidget {
  const _HomeSection({
    required this.onContactTap,
    required this.onResumeTap,
    required this.onLaunch,
  });

  final VoidCallback onContactTap;
  final VoidCallback onResumeTap;
  final ValueChanged<String> onLaunch;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final sideBySide = constraints.maxWidth >= 620;
        final copy = _HeroCopy(
          onContactTap: onContactTap,
          onResumeTap: onResumeTap,
          onLaunch: onLaunch,
        );
        const showcase = _HomeVisual();

        if (!sideBySide) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              copy,
              const SizedBox(height: 52),
              const Center(child: showcase),
            ],
          );
        }

        final compactDesktop = constraints.maxWidth < 1040;
        final gap = compactDesktop ? 22.0 : 42.0;
        final copyWidth = (constraints.maxWidth * (compactDesktop ? 0.5 : 0.45))
            .clamp(320.0, 610.0);
        final visualWidth = math.max(
          260.0,
          constraints.maxWidth - copyWidth - gap,
        );

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: copyWidth,
              child: Padding(
                padding: EdgeInsets.only(top: compactDesktop ? 70 : 118),
                child: copy,
              ),
            ),
            SizedBox(width: gap),
            SizedBox(width: visualWidth, child: showcase),
          ],
        );
      },
    );
  }
}

class _HeroCopy extends StatelessWidget {
  const _HeroCopy({
    required this.onContactTap,
    required this.onResumeTap,
    required this.onLaunch,
  });

  final VoidCallback onContactTap;
  final VoidCallback onResumeTap;
  final ValueChanged<String> onLaunch;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final localWidth = constraints.maxWidth;
        final isNarrow = localWidth < 380;
        final heroSize = (localWidth * 0.142).clamp(38.0, 74.0);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: isNarrow ? 62 : 92,
                  top: isNarrow ? -16 : -24,
                  child: Transform.rotate(
                    angle: 0.52,
                    child: _TriangleMark(
                      width: isNarrow ? 54 : 62,
                      height: isNarrow ? 96 : 116,
                      colors: const [_ProPalette.orange, _ProPalette.red],
                    ),
                  ),
                ),
                Positioned(
                  left: isNarrow ? -20 : -48,
                  top: isNarrow ? 58 : 76,
                  child: Transform.rotate(
                    angle: -1.5,
                    child: _TriangleMark(
                      width: isNarrow ? 50 : 58,
                      height: isNarrow ? 132 : 160,
                      colors: const [_ProPalette.violet, _ProPalette.pink],
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MY NAME',
                      style: _heroLineStyle(context, heroSize).copyWith(
                        fontWeight: FontWeight.w500,
                        letterSpacing: -2.1,
                      ),
                    ),
                    Text(
                      'IS ANIKET',
                      style: _heroLineStyle(
                        context,
                        heroSize,
                      ).copyWith(fontWeight: FontWeight.w900),
                    ),
                    Text(
                      'PARIHAR...',
                      style: _heroLineStyle(
                        context,
                        heroSize,
                      ).copyWith(fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: PortfolioContent.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const TextSpan(text: ' based in '),
                  const TextSpan(
                    text: 'Raipur',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: _ProPalette.ink,
                fontSize: isNarrow ? 18 : null,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 40),
            Wrap(
              spacing: 18,
              runSpacing: 18,
              children: [
                _HomeButton(label: "Let's talk with me", onTap: onContactTap),
                if (isNarrow)
                  _SecondaryButton(label: 'Download CV', onTap: onResumeTap),
              ],
            ),
            const SizedBox(height: 58),
            Wrap(
              spacing: isNarrow ? 18 : 34,
              runSpacing: 16,
              children: [
                _HomeContactLink(
                  icon: Icons.link,
                  text: PortfolioContent.phone,
                  onTap: () => onLaunch('tel:+918770561223'),
                ),
                _HomeContactLink(
                  icon: Icons.mail_outline,
                  text: PortfolioContent.email,
                  onTap: () => onLaunch('mailto:${PortfolioContent.email}'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  TextStyle _heroLineStyle(BuildContext context, double size) {
    return Theme.of(context).textTheme.displayLarge!.copyWith(
      color: _ProPalette.ink,
      fontSize: size,
      height: 0.92,
      letterSpacing: -2.4,
    );
  }
}

class _HomeVisual extends StatefulWidget {
  const _HomeVisual();

  @override
  State<_HomeVisual> createState() => _HomeVisualState();
}

class _HomeVisualState extends State<_HomeVisual>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

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

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final lift = math.sin(_controller.value * math.pi) * 8;
        return Transform.translate(offset: Offset(0, -lift), child: child);
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = math.min(constraints.maxWidth, 610.0);
          final imageHeight = size * 0.96;

          return SizedBox(
            width: size,
            height: size * 1.04,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: size * 0.21,
                  child: Container(
                    width: size * 0.7,
                    height: size * 0.7,
                    decoration: const BoxDecoration(
                      color: _ProPalette.cream,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  top: size * 0.18,
                  left: size * 0.02,
                  child: _ArcRibbon(
                    size: size * 0.78,
                    startColor: _ProPalette.pink,
                  ),
                ),
                Positioned(
                  right: size * 0.01,
                  bottom: size * 0.06,
                  child: Transform.rotate(
                    angle: 2.22,
                    child: const _TriangleMark(
                      width: 96,
                      height: 184,
                      colors: [_ProPalette.orange, _ProPalette.red],
                    ),
                  ),
                ),
                Positioned(
                  right: size * 0.02,
                  bottom: size * 0.07,
                  child: _DotPattern(
                    color: _ProPalette.ink.withValues(alpha: 0.72),
                    size: 82,
                    dots: 49,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: ColorFiltered(
                      colorFilter: const ColorFilter.matrix(<double>[
                        0.2126,
                        0.7152,
                        0.0722,
                        0,
                        0,
                        0.2126,
                        0.7152,
                        0.0722,
                        0,
                        0,
                        0.2126,
                        0.7152,
                        0.0722,
                        0,
                        0,
                        0,
                        0,
                        0,
                        1,
                        0,
                      ]),
                      child: Image.asset(
                        PortfolioContent.profileAsset,
                        height: imageHeight,
                        width: size * 0.55,
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: size * 0.22,
                  child: Transform.rotate(
                    angle: -0.52,
                    child: _GradientBlock(
                      width: size * 0.9,
                      height: size * 0.17,
                      radius: 4,
                    ),
                  ),
                ),
                Positioned(
                  bottom: size * 0.08,
                  child: Transform.rotate(
                    angle: -0.52,
                    child: _GradientBlock(
                      width: size * 0.92,
                      height: size * 0.17,
                      radius: 4,
                      opacity: 0.72,
                    ),
                  ),
                ),
                Positioned(
                  top: size * 0.06,
                  right: size * 0.17,
                  child: const _Sparkle(size: 26),
                ),
                Positioned(
                  left: size * 0.05,
                  bottom: size * 0.3,
                  child: const _Sparkle(size: 18),
                ),
                Positioned(
                  right: -70,
                  top: size * 0.33,
                  child: const _HomeSocialRail(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HomeButton extends StatelessWidget {
  const _HomeButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        backgroundColor: _ProPalette.ink,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
        shape: const RoundedRectangleBorder(),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(width: 12),
          Container(
            width: 18,
            height: 18,
            alignment: Alignment.center,
            decoration: const BoxDecoration(gradient: _ProPalette.hotGradient),
            child: const Icon(Icons.north_east, size: 13, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _HomeContactLink extends StatelessWidget {
  const _HomeContactLink({
    required this.icon,
    required this.text,
    required this.onTap,
  });

  final IconData icon;
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                color: Color(0xFFF4F4F4),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 15, color: _ProPalette.ink),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: _ProPalette.ink,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeSocialRail extends StatelessWidget {
  const _HomeSocialRail();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _OutlineCircle(icon: Icons.camera_alt_outlined),
        const SizedBox(height: 16),
        const _OutlineCircle(icon: Icons.sports_basketball_outlined),
        const SizedBox(height: 16),
        const _OutlineCircle(icon: Icons.keyboard_tab_rounded),
        const SizedBox(height: 24),
        Container(
          width: 2,
          height: 104,
          color: _ProPalette.ink.withValues(alpha: 0.18),
        ),
      ],
    );
  }
}

class _OutlineCircle extends StatelessWidget {
  const _OutlineCircle({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        shape: BoxShape.circle,
        border: Border.all(color: _ProPalette.line),
      ),
      child: Icon(icon, size: 15, color: _ProPalette.ink),
    );
  }
}

class _TriangleMark extends StatelessWidget {
  const _TriangleMark({
    required this.width,
    required this.height,
    required this.colors,
  });

  final double width;
  final double height;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _TriangleClipper(),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
    );
  }
}

class _TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height * 0.82)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _ArcRibbon extends StatelessWidget {
  const _ArcRibbon({required this.size, required this.startColor});

  final double size;
  final Color startColor;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _ArcRibbonPainter(startColor),
    );
  }
}

class _ArcRibbonPainter extends CustomPainter {
  const _ArcRibbonPainter(this.startColor);

  final Color startColor;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.17
      ..strokeCap = StrokeCap.butt
      ..shader = SweepGradient(
        colors: [startColor, _ProPalette.red, _ProPalette.violet, startColor],
      ).createShader(rect);

    canvas.drawArc(
      rect.deflate(size.width * 0.16),
      math.pi * 1.06,
      math.pi * 1.35,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _ArcRibbonPainter oldDelegate) {
    return oldDelegate.startColor != startColor;
  }
}

class _Sparkle extends StatelessWidget {
  const _Sparkle({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: const _SparklePainter(),
    );
  }
}

class _SparklePainter extends CustomPainter {
  const _SparklePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _ProPalette.ink
      ..strokeWidth = 1.7
      ..strokeCap = StrokeCap.round;
    final c = Offset(size.width / 2, size.height / 2);

    canvas.drawLine(Offset(c.dx, 0), Offset(c.dx, size.height), paint);
    canvas.drawLine(Offset(0, c.dy), Offset(size.width, c.dy), paint);
    canvas.drawLine(
      Offset(size.width * 0.18, size.height * 0.18),
      Offset(size.width * 0.82, size.height * 0.82),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.82, size.height * 0.18),
      Offset(size.width * 0.18, size.height * 0.82),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AboutSection extends StatelessWidget {
  const _AboutSection({required this.onResumeTap});

  final VoidCallback onResumeTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 940;
        final isTightDesktop =
            constraints.maxWidth >= 940 && constraints.maxWidth < 1120;
        final contentInset = stacked ? 0.0 : (isTightDesktop ? 56.0 : 92.0);
        final profileWidth = isTightDesktop ? 380.0 : 430.0;
        final columnGap = isTightDesktop ? 54.0 : 90.0;
        final topInset = stacked ? 0.0 : 12.0;

        return Padding(
          padding: EdgeInsets.only(top: topInset),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: contentInset),
                child: const _AboutIntroHeader(),
              ),
              SizedBox(height: stacked ? 34 : 33),
              if (stacked) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ProfileSummaryCard(onResumeTap: onResumeTap),
                    const SizedBox(height: 40),
                    const _AboutNarrative(),
                  ],
                ),
              ] else
                Padding(
                  padding: EdgeInsets.only(left: contentInset),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: profileWidth,
                        child: _ProfileSummaryCard(onResumeTap: onResumeTap),
                      ),
                      SizedBox(width: columnGap),
                      const Expanded(child: _AboutNarrative()),
                    ],
                  ),
                ),
              SizedBox(height: stacked ? 58 : 88),
              _TimelinePanel(onResumeTap: onResumeTap),
            ],
          ),
        );
      },
    );
  }
}

class _AboutIntroHeader extends StatelessWidget {
  const _AboutIntroHeader();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = Breakpoints.isMobile(width);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nice to meet you!',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: _ProPalette.ink,
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'WELCOME TO...',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            color: _ProPalette.ink,
            fontSize: isMobile ? 40 : 50,
            fontWeight: FontWeight.w900,
            height: 0.98,
            letterSpacing: -1.2,
          ),
        ),
      ],
    );
  }
}

class _ProfileSummaryCard extends StatelessWidget {
  const _ProfileSummaryCard({required this.onResumeTap});

  final VoidCallback onResumeTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _AboutPortrait(),
          const SizedBox(height: 24),
          _GradientText(
            PortfolioContent.name.toUpperCase(),
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: Colors.white,
              fontSize: 42,
              fontWeight: FontWeight.w900,
              height: 1,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 10),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: PortfolioContent.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const TextSpan(text: ' based in '),
                const TextSpan(
                  text: 'Raipur',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: _ProPalette.ink,
              height: 1.25,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 28),
          _AboutDownloadLink(onTap: onResumeTap),
        ],
      ),
    );
  }
}

class _AboutPortrait extends StatelessWidget {
  const _AboutPortrait();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth.clamp(300.0, 430.0)
            : 430.0;
        final height = width * 0.87;
        final imageSize = width * 0.8;

        return SizedBox(
          width: width,
          height: height,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Positioned(
                left: width * 0.11,
                top: height * 0.37,
                child: _DotPattern(
                  color: _ProPalette.ink,
                  size: width * 0.19,
                  dots: 20,
                ),
              ),
              Positioned(
                left: width * 0.02,
                bottom: height * 0.11,
                child: Transform.rotate(
                  angle: -0.32,
                  child: _TriangleMark(
                    width: width * 0.34,
                    height: height * 0.2,
                    colors: const [_ProPalette.orange, _ProPalette.red],
                  ),
                ),
              ),
              Positioned(
                right: width * 0.03,
                bottom: height * 0.06,
                child: Transform.rotate(
                  angle: 0.18,
                  child: _GradientBlock(
                    width: width * 0.22,
                    height: height * 0.5,
                    radius: 90,
                    opacity: 0.92,
                  ),
                ),
              ),
              Positioned(
                top: height * 0.07,
                child: Container(
                  width: imageSize,
                  height: imageSize,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    PortfolioContent.profileAsset,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                ),
              ),
              Positioned(
                right: -width * 0.02,
                bottom: height * 0.08,
                child: Transform.rotate(
                  angle: -0.08,
                  child: Text(
                    'Aniket Parihar',
                    style: TextStyle(
                      color: _ProPalette.ink.withValues(alpha: 0.86),
                      fontFamily: 'Georgia',
                      fontSize: width * 0.105,
                      fontStyle: FontStyle.italic,
                      height: 0.85,
                    ),
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

class _AboutDownloadLink extends StatelessWidget {
  const _AboutDownloadLink({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Download CV',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: _ProPalette.ink,
              fontWeight: FontWeight.w900,
              decoration: TextDecoration.underline,
              decorationThickness: 1.6,
            ),
          ),
          const SizedBox(width: 7),
          Container(
            width: 21,
            height: 21,
            alignment: Alignment.center,
            color: _ProPalette.ink,
            child: const Icon(Icons.north_east, size: 15, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _AboutNarrative extends StatelessWidget {
  const _AboutNarrative();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _AboutFactGrid(),
        const SizedBox(height: 22),
        const Divider(color: _ProPalette.line, thickness: 1),
        const SizedBox(height: 48),
        LayoutBuilder(
          builder: (context, constraints) {
            const spacing = 28.0;
            final twoColumns = constraints.maxWidth >= 560;
            final metricWidth = twoColumns
                ? (constraints.maxWidth - spacing) / 2
                : constraints.maxWidth;

            return Wrap(
              spacing: spacing,
              runSpacing: 28,
              children: [
                _AboutMetricBlock(
                  width: metricWidth,
                  value: '02+',
                  label: 'Years\nexperience...',
                  body:
                      'Hello there! My name is Aniket Parihar. I am a Flutter developer, and I am very passionate and dedicated to my work.',
                ),
                _AboutMetricBlock(
                  width: metricWidth,
                  value: '08+',
                  label: 'Apps\nShipped...',
                  body:
                      'With production experience across maps, dashboards, attendance and commerce, I build reliable apps for real users.',
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 54),
        const _AboutQuoteBox(),
      ],
    );
  }
}

class _AboutFactGrid extends StatelessWidget {
  const _AboutFactGrid();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 28.0;
        final twoColumns = constraints.maxWidth >= 560;
        final itemWidth = twoColumns
            ? (constraints.maxWidth - spacing) / 2
            : constraints.maxWidth;

        return Wrap(
          spacing: spacing,
          runSpacing: 24,
          children: [
            SizedBox(
              width: itemWidth,
              child: const _AboutFactItem(
                icon: Icons.link_rounded,
                text: PortfolioContent.phone,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: const _AboutFactItem(
                icon: Icons.badge_outlined,
                text: '02 yrs',
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: const _AboutFactItem(
                icon: Icons.mail_outline_rounded,
                text: PortfolioContent.email,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: const _AboutFactItem(
                icon: Icons.location_on_outlined,
                text: PortfolioContent.location,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _AboutFactItem extends StatelessWidget {
  const _AboutFactItem({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: const BoxDecoration(
            color: Color(0xFFF5F5F5),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: _ProPalette.ink),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: _ProPalette.ink,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}

class _AboutMetricBlock extends StatelessWidget {
  const _AboutMetricBlock({
    required this.width,
    required this.value,
    required this.label,
    required this.body,
  });

  final double width;
  final String value;
  final String label;
  final String body;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _GradientText(
                value,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  height: 0.9,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: _ProPalette.ink,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                    height: 1.05,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            body,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: _ProPalette.ink.withValues(alpha: 0.88),
              height: 1.42,
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutQuoteBox extends StatelessWidget {
  const _AboutQuoteBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 44, vertical: 38),
      color: _ProPalette.ink,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '“',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.24),
              fontWeight: FontWeight.w900,
              height: 0.8,
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Text(
              'Flutter products should feel fast, clear and useful before they feel decorative.',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelinePanel extends StatelessWidget {
  const _TimelinePanel({required this.onResumeTap});

  final VoidCallback onResumeTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 900;
        final isTightDesktop =
            constraints.maxWidth >= 900 && constraints.maxWidth < 1120;
        final horizontalInset = stacked ? 30.0 : (isTightDesktop ? 56.0 : 92.0);
        final topInset = stacked ? 42.0 : 114.0;
        final bottomInset = stacked ? 42.0 : 92.0;
        final introWidth = isTightDesktop ? 320.0 : 360.0;
        final rowGap = isTightDesktop ? 70.0 : 160.0;

        return Container(
          width: double.infinity,
          constraints: BoxConstraints(minHeight: stacked ? 500 : 566),
          padding: EdgeInsets.fromLTRB(
            horizontalInset,
            topInset,
            horizontalInset,
            bottomInset,
          ),
          decoration: const BoxDecoration(gradient: _ProPalette.hotGradient),
          child: stacked
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ExperienceIntro(onResumeTap: onResumeTap),
                    const SizedBox(height: 42),
                    const _ExperienceRows(),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: introWidth,
                      child: _ExperienceIntro(onResumeTap: onResumeTap),
                    ),
                    SizedBox(width: rowGap),
                    const Expanded(child: _ExperienceRows()),
                  ],
                ),
        );
      },
    );
  }
}

class _ExperienceIntro extends StatelessWidget {
  const _ExperienceIntro({required this.onResumeTap});

  final VoidCallback onResumeTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Experience',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 22),
        Text(
          'MY EXPERIENCE',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            height: 1,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 28),
        Text(
          'Hello there! My name is Aniket Parihar. I am a Flutter developer, and I am very passionate and dedicated to my work.',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: Colors.white, height: 1.55),
        ),
        const SizedBox(height: 42),
        _HomeButton(label: 'Download my resume', onTap: onResumeTap),
      ],
    );
  }
}

class _ExperienceRows extends StatelessWidget {
  const _ExperienceRows();

  @override
  Widget build(BuildContext context) {
    final rows = [
      for (final item in PortfolioContent.experience) item,
      const ExperienceItem(
        role: PortfolioContent.educationTitle,
        company: PortfolioContent.educationResult,
        period: PortfolioContent.educationPeriod,
        location: 'Bhilai, India',
        summary: PortfolioContent.educationSchool,
        highlights: [],
      ),
    ];

    return Column(
      children: [
        for (var index = 0; index < rows.length; index++)
          _ExperienceBandRow(
            item: rows[index],
            showDivider: index != rows.length - 1,
          ),
      ],
    );
  }
}

class _ExperienceBandRow extends StatelessWidget {
  const _ExperienceBandRow({required this.item, required this.showDivider});

  final ExperienceItem item;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 520;

        final period = Text(
          '-${item.period}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
          ),
        );

        final role = Text(
          item.role.toUpperCase(),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            height: 1.08,
            letterSpacing: -0.5,
          ),
        );

        final company = Text(
          '-${item.company}',
          textAlign: stacked ? TextAlign.left : TextAlign.right,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        );

        return Padding(
          padding: EdgeInsets.only(bottom: showDivider ? 34 : 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (stacked)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    period,
                    const SizedBox(height: 12),
                    role,
                    const SizedBox(height: 12),
                    company,
                  ],
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [period, const SizedBox(height: 24), role],
                      ),
                    ),
                    const SizedBox(width: 20),
                    SizedBox(width: 170, child: company),
                  ],
                ),
              if (showDivider) ...[
                const SizedBox(height: 30),
                Container(
                  height: 1,
                  color: Colors.white.withValues(alpha: 0.24),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _ServicesSection extends StatefulWidget {
  const _ServicesSection();

  @override
  State<_ServicesSection> createState() => _ServicesSectionState();
}

class _ServicesSectionState extends State<_ServicesSection> {
  static const _items = [
    _ServiceRowData(
      title: 'LOCATION-FIRST SYSTEMS',
      description:
          'Google Maps integration, GIS-backed interfaces, geofencing and live tracking for real-world products.',
    ),
    _ServiceRowData(
      title: 'PRODUCT DELIVERY',
      description:
          'From UI architecture to API integration, I build reliable flows that keep dashboards, payments and users in sync.',
    ),
    _ServiceRowData(
      title: 'PROFESSIONAL STATE MANAGEMENT',
      description:
          'Comfortable with BLoC, Riverpod and clean component design for maintainable, scalable applications.',
    ),
    _ServiceRowData(
      title: 'TECHNICAL STACK',
      description:
          'Flutter, BLoC Pattern, Riverpod, Google Maps SDK, GIS concepts, REST APIs, Laravel and performance optimisation.',
    ),
  ];

  int _activeIndex = 2;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 760;
        final tightDesktop =
            constraints.maxWidth >= 760 && constraints.maxWidth < 1120;
        final leftInset = compact ? 0.0 : (tightDesktop ? 56.0 : 88.0);
        final rightInset = compact ? 0.0 : (tightDesktop ? 40.0 : 4.0);

        return Padding(
          padding: EdgeInsets.only(left: leftInset, right: rightInset),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _ServicesHeader(),
              SizedBox(height: compact ? 36 : 45),
              for (var index = 0; index < _items.length; index++)
                _ServiceAccordionRow(
                  item: _items[index],
                  isActive: index == _activeIndex,
                  onTap: () => setState(() => _activeIndex = index),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ServiceRowData {
  const _ServiceRowData({required this.title, required this.description});

  final String title;
  final String description;
}

class _ServicesHeader extends StatelessWidget {
  const _ServicesHeader();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = Breakpoints.isMobile(width);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Service',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: _ProPalette.ink,
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 22),
        Text(
          'MY SPECIALTIES',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            color: _ProPalette.ink,
            fontSize: isMobile ? 39 : 44,
            fontWeight: FontWeight.w900,
            height: 0.98,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

class _ServiceAccordionRow extends StatelessWidget {
  const _ServiceAccordionRow({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  final _ServiceRowData item;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 700;
        final leftColumnWidth = compact
            ? constraints.maxWidth
            : constraints.maxWidth < 1040
            ? 360.0
            : 520.0;
        final iconWidth = compact ? 42.0 : 54.0;

        return DecoratedBox(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: _ProPalette.ink.withValues(alpha: 0.15),
              ),
            ),
          ),
          child: InkWell(
            onTap: onTap,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            child: isActive
                ? _ActiveServiceRow(
                    item: item,
                    compact: compact,
                    leftColumnWidth: leftColumnWidth,
                    iconWidth: iconWidth,
                  )
                : _CollapsedServiceRow(
                    item: item,
                    compact: compact,
                    leftColumnWidth: leftColumnWidth,
                    iconWidth: iconWidth,
                  ),
          ),
        );
      },
    );
  }
}

class _CollapsedServiceRow extends StatelessWidget {
  const _CollapsedServiceRow({
    required this.item,
    required this.compact,
    required this.leftColumnWidth,
    required this.iconWidth,
  });

  final _ServiceRowData item;
  final bool compact;
  final double leftColumnWidth;
  final double iconWidth;

  @override
  Widget build(BuildContext context) {
    final title = _ServiceTitle(title: item.title, isActive: false);
    final body = _ServiceDescription(item.description);
    final glyph = const _ServiceActionGlyph(isActive: false);

    if (compact) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: title),
                SizedBox(width: iconWidth, child: glyph),
              ],
            ),
            const SizedBox(height: 18),
            body,
          ],
        ),
      );
    }

    return SizedBox(
      height: 108,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: leftColumnWidth, child: title),
          Expanded(child: body),
          SizedBox(width: iconWidth, child: glyph),
        ],
      ),
    );
  }
}

class _ActiveServiceRow extends StatelessWidget {
  const _ActiveServiceRow({
    required this.item,
    required this.compact,
    required this.leftColumnWidth,
    required this.iconWidth,
  });

  final _ServiceRowData item;
  final bool compact;
  final double leftColumnWidth;
  final double iconWidth;

  @override
  Widget build(BuildContext context) {
    final title = _ServiceTitle(title: item.title, isActive: true);
    final imageAndText = _ServiceImageAndText(description: item.description);
    final glyph = const _ServiceActionGlyph(isActive: true);

    if (compact) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: title),
                SizedBox(width: iconWidth, child: glyph),
              ],
            ),
            const SizedBox(height: 28),
            imageAndText,
          ],
        ),
      );
    }

    return SizedBox(
      height: 292,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 45),
            child: SizedBox(width: leftColumnWidth, child: title),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 36),
              child: imageAndText,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 45),
            child: SizedBox(width: iconWidth, child: glyph),
          ),
        ],
      ),
    );
  }
}

class _ServiceTitle extends StatelessWidget {
  const _ServiceTitle({required this.title, required this.isActive});

  final String title;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.headlineSmall?.copyWith(
      color: isActive ? Colors.white : _ProPalette.ink,
      fontSize: 28,
      fontWeight: FontWeight.w900,
      height: 1,
      letterSpacing: 0.2,
    );

    return Row(
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: isActive ? _ProPalette.violet : _ProPalette.ink,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 18),
        Flexible(
          child: isActive
              ? _GradientText(title, style: style)
              : Text(title, style: style),
        ),
      ],
    );
  }
}

class _ServiceDescription extends StatelessWidget {
  const _ServiceDescription(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        color: _ProPalette.ink.withValues(alpha: 0.68),
        fontSize: 14,
        height: 1.55,
        letterSpacing: 0.05,
      ),
    );
  }
}

class _ServiceImageAndText extends StatelessWidget {
  const _ServiceImageAndText({required this.description});

  final String description;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 480),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            'assets/images/service_mobile_application.png',
            width: 390,
            height: 164,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 24),
          _ServiceDescription(description),
        ],
      ),
    );
  }
}

class _ServiceActionGlyph extends StatelessWidget {
  const _ServiceActionGlyph({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: CustomPaint(
        size: const Size.square(27),
        painter: _ServiceActionGlyphPainter(isActive: isActive),
      ),
    );
  }
}

class _ServiceActionGlyphPainter extends CustomPainter {
  const _ServiceActionGlyphPainter({required this.isActive});

  final bool isActive;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _ProPalette.ink
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.square;
    final center = size.height / 2;

    canvas.drawLine(Offset(0, center), Offset(size.width, center), paint);
    if (!isActive) {
      canvas.drawLine(Offset(center, 0), Offset(center, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ServiceActionGlyphPainter oldDelegate) {
    return oldDelegate.isActive != isActive;
  }
}

class _WorksSection extends StatelessWidget {
  const _WorksSection();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 760;
        final tightDesktop =
            constraints.maxWidth >= 760 && constraints.maxWidth < 1120;
        final leftInset = compact ? 0.0 : (tightDesktop ? 56.0 : 88.0);
        final rightInset = compact ? 0.0 : (tightDesktop ? 40.0 : 4.0);

        return Padding(
          padding: EdgeInsets.only(left: leftInset, right: rightInset),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _WorksHeader(),
              SizedBox(height: compact ? 34 : 42),
              const _WorksProjectGrid(),
              SizedBox(height: compact ? 34 : 48),
              Center(child: _WorkLoadMoreButton(onTap: () {})),
              SizedBox(height: compact ? 58 : 94),
              const _WorkTestimonialPanel(),
            ],
          ),
        );
      },
    );
  }
}

class _WorksHeader extends StatelessWidget {
  const _WorksHeader();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = Breakpoints.isMobile(width);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Work',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: _ProPalette.ink,
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 22),
        Text(
          'RECENT PROJECT',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            color: _ProPalette.ink,
            fontSize: isMobile ? 39 : 44,
            fontWeight: FontWeight.w900,
            height: 0.98,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

class _WorksProjectGrid extends StatelessWidget {
  const _WorksProjectGrid();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final twoColumns = constraints.maxWidth >= 920;
        final columnGap = constraints.maxWidth < 1080 ? 50.0 : 78.0;
        final rowGap = constraints.maxWidth < 1080 ? 42.0 : 44.0;
        final itemWidth = twoColumns
            ? (constraints.maxWidth - columnGap) / 2
            : constraints.maxWidth;

        return Wrap(
          spacing: columnGap,
          runSpacing: rowGap,
          children: [
            for (var i = 0; i < PortfolioContent.projects.length; i++)
              SizedBox(
                width: itemWidth,
                child: _WorkProjectItem(
                  project: PortfolioContent.projects[i],
                  index: i,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _WorkProjectItem extends StatelessWidget {
  const _WorkProjectItem({required this.project, required this.index});

  final ProjectItem project;
  final int index;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 430;
        final textBlock = _WorkProjectText(project: project);
        final thumbnail = _ProjectThumbnail(index: index);

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [textBlock, const SizedBox(height: 18), thumbnail],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 170, child: textBlock),
            const SizedBox(width: 28),
            Expanded(child: thumbnail),
          ],
        );
      },
    );
  }
}

class _WorkProjectText extends StatelessWidget {
  const _WorkProjectText({required this.project});

  final ProjectItem project;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          project.category,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: _ProPalette.ink,
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 15),
        Text(
          project.title,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: _ProPalette.ink,
            fontSize: 30,
            fontWeight: FontWeight.w900,
            height: 0.94,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 27),
        const Icon(Icons.north_east, color: _ProPalette.ink, size: 43),
      ],
    );
  }
}

class _ProjectThumbnail extends StatelessWidget {
  const _ProjectThumbnail({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.27,
      child: ClipRect(
        child: CustomPaint(
          painter: _ProjectThumbnailPainter(index),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _ProjectThumbnailPainter extends CustomPainter {
  const _ProjectThumbnailPainter(this.index);

  final int index;

  @override
  void paint(Canvas canvas, Size size) {
    switch (index % 4) {
      case 0:
        _paintDinnerScene(canvas, size);
      case 1:
        _paintAtmScene(canvas, size);
      case 2:
        _paintBottleScene(canvas, size);
      default:
        _paintCosmeticScene(canvas, size);
    }
  }

  void _paintDinnerScene(Canvas canvas, Size size) {
    final bg = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF6951FF), Color(0xFFB4A8FF)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, bg);

    final dark = Paint()..color = const Color(0xFF17114E);
    final plate = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.025
      ..color = const Color(0xFF1B3EEB);
    canvas.drawCircle(
      Offset(size.width * 0.52, size.height * 0.69),
      size.width * 0.16,
      plate,
    );
    canvas.drawCircle(
      Offset(size.width * 0.52, size.height * 0.69),
      size.width * 0.1,
      plate,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.13,
          size.height * 0.55,
          size.width * 0.07,
          size.height * 0.32,
        ),
        const Radius.circular(18),
      ),
      dark,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.24,
          size.height * 0.55,
          size.width * 0.035,
          size.height * 0.31,
        ),
        const Radius.circular(10),
      ),
      dark,
    );
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.56, size.height * 0.11)
        ..cubicTo(
          size.width * 0.41,
          size.height * 0.25,
          size.width * 0.45,
          size.height * 0.42,
          size.width * 0.55,
          size.height * 0.5,
        )
        ..cubicTo(
          size.width * 0.7,
          size.height * 0.37,
          size.width * 0.74,
          size.height * 0.21,
          size.width * 0.56,
          size.height * 0.11,
        ),
      Paint()..color = const Color(0xFFD8D9FF),
    );
    canvas.drawCircle(
      Offset(size.width * 0.58, size.height * 0.44),
      size.width * 0.05,
      dark,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.73,
          size.height * 0.66,
          size.width * 0.19,
          size.height * 0.13,
        ),
        const Radius.circular(18),
      ),
      Paint()..color = const Color(0xFFE8DAFF),
    );
  }

  void _paintAtmScene(Canvas canvas, Size size) {
    final bg = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFF7DDAA), Color(0xFFFFD0D8)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, bg);

    for (var i = 0; i < 3; i++) {
      final left = size.width * (0.18 + i * 0.22);
      final top = size.height * (0.23 - i * 0.02);
      final body = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, size.width * 0.19, size.height * 0.52),
        const Radius.circular(20),
      );
      canvas.drawRRect(body, Paint()..color = const Color(0xFFFF7E94));
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            left + size.width * 0.035,
            top + size.height * 0.13,
            size.width * 0.12,
            size.height * 0.2,
          ),
          const Radius.circular(4),
        ),
        Paint()..color = const Color(0xFF2A2633),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            left + size.width * 0.03,
            top - size.height * 0.035,
            size.width * 0.13,
            size.height * 0.08,
          ),
          const Radius.circular(12),
        ),
        Paint()..color = Colors.white.withValues(alpha: 0.92),
      );
    }
  }

  void _paintBottleScene(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFE9CDD4),
    );
    canvas.save();
    canvas.translate(size.width * 0.53, size.height * 0.5);
    canvas.rotate(-0.72);
    final bottle = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset.zero,
        width: size.width * 0.28,
        height: size.height * 0.78,
      ),
      const Radius.circular(28),
    );
    canvas.drawRRect(bottle, Paint()..color = const Color(0xFFB8A5A6));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(0, -size.height * 0.45),
          width: size.width * 0.16,
          height: size.height * 0.13,
        ),
        const Radius.circular(10),
      ),
      Paint()..color = const Color(0xFF4B4348),
    );
    canvas.drawCircle(
      Offset(-size.width * 0.06, -size.height * 0.08),
      size.width * 0.035,
      Paint()..color = _ProPalette.orange,
    );
    canvas.drawCircle(
      Offset(size.width * 0.07, size.height * 0.08),
      size.width * 0.025,
      Paint()..color = _ProPalette.orange,
    );
    canvas.restore();
  }

  void _paintCosmeticScene(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFD9E9E8),
    );
    final shadow = Paint()..color = _ProPalette.ink.withValues(alpha: 0.08);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.52, size.height * 0.68),
        width: size.width * 0.42,
        height: size.height * 0.14,
      ),
      shadow,
    );
    for (var i = 0; i < 2; i++) {
      canvas.save();
      canvas.translate(
        size.width * (0.43 + i * 0.19),
        size.height * (0.47 + i * 0.08),
      );
      canvas.rotate(i == 0 ? -0.38 : 0.18);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: size.width * 0.13,
            height: size.height * 0.48,
          ),
          const Radius.circular(20),
        ),
        Paint()..color = const Color(0xFFE8F0F0),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(0, -size.height * 0.27),
            width: size.width * 0.12,
            height: size.height * 0.08,
          ),
          const Radius.circular(8),
        ),
        Paint()..color = const Color(0xFFFFB74B),
      );
      canvas.restore();
    }
    final petal = Paint()..color = const Color(0xFFFFD36E);
    for (var i = 0; i < 6; i++) {
      canvas.drawCircle(
        Offset(
          size.width * (0.64 + math.cos(i) * 0.06),
          size.height * (0.29 + math.sin(i) * 0.05),
        ),
        size.width * 0.027,
        petal,
      );
    }
    canvas.drawCircle(
      Offset(size.width * 0.64, size.height * 0.29),
      size.width * 0.025,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant _ProjectThumbnailPainter oldDelegate) {
    return oldDelegate.index != index;
  }
}

class _WorkLoadMoreButton extends StatelessWidget {
  const _WorkLoadMoreButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        backgroundColor: _ProPalette.ink,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 18),
        shape: const RoundedRectangleBorder(),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Load more',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 18,
            height: 18,
            alignment: Alignment.center,
            decoration: const BoxDecoration(gradient: _ProPalette.hotGradient),
            child: const Icon(Icons.north_east, size: 13, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _WorkTestimonialPanel extends StatelessWidget {
  const _WorkTestimonialPanel();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 820;

        return Container(
          width: double.infinity,
          constraints: BoxConstraints(minHeight: stacked ? 660 : 728),
          padding: EdgeInsets.fromLTRB(
            stacked ? 30 : 92,
            stacked ? 44 : 78,
            stacked ? 30 : 92,
            stacked ? 36 : 58,
          ),
          decoration: const BoxDecoration(gradient: _ProPalette.hotGradient),
          child: Column(
            children: [
              Text(
                'Testimonial',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'WHAT THEY SAYS',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  height: 1,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: stacked ? 44 : 46),
              if (stacked)
                const Column(
                  children: [
                    _TestimonialVisual(),
                    SizedBox(height: 34),
                    _TestimonialCopy(),
                  ],
                )
              else
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(width: 320, child: _TestimonialVisual()),
                    SizedBox(width: 100),
                    Expanded(child: _TestimonialCopy()),
                  ],
                ),
              const SizedBox(height: 42),
              Container(height: 1, color: Colors.white.withValues(alpha: 0.68)),
              const SizedBox(height: 48),
              const _TestimonialLogos(),
            ],
          ),
        );
      },
    );
  }
}

class _TestimonialVisual extends StatelessWidget {
  const _TestimonialVisual();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 340,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 6,
            top: 70,
            child: Transform.rotate(
              angle: -0.74,
              child: _TriangleMark(
                width: 118,
                height: 122,
                colors: const [_ProPalette.orange, _ProPalette.violet],
              ),
            ),
          ),
          Positioned(
            left: 48,
            top: 112,
            child: Container(
              width: 134,
              height: 96,
              color: Colors.white.withValues(alpha: 0.24),
            ),
          ),
          Positioned(
            bottom: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
              child: Image.asset(
                PortfolioContent.profileAsset,
                width: 260,
                height: 310,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TestimonialCopy extends StatelessWidget {
  const _TestimonialCopy();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '“ Flutter delivery made easy - including map-first workflows, clean dashboards and reliable production features.”',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 28),
        Text(
          '-Product Team',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Flutter Application Delivery',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 40),
        const Row(
          children: [
            _RoundArrowButton(icon: Icons.arrow_back),
            SizedBox(width: 16),
            _RoundArrowButton(icon: Icons.arrow_forward),
          ],
        ),
      ],
    );
  }
}

class _RoundArrowButton extends StatelessWidget {
  const _RoundArrowButton({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: _ProPalette.ink, size: 24),
    );
  }
}

class _TestimonialLogos extends StatelessWidget {
  const _TestimonialLogos();

  @override
  Widget build(BuildContext context) {
    final logos = [
      ('square', Icons.square_outlined),
      ('PAPERZ', Icons.flag_rounded),
      ('cuebia', Icons.category_outlined),
      ('Martino', Icons.view_column_rounded),
    ];

    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      runAlignment: WrapAlignment.center,
      spacing: 42,
      runSpacing: 24,
      children: [
        for (final logo in logos)
          _TestimonialLogo(label: logo.$1, icon: logo.$2),
      ],
    );
  }
}

class _TestimonialLogo extends StatelessWidget {
  const _TestimonialLogo({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BlogSection extends StatelessWidget {
  const _BlogSection();

  @override
  Widget build(BuildContext context) {
    final posts = [
      const _InsightPost(
        tag: 'Maps',
        title: 'Designing app screens when location is the primary data.',
        body:
            'Notes on making maps useful without overwhelming users with markers, states and permissions.',
        icon: Icons.map_outlined,
      ),
      const _InsightPost(
        tag: 'Flutter',
        title:
            'Keeping Flutter product code maintainable under delivery pressure.',
        body:
            'How reusable widgets, clear state boundaries and API contracts reduce chaos in production apps.',
        icon: Icons.account_tree_outlined,
      ),
      const _InsightPost(
        tag: 'Product',
        title: 'Why dashboards need fewer numbers and stronger decisions.',
        body:
            'A practical way to think about operational dashboards for attendance, booking and commerce flows.',
        icon: Icons.dashboard_customize_outlined,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(
          eyebrow: 'Blog direction',
          title: 'A professional blog page, ready for real case studies.',
          body:
              'Instead of dummy lorem ipsum, this section frames the topics Aniket can credibly write about.',
        ),
        const SizedBox(height: 30),
        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = constraints.maxWidth < 900
                ? constraints.maxWidth
                : (constraints.maxWidth - 44) / 3;

            return Wrap(
              spacing: 22,
              runSpacing: 22,
              children: [
                for (final post in posts)
                  SizedBox(
                    width: cardWidth,
                    child: _InsightCard(post: post),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _ContactSection extends StatelessWidget {
  const _ContactSection({required this.onLaunch});

  final ValueChanged<String> onLaunch;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 900;

        final lead = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionTitle(
              eyebrow: 'Contact',
              title:
                  'Have a Flutter app, map feature or product workflow to build?',
              body:
                  'Reach out through email, phone or professional profiles. The fastest path is email with project context and timeline.',
            ),
            const SizedBox(height: 26),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                for (final action in PortfolioContent.contactActions)
                  _ContactActionCard(
                    action: action,
                    onTap: () => onLaunch(action.url),
                  ),
              ],
            ),
          ],
        );

        final panel = _ContactPanel(onLaunch: onLaunch);

        if (stacked) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [lead, const SizedBox(height: 28), panel],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 6, child: lead),
            const SizedBox(width: 34),
            Expanded(flex: 5, child: panel),
          ],
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.eyebrow,
    required this.title,
    required this.body,
  });

  final String eyebrow;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 780),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            eyebrow,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: _ProPalette.orange,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: _ProPalette.ink,
              fontWeight: FontWeight.w900,
              height: 1.05,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            body,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: _ProPalette.muted,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightPost {
  const _InsightPost({
    required this.tag,
    required this.title,
    required this.body,
    required this.icon,
  });

  final String tag;
  final String title;
  final String body;
  final IconData icon;
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.post});

  final _InsightPost post;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _IconBox(icon: post.icon, compact: true),
              const Spacer(),
              Text(
                post.tag,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: _ProPalette.orange,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),
          Text(
            post.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
              height: 1.16,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            post.body,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: _ProPalette.muted,
              height: 1.65,
            ),
          ),
          const SizedBox(height: 20),
          const _TextArrow(label: 'Read note'),
        ],
      ),
    );
  }
}

class _ContactPanel extends StatelessWidget {
  const _ContactPanel({required this.onLaunch});

  final ValueChanged<String> onLaunch;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: _ProPalette.hotGradient,
        borderRadius: BorderRadius.circular(34),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Project brief',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Share the product goal, platform, timeline and any maps/API requirements. I will respond with a practical next step.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.88),
              height: 1.7,
            ),
          ),
          const SizedBox(height: 26),
          _BriefLine(label: 'Name'),
          const SizedBox(height: 18),
          _BriefLine(label: 'Email'),
          const SizedBox(height: 18),
          _BriefLine(label: 'Project details', tall: true),
          const SizedBox(height: 26),
          _DarkButton(
            label: 'Email Aniket',
            onTap: () => onLaunch('mailto:${PortfolioContent.email}'),
          ),
        ],
      ),
    );
  }
}

class _ContactActionCard extends StatelessWidget {
  const _ContactActionCard({required this.action, required this.onTap});

  final ContactAction action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: _SurfaceCard(
        padding: const EdgeInsets.all(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _IconBox(icon: action.icon, compact: true),
              const SizedBox(height: 18),
              Text(
                action.title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              Text(
                action.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: _ProPalette.muted,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({
    required this.child,
    this.padding = const EdgeInsets.all(24),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _ProPalette.line),
        boxShadow: [
          BoxShadow(
            color: _ProPalette.ink.withValues(alpha: 0.05),
            blurRadius: 34,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: _ProPalette.ink,
        side: const BorderSide(color: _ProPalette.ink),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 17),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
    );
  }
}

class _GradientButton extends StatelessWidget {
  const _GradientButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: _ProPalette.hotGradient,
        borderRadius: BorderRadius.circular(18),
      ),
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(width: 10),
            const Icon(Icons.north_east, size: 18),
          ],
        ),
      ),
    );
  }
}

class _DarkButton extends StatelessWidget {
  const _DarkButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        backgroundColor: _ProPalette.ink,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
    );
  }
}

class _SocialIcon extends StatelessWidget {
  const _SocialIcon({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      style: IconButton.styleFrom(
        foregroundColor: _ProPalette.ink,
        backgroundColor: Colors.white,
      ),
    );
  }
}

class _IconBox extends StatelessWidget {
  const _IconBox({required this.icon, this.compact = false});

  final IconData icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 42.0 : 54.0;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _ProPalette.cream,
        borderRadius: BorderRadius.circular(compact ? 14 : 18),
        border: Border.all(color: _ProPalette.line),
      ),
      child: Icon(icon, color: _ProPalette.ink, size: compact ? 18 : 24),
    );
  }
}

class _GradientBlock extends StatelessWidget {
  const _GradientBlock({
    required this.width,
    required this.height,
    this.radius = 999,
    this.opacity = 1,
  });

  final double width;
  final double height;
  final double radius;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _ProPalette.orange.withValues(alpha: 0.34 * opacity),
            _ProPalette.red.withValues(alpha: 0.82 * opacity),
            _ProPalette.violet.withValues(alpha: 0.95 * opacity),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class _DotPattern extends StatelessWidget {
  const _DotPattern({required this.color, this.size = 88, this.dots = 64});

  final Color color;
  final double size;
  final int dots;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (var i = 0; i < dots; i++)
            Container(
              width: 3,
              height: 3,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
        ],
      ),
    );
  }
}

class _GradientText extends StatelessWidget {
  const _GradientText(this.text, {this.style});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => _ProPalette.hotGradient.createShader(bounds),
      child: Text(text, style: style?.copyWith(color: Colors.white)),
    );
  }
}

class _TextArrow extends StatelessWidget {
  const _TextArrow({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: _ProPalette.ink,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(width: 8),
        const Icon(Icons.north_east, size: 16, color: _ProPalette.ink),
      ],
    );
  }
}

class _BriefLine extends StatelessWidget {
  const _BriefLine({required this.label, this.tall = false});

  final String label;
  final bool tall;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: tall ? 74 : 46,
      alignment: Alignment.topLeft,
      padding: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.7)),
        ),
      ),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.white.withValues(alpha: 0.78),
          fontWeight: FontWeight.w900,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

abstract final class _ProPalette {
  static const Color stage = Color(0xFF3F3F3D);
  static const Color ink = Color(0xFF111111);
  static const Color canvas = Color(0xFFF5F2ED);
  static const Color paper = Color(0xFFFFFCF7);
  static const Color cream = Color(0xFFFFE9C8);
  static const Color line = Color(0x1F111111);
  static const Color muted = Color(0xB0111111);
  static const Color orange = Color(0xFFFF9E3D);
  static const Color red = Color(0xFFFF625B);
  static const Color pink = Color(0xFFE066C8);
  static const Color violet = Color(0xFF9B35F2);

  static const LinearGradient hotGradient = LinearGradient(
    colors: [violet, pink, red, orange],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
