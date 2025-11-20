import 'package:tinydroplets/core/constant/app_export.dart';
import 'package:tinydroplets/features/presentation/pages/notification_page/model/notification_model.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<NotificationDataModel> _notificationData = [];
  final DioClient _dioClient = DioClient();

  @override
  void initState() {
    super.initState();
    _fetchAllReview();
  }

  Future<void> _fetchAllReview() async {
    try {
      final response =
          await _dioClient.sendGetRequest(ApiEndpoints.notification);
      CommonMethods.devLog(logName: 'Notification', message: response.data);

      if (response.data['status'] == 1) {
        final data = NotificationModel.fromJson(response.data);
        setState(() {
          _notificationData = data.data;
        });
      }
    } catch (e) {
      if (mounted) {
        CommonMethods.showSnackBar(context, e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Notifications',
            style: TextStyle(fontSize: 20),
          ),
        ),
        body: ListView.builder(
          itemCount: _notificationData.length,
          itemBuilder: (context, index) {
            final notification = _notificationData[index];
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(color: Theme.of(context).cardColor),
                child: Dismissible(
                  key: Key(notification.id.toString()),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) {},
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  child: ListTile(
                    title: Text(notification.title,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(notification.message),
                    trailing: Text(
                      '${notification.createdAt}',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    onTap: () {},
                  ),
                ),
              ),
            );
          },
        ));
  }
}
