import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tinydroplets/common/widgets/loader.dart';
import 'package:tinydroplets/features/presentation/pages/my_account/profile_completion/profile_completion_cubit.dart';
import 'package:tinydroplets/features/presentation/pages/my_account/profile_page.dart';

import '../../../../../core/constant/app_export.dart';
import '../../../../../core/services/payment_service.dart';

class ProfileCompletionCard extends StatefulWidget {
  const ProfileCompletionCard({super.key});

  @override
  State<ProfileCompletionCard> createState() => _ProfileCompletionCardState();
}

class _ProfileCompletionCardState extends State<ProfileCompletionCard> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileCompletionCubit>().getProfileCompletion();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCompletionCubit, ProfileCompletionState>(
      builder: (context, state) {
        if (state is ProfileCompletionLoading) {
          return const Loader();
        } else if (state is ProfileCompletionLoaded) {
          final percentage = state.percentage;
          CommonMethods.devLog(
            logName: 'Profile completion',
            message: state.percentage,
          );
          if (percentage >= 100) {
            return const SizedBox.shrink();
          }
          final percentDouble = (percentage.clamp(0, 100)) / 100;

          return Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFFFFF7F5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Almost There!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                    const Text(
                      'Please complete your profile',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    const SizedBox(height: 20),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        minHeight: 15,
                        value: percentDouble,
                        backgroundColor: const Color(0xFFFEE5C2),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          const Color(0xFFFF9000),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          goto(context, ProfileScreen());
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.black),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 24,
                          ),
                        ),
                        child: const Text(
                          'Go to Profile',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFFF9000),
                          const Color(0xFFFF9000).withOpacity(0.4),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Text(
                      '$percentage%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        } else if (state is ProfileCompletionError) {
          CommonMethods.devLog(logName: '', message: 'Error: ${state.message}');
          return Center(child: Text('Error: ${state.message}'));
        }
        return const SizedBox.shrink();
      },
    );
  }
}
