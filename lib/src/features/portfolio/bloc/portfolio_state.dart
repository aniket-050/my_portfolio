part of 'portfolio_bloc.dart';

class PortfolioState extends Equatable {
  const PortfolioState({
    this.activeSection = PortfolioSection.home,
    this.requestedSection = PortfolioSection.home,
    this.scrollRequestId = 0,
    this.hoveredProjectId,
    this.isMenuOpen = false,
  });

  final PortfolioSection activeSection;
  final PortfolioSection requestedSection;
  final int scrollRequestId;
  final String? hoveredProjectId;
  final bool isMenuOpen;

  PortfolioState copyWith({
    PortfolioSection? activeSection,
    PortfolioSection? requestedSection,
    int? scrollRequestId,
    Object? hoveredProjectId = _copySentinel,
    bool? isMenuOpen,
  }) {
    return PortfolioState(
      activeSection: activeSection ?? this.activeSection,
      requestedSection: requestedSection ?? this.requestedSection,
      scrollRequestId: scrollRequestId ?? this.scrollRequestId,
      hoveredProjectId: hoveredProjectId == _copySentinel
          ? this.hoveredProjectId
          : hoveredProjectId as String?,
      isMenuOpen: isMenuOpen ?? this.isMenuOpen,
    );
  }

  @override
  List<Object?> get props => [
    activeSection,
    requestedSection,
    scrollRequestId,
    hoveredProjectId,
    isMenuOpen,
  ];
}

const Object _copySentinel = Object();
