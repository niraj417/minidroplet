import 'package:tinydroplets/common/widgets/loader.dart';
import 'package:tinydroplets/core/constant/app_export.dart';
import 'package:dio/dio.dart';
import 'package:tinydroplets/core/utils/url_opener.dart';

class SocialLinksScroll extends StatefulWidget {
  const SocialLinksScroll({super.key});

  @override
  SocialLinksScrollState createState() => SocialLinksScrollState();
}

class SocialLinksScrollState extends State<SocialLinksScroll> {
  final DioClient _dioClient = DioClient();
  Future<List<Map<String, dynamic>>> fetchSocialLinks() async {
    try {
      final response = await _dioClient.sendGetRequest(
        ApiEndpoints.socialLinks,
      );
      if (response.data['status'] == 1) {
        return List<Map<String, dynamic>>.from(response.data['data']);
      }
    } catch (e) {
      debugPrint('Error fetching social links: $e');
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchSocialLinks(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Loader();
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final socialLinks = snapshot.data!;
        double itemWidth =
            MediaQuery.of(context).size.width / socialLinks.length;

        return SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: socialLinks.length,
            itemBuilder: (context, index) {
              final link = socialLinks[index];
              return GestureDetector(
                onTap: () => UrlOpener.launchURL(link['link']),
                child: Column(
                  children: [
                    Container(
                      clipBehavior: Clip.hardEdge,
                      width: itemWidth - 30,
                      height: 40,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        //  color: Colors.grey[200],
                      ),
                      child: CustomImage(
                        imageUrl: link['image'],
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      link['name'],
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        // fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
