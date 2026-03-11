import 'package:flutter_bloc/flutter_bloc.dart';

import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc() : super(DashboardInitialState(0)) {
    on<NavigateToIndex>(
        (event, emit) => emit(DashboardNavigationState(event.index)));
    on<ResetNavigation>(
      (event, emit) => emit(DashboardInitialState(0)),
    );
  }
}
