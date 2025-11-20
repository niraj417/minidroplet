abstract class DashboardEvent {}

class NavigateToIndex extends DashboardEvent {
  final int index;
  NavigateToIndex(this.index);
}
class ResetNavigation extends DashboardEvent {}
