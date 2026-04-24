part of 'portfolio_bloc.dart';

sealed class PortfolioEvent extends Equatable {
  const PortfolioEvent();

  @override
  List<Object?> get props => [];
}

final class PortfolioSectionRequested extends PortfolioEvent {
  const PortfolioSectionRequested(this.section);

  final PortfolioSection section;

  @override
  List<Object?> get props => [section];
}

final class PortfolioSectionActivated extends PortfolioEvent {
  const PortfolioSectionActivated(this.section);

  final PortfolioSection section;

  @override
  List<Object?> get props => [section];
}

final class PortfolioMenuToggled extends PortfolioEvent {
  const PortfolioMenuToggled();
}

final class PortfolioProjectHovered extends PortfolioEvent {
  const PortfolioProjectHovered(this.projectId);

  final String? projectId;

  @override
  List<Object?> get props => [projectId];
}
