abstract class DashboardState {}

class DashboardInitialState extends DashboardState {
  final int currentIndex;
  DashboardInitialState(this.currentIndex);
}

class DashboardNavigationState extends DashboardState {
  final int currentIndex;
  DashboardNavigationState(this.currentIndex);
}
