import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/constant/app_export.dart';
import '../../../../../core/constant/app_vector.dart';
import '../../../../../core/theme/theme_bloc/theme_bloc.dart';
import '../../../../../core/theme/theme_bloc/theme_event.dart';
import '../../../../../core/theme/theme_bloc/theme_state.dart';

class EbookReadMode extends StatefulWidget {
  const EbookReadMode({super.key});

  @override
  State<EbookReadMode> createState() => _EbookReadModeState();
}

class _EbookReadModeState extends State<EbookReadMode> {
  double sliderValue = 0.5;
  Duration duration = Duration(minutes: 3, seconds: 30); // Total duration
  Duration position = Duration(minutes: 1, seconds: 45); // Current position

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          // colors: [Colors.pink, Colors.red],
          colors: [Colors.pink.shade100, Colors.deepOrange],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Scaffold(
          backgroundColor: AppColor.transparentColor,
          appBar: AppBar(
            backgroundColor: AppColor.transparentColor,
            leading: Transform.translate(
              offset: const Offset(-15, 0),
              child: InkWell(
                onTap: () => backTo(context),
                highlightColor: AppColor.transparentColor,
                focusColor: AppColor.transparentColor,
                splashColor: AppColor.transparentColor,
                child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Icon(CupertinoIcons.back)),
              ),
            ),
            title: Text(
              'The Arsonist',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          body: Column(
            children: [
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Chapter: 1',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700),
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Text(
                                  "  Lorem ipsum dolor sit amet, consectetu ryguu adipiscing elit, sed do eiusmodiuiuiuij temporuiuiuq incididunt ut labore et dolores magna aliquap Ut enim ad minim veniam, its quis nostrudjj poo exercitation ullamcomoum laboris nisi ut aliquip ex ea commodookolom consequat. Duis aute irure dolor inputsoii lwil reprehenderit in voluptate velit esse cillumss dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt inputs culpa qui officia deserunt mollit anim idestim laborum.Lorem ipsum dolor sit amet, consectetu ryguu adipiscing elit, sed do eiusmodiuiuiuij temporuiuiuq incididunt ut labore et dolores magna aliquap Ut enim ad minim veniam, its quis nostrudjj poo exercitation ullamcomoum laboris nisi ut aliquip ex ea commodookolom consequat.",
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: Colors.white,
                              inactiveTrackColor: Colors.white38,
                              thumbColor: Colors.white,
                              overlayShape: SliderComponentShape.noOverlay,
                            ),
                            child: Slider(
                              value: sliderValue,
                              onChanged: (value) {
                                setState(() {
                                  sliderValue = value;
                                  position = duration * sliderValue;
                                });
                              },
                              min: 0,
                              max: 1,
                            ),
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Text(
                            '124 of 170',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: IconButton(
                              onPressed: () {},
                              icon: Icon(CupertinoIcons.book),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: IconButton(
                              onPressed: () {},
                              icon: Icon(CupertinoIcons.list_bullet),
                            ),
                          ),
                          BlocBuilder<ThemeBloc, ThemeState>(
                            builder: (context, state) {
                              return Padding(
                                padding: const EdgeInsets.all(10),
                                child: IconButton(
                                  onPressed: () {
                                    context
                                        .read<ThemeBloc>()
                                        .add(ToggleThemeEvent());
                                  },
                                  icon: Icon(state is LightThemeState
                                      ? CupertinoIcons.sun_max_fill
                                      : CupertinoIcons.moon_fill),
                                ),
                              );
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: IconButton(
                              onPressed: () {},
                              icon: Icon(CupertinoIcons.headphones),
                            ),
                          ),
                        ],
                      )
                    ],
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
