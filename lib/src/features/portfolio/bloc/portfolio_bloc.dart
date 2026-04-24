import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/portfolio_models.dart';

part 'portfolio_event.dart';
part 'portfolio_state.dart';

class PortfolioBloc extends Bloc<PortfolioEvent, PortfolioState> {
  PortfolioBloc() : super(const PortfolioState()) {
    on<PortfolioSectionRequested>(_onSectionRequested);
    on<PortfolioSectionActivated>(_onSectionActivated);
    on<PortfolioMenuToggled>(_onMenuToggled);
    on<PortfolioProjectHovered>(_onProjectHovered);
  }

  void _onSectionRequested(
    PortfolioSectionRequested event,
    Emitter<PortfolioState> emit,
  ) {
    emit(
      state.copyWith(
        activeSection: event.section,
        requestedSection: event.section,
        scrollRequestId: state.scrollRequestId + 1,
        isMenuOpen: false,
      ),
    );
  }

  void _onSectionActivated(
    PortfolioSectionActivated event,
    Emitter<PortfolioState> emit,
  ) {
    if (event.section == state.activeSection) {
      return;
    }

    emit(state.copyWith(activeSection: event.section));
  }

  void _onMenuToggled(
    PortfolioMenuToggled event,
    Emitter<PortfolioState> emit,
  ) {
    emit(state.copyWith(isMenuOpen: !state.isMenuOpen));
  }

  void _onProjectHovered(
    PortfolioProjectHovered event,
    Emitter<PortfolioState> emit,
  ) {
    emit(state.copyWith(hoveredProjectId: event.projectId));
  }
}
