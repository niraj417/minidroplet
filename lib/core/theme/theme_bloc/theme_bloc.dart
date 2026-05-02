import 'package:flutter_bloc/flutter_bloc.dart';
import '../../utils/shared_pref.dart';
import '../app_color.dart';
import 'theme_event.dart';
import 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(SharedPref.getTheme() ? DarkThemeState() : LightThemeState()) {
    add(FetchPrimaryColorEvent());

    on<ToggleThemeEvent>(
          (event, emit) async {
        if (state is LightThemeState) {
          emit(DarkThemeState());
          await SharedPref.setTheme(true);
        } else {
          emit(LightThemeState());
          await SharedPref.setTheme(false);
        }
      },
    );

    on<FetchPrimaryColorEvent>((event, emit) async {
      await AppColor.fetchAndSetPrimaryColor();
      emit(state is LightThemeState ? LightThemeState() : DarkThemeState());
    });
  }
}
