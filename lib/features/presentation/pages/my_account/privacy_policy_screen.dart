import '../../../../core/constant/app_export.dart';

class CmsScreen extends StatelessWidget {
  final String title;
  final String description;
  const CmsScreen({super.key, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.bold)),
              SizedBox(
                height: 10,
              ),
              Text(description, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
