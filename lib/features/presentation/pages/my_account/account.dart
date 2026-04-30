import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:tinydroplets/core/constant/app_export.dart';
import 'package:tinydroplets/features/presentation/pages/auth/login_page/login_page.dart';
import 'package:tinydroplets/features/presentation/pages/my_account/profile_page.dart';

class Account extends StatefulWidget {
  const Account({super.key});

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  final DioClient dioClient = GetIt.instance<DioClient>();
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account'), centerTitle: true),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                vertical: 16.0,
                horizontal: 30,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Account Options
                      ListTile(
                        leading: Icon(CupertinoIcons.pencil),
                        title: Text(
                          'Edit Profile',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        onTap: () => goto(context, ProfileScreen()),
                      ),
                      Divider(color: Colors.grey),
                      ListTile(
                        leading: Icon(CupertinoIcons.doc_text),
                        title: Text(
                          'Request Account Info',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        onTap: () {
                          CommonMethods.showSnackBar(
                            context,
                            'Coming soon, don\'t fret',
                          );
                        },
                      ),
                      Divider(color: Colors.grey),
                      const Spacer(), // Push Danger Zone to bottom
                      // 🚨 Danger Zone
                      Text(
                        'Danger Zone',
                        style: TextStyle(
                          color: Colors.red[700],
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.red,
                            style: BorderStyle.solid,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Deleting your account is permanent and cannot be undone. All your data will be lost.',
                              style: TextStyle(color: Colors.red[300]),
                            ),
                            const SizedBox(height: 16),
                            _isDeleting
                                ? const CircularProgressIndicator()
                                : ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red[700],
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    minimumSize: const Size.fromHeight(50),
                                  ),
                                  icon: const Icon(
                                    CupertinoIcons.delete_solid,
                                    color: Colors.white,
                                  ),
                                  label: const Text(
                                    'Delete Account',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                  onPressed:
                                      () => _showDeleteConfirmationDialog(
                                        context,
                                      ),
                                ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder:
          (_) => CupertinoAlertDialog(
            title: const Text('Confirm Deletion'),
            content: const Text(
              'Are you sure you want to delete your account? This action cannot be undone.',
            ),
            actions: [
              CupertinoDialogAction(
                child: const Text('Cancel'),
                onPressed: () => Navigator.pop(context),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                child: const Text('Delete'),
                onPressed: () async {
                  Navigator.pop(context);
                  await deleteAccount();
                  CommonMethods.showSnackBar(
                    context,
                    'Your account has been deleted.',
                  );
                  // TODO: Add real deletion logic here
                },
              ),
            ],
          ),
    );
  }

  Future<void> deleteAccount() async {
    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
    }

    setState(() {
      _isDeleting = true;
    });

    try {
      final response = await dioClient.sendPostRequest(
        ApiEndpoints.deleteAccountUrl,
        {}, // You can include auth tokens or other data if required by backend
      );

      CommonMethods.devLog(
        logName: 'Delete Account Response',
        message: response,
      );

      if (response.data['status'] == 1) {
        if (mounted) {
          CommonMethods.showSnackBar(context, 'Account deleted successfully');

          // Clear stored user data
          await SharedPref.clear();
          setState(() => _isDeleting = false);

          // Navigate to login or onboarding screen
          gotoRemoveAll(context, const LoginPage());
        }
      } else {
        if (mounted) {
          CommonMethods.showSnackBar(context, response.data['message']);
          setState(() => _isDeleting = false);
        }
      }
    } catch (e) {
      if (mounted) {
        CommonMethods.showSnackBar(context, e.toString());
        CommonMethods.devLog(logName: 'Delete Error', message: e.toString());
        setState(() => _isDeleting = false);
      }
    }
  }
}
