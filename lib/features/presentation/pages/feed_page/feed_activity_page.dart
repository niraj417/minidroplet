import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tinydroplets/common/widgets/loader.dart';
import 'package:tinydroplets/features/presentation/pages/feed_page/widget/age_circle_widget.dart';
import 'package:tinydroplets/features/presentation/pages/feed_page/widget/horizontal_selecter_widget.dart';
import '../../../../common/widgets/custom_expansion_tile.dart';
import '../../../../core/constant/app_export.dart';
import 'bloc/age_group_bloc/age_group_cubit.dart';
import 'bloc/track_milestone_bloc/track_milestone_cubit.dart';

class FeedActivityPage extends StatefulWidget {
  final int id;
  final String name;
  final String image;
  final bool fromLegacy;
  final String PageName;

  const FeedActivityPage({
    super.key,
    required this.id,
    required this.name,
    required this.image,
    required this.PageName,
    this.fromLegacy = false,
  });

  @override
  State<FeedActivityPage> createState() => _FeedActivityPageState();
}

class _FeedActivityPageState extends State<FeedActivityPage> {
  late final TrackMilestoneCubit _cubit;
  late final AgeGroupCubit _ageGroupCubit;
  int? _selectedAgeGroupId;

  @override
  void initState() {
    super.initState();
    _cubit = TrackMilestoneCubit();
    _ageGroupCubit = AgeGroupCubit();
  }

  @override
  void dispose() {
    _ageGroupCubit.close();
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _cubit),
        BlocProvider.value(value: _ageGroupCubit),
      ],
      child: Scaffold(
        body: Column(
          children: [
            Container(
              color: Color(AppColor.primaryColor),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 40, left: 8, right: 16),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.black,
                          ),
                          onPressed: () => backTo(context),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Text(
                            widget.name,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  HorizontalSelector(
                    fromLegacy: widget.fromLegacy,
                    onIndexSelected: (ageGroupId) {
                      setState(() {
                        _selectedAgeGroupId = ageGroupId;
                      });
                      final selectedApi = widget.id == 1
                          ? MilestoneApiType.trackMilestone
                          : MilestoneApiType.activityCenter;

                      _cubit.fetchMilestones(ageGroupId, selectedApi);
                      // _cubit.fetchMilestones(ageGroupId);
                    },
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: BlocBuilder<TrackMilestoneCubit, TrackMilestoneState>(
                  builder: (context, state) {
                    if (state is TrackMilestoneLoading) {
                      return const Loader();
                    } else if (state is TrackMilestoneLoaded) {
                      if (state.milestones.isEmpty) {
                        return const Center(
                          child: Text('No milestones found.'),
                        );
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        itemCount: state.milestones.length,
                        itemBuilder: (context, index) {
                          final m = state.milestones[index];
                          return RecipeStepTile(
                            color: CommonMethods.hexToColor(m['color']),
                            title: m['name'] ?? 'No Title',
                            description: m['description'] ?? 'No Description',
                            stepNumber: index + 1,
                          );
                        },
                      );
                    } else if (state is TrackMilestoneError) {
                      return Center(child: Text(state.message));
                    }
                    return SizedBox.shrink();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
