import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tinydroplets/common/widgets/loader.dart';
import 'package:tinydroplets/core/constant/app_export.dart';
import 'package:tinydroplets/core/utils/url_opener.dart';
import 'package:tinydroplets/features/presentation/pages/feed_page/widget/horizontal_selecter_widget.dart';

import 'bloc/affiliate_bloc/affiliate_cubit.dart';

class FeedAffiliatePage extends StatefulWidget {
  final int id;
  final String name;
  final String image;
  const FeedAffiliatePage({
    super.key,
    required this.id,
    required this.name,
    required this.image,
  });

  @override
  State<FeedAffiliatePage> createState() => _FeedAffiliatePageState();
}

class _FeedAffiliatePageState extends State<FeedAffiliatePage> {
  @override
  void initState() {
    super.initState();
    context.read<AffiliateCubit>().fetchAffiliateLinks(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: () => backTo(context),
                      ),

                      SizedBox(width: 20),
                      Expanded(
                        child: Text(
                          widget.name,
                          style: TextStyle(
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
                  fromLegacy: true,
                  onIndexSelected: (value) {
                    context.read<AffiliateCubit>().fetchAffiliateLinks(value);
                  },
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
      /*
          Expanded(
            child: BlocBuilder<AffiliateCubit, AffiliateState>(
              builder: (context, state) {
                if (state is AffiliateLoading) {
                  return Loader();
                } else if (state is AffiliateLoaded) {
                  final affiliateLinks = state.links;
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.8,
                          ),
                      itemCount: affiliateLinks.length,
                      itemBuilder: (context, index) {
                        final item = affiliateLinks[index];
                        return Card(
                          color: Theme.of(context).cardColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                                child: CustomImage(
                                  imageUrl: item['image'] ?? DummyData.avatarUrl,
                                  // imageUrl: item['image'] ?? DummyData.avatarUrl,
                                  height: 120,
                                  width: MediaQuery.of(context).size.width,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Text(
                                      item['name']!,
                                      style: Theme.of(context).textTheme.titleMedium,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 8),
                                    // Constrained button that adapts to available width
                                    ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxWidth: MediaQuery.of(context).size.width * 0.4, // Adjust this value as needed
                                      ),
                                      child: SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            UrlOpener.launchURL(item['link']);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            padding: const EdgeInsets.symmetric(horizontal: 8),
                                          ),
                                          child: const FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text('Buy Now'),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  );
                } else if (state is AffiliateError) {
                  return Center(child: Text(state.message));
                }
                return Center(child: Text('No data'));
              },
            ),
          ),*/
          Expanded(
            child: BlocBuilder<AffiliateCubit, AffiliateState>(
              builder: (context, state) {
                if (state is AffiliateLoading) {
                  return Loader();
                } else if (state is AffiliateLoaded) {
                  final affiliateLinks = state.links;
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      // Mobile-first responsive design
                      double screenWidth = constraints.maxWidth;
                      int crossAxisCount;
                      double childAspectRatio;
                      double fontSize;
                      double buttonHeight;

                      if (screenWidth <= 360) {
                        // Small phones (iPhone SE, small Android)
                        crossAxisCount = 2;
                        childAspectRatio = 0.8;
                        fontSize = 11;
                        buttonHeight = 28;
                      } else if (screenWidth <= 400) {
                        // Regular phones
                        crossAxisCount = 2;
                        childAspectRatio = 0.82;
                        fontSize = 12;
                        buttonHeight = 30;
                      } else if (screenWidth <= 500) {
                        // Large phones
                        crossAxisCount = 2;
                        childAspectRatio = 0.85;
                        fontSize = 13;
                        buttonHeight = 32;
                      } else if (screenWidth <= 700) {
                        // Small tablets
                        crossAxisCount = 3;
                        childAspectRatio = 0.8;
                        fontSize = 13;
                        buttonHeight = 32;
                      } else {
                        // Large tablets
                        crossAxisCount = 3;
                        childAspectRatio = 0.85;
                        fontSize = 14;
                        buttonHeight = 34;
                      }

                      return Padding(
                        padding: EdgeInsets.all(screenWidth <= 360 ? 6.0 : 8.0),
                        child: GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: screenWidth <= 360 ? 6 : 8,
                            mainAxisSpacing: screenWidth <= 360 ? 6 : 8,
                            childAspectRatio: childAspectRatio,
                          ),
                          itemCount: affiliateLinks.length,
                          itemBuilder: (context, index) {
                            final item = affiliateLinks[index];
                            return LayoutBuilder(
                              builder: (context, cardConstraints) {
                                return Card(
                                  color: Theme.of(context).cardColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 4,
                                  child: Column(
                                    children: [
                                      // Image section
                                      Expanded(
                                        flex: 6,
                                        child: ClipRRect(
                                          borderRadius: const BorderRadius.vertical(
                                            top: Radius.circular(12),
                                          ),
                                          child: CustomImage(
                                            imageUrl: item['image'] ?? DummyData.avatarUrl,
                                            height: cardConstraints.maxHeight * 0.6,
                                            width: cardConstraints.maxWidth,
                                          ),
                                        ),
                                      ),
                                      // Content section
                                      Expanded(
                                        flex: 4,
                                        child: Padding(
                                          padding: EdgeInsets.all(screenWidth <= 360 ? 6.0 : 8.0),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              // Title
                                              Expanded(
                                                child: Center(
                                                  child: Text(
                                                    item['name']!,
                                                    style: TextStyle(
                                                      fontSize: fontSize,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                              // Button
                                              Container(
                                                width: double.infinity,
                                                height: buttonHeight,
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    UrlOpener.launchURL(item['link']);
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(6),
                                                    ),
                                                    padding: EdgeInsets.symmetric(
                                                      horizontal: screenWidth <= 360 ? 2 : 4,
                                                    ),
                                                  ),
                                                  child: FittedBox(
                                                    fit: BoxFit.scaleDown,
                                                    child: Text(
                                                      'Buy Now',
                                                      style: TextStyle(
                                                        fontSize: fontSize - 1,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      );
                    },
                  );
                } else if (state is AffiliateError) {
                  return Center(child: Text(state.message));
                }
                return const Center(child: Text('No data'));
              },
            ),
          )

        ],
      ),
    );
  }
}
