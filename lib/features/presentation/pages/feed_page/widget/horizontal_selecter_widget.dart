import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tinydroplets/common/widgets/loader.dart';
import 'package:tinydroplets/core/constant/app_export.dart';
import '../bloc/age_group_bloc/age_group_cubit.dart';
import 'age_circle_widget.dart';

class HorizontalSelector extends StatefulWidget {
  final ValueChanged<int> onIndexSelected;

  const HorizontalSelector({super.key, required this.onIndexSelected});

  @override
  _HorizontalSelectorState createState() => _HorizontalSelectorState();
}

class _HorizontalSelectorState extends State<HorizontalSelector> {
  final ScrollController _scrollController = ScrollController();
  int _selectedIndex = 0;
  final double scrollOffset = 150.0;
  bool _hasAutoSelected = false;

  void _scrollLeft() {
    double newPosition = _scrollController.offset - scrollOffset;
    if (newPosition < 0) newPosition = 0;
    _scrollController.animateTo(
      newPosition,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _scrollRight() {
    double maxScroll = _scrollController.position.maxScrollExtent;
    double newPosition = _scrollController.offset + scrollOffset;
    if (newPosition > maxScroll) newPosition = maxScroll;
    _scrollController.animateTo(
      newPosition,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void initState() {
    super.initState();
    context.read<AgeGroupCubit>().fetchAgeGroup();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AgeGroupCubit, AgeGroupState>(
        builder: (context, state) {
          if (state is AgeGroupLoading) {
            return Loader();
          } else if (state is AgeGroupLoaded) {
            if (!_hasAutoSelected && state.ageGroupList.isNotEmpty) {
              _hasAutoSelected = true;
              final int firstId = state.ageGroupList[0]['id'];
              WidgetsBinding.instance.addPostFrameCallback((_) {
                widget.onIndexSelected(firstId);
              });
            }
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: _scrollLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(8.0),
                        topRight: Radius.circular(8.0),
                      ),
                      color: Colors.black38,
                    ),
                    child: Transform.flip(
                      flipX: true,
                      child: const Icon(Icons.double_arrow, color: Colors.white),
                    ),
                  ),
                ),
                state.ageGroupList.isEmpty
                    ? const Text('No data')
                    : SizedBox(
                  height: 60,
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: state.ageGroupList.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 15.0),
                        child: AgeCircleWidget(
                          onTap: () {
                            setState(() => _selectedIndex = index);
                            // setState(() => _selectedIndex = state.ageGroupList[index]['id']);
                            // widget.onIndexSelected(index);
                            widget.onIndexSelected(state.ageGroupList[index]['id']);
                          },
                          text: state.ageGroupList[index]['age_group'].toString(),
                          isSelected: _selectedIndex == index,
                        ),
                      );
                    },
                  ),
                ),
                InkWell(
                  onTap: _scrollRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(8.0),
                        topRight: Radius.circular(8.0),
                      ),
                      color: Colors.black38,
                    ),
                    child: const Icon(Icons.double_arrow, color: Colors.white),
                  ),
                ),
              ],
            );
          } else if (state is AgeGroupError) {
            return Center(child: Text('Error: ${state.message}'));
          } else {
            return const SizedBox.shrink();
          }
        },
      );
  }
}
