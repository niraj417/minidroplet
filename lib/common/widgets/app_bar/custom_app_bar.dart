import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tinydroplets/core/constant/app_export.dart';
import 'package:tinydroplets/features/presentation/pages/notification_page/notification_page.dart';

import '../../../features/presentation/pages/dashboard/dashboard_bloc/dashboard_bloc.dart';
import '../../../features/presentation/pages/dashboard/dashboard_bloc/dashboard_event.dart';
import '../../../features/presentation/pages/my_account/profile_bloc/profile_cubit.dart';
import '../../../features/presentation/pages/my_account/profile_bloc/profile_state.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  String? subtitle;

  CustomAppBar({super.key, required this.title,this.subtitle});

  @override
  Widget build(BuildContext context) {

    return AppBar(
      title: subtitle == null ?
        Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ) : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            subtitle!,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.normal,
            ),
          )
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications),
          onPressed: () => goto(context, NotificationPage()),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
            child: InkWell(
              onTap: () {
                context.read<DashboardBloc>().add(NavigateToIndex(3));
              },
              child:    BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, state) {
                  return Container(
                    padding: EdgeInsets.all(1.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Color(AppColor.primaryColor), width: 1),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      height: 30,
                      width: 30,
                      clipBehavior: Clip.hardEdge,
                      child: CustomImage(
                        imageUrl: state.image,
                        fit: BoxFit.fill,
                      ),
                    ),
                  );
                }
              ),
            ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
