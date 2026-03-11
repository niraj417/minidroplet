import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tinydroplets/core/constant/app_export.dart';
import 'package:tinydroplets/features/presentation/pages/my_account/model/order_history_model.dart';

abstract class OrderListState {}

class OrderListInitial extends OrderListState {}

class OrderListLoading extends OrderListState {}

class OrderListLoaded extends OrderListState {
  final List<Ebook> ebooks;
  final List<Ebook> videos;
  final List<Ebook> playlists;

  OrderListLoaded({
    required this.ebooks,
    required this.videos,
    required this.playlists,
  });
}

class OrderListError extends OrderListState {
  final String message;

  OrderListError({required this.message});
}

class DownloadingPdf extends OrderListState {
  final OrderListState currentState;

  DownloadingPdf({required this.currentState});
}

class DownloadProgress extends OrderListState {
  final double progress;
  final OrderListState currentState;

  DownloadProgress({required this.progress, required this.currentState});
}

class DownloadError extends OrderListState {
  final String message;
  final OrderListState currentState;

  DownloadError({required this.message, required this.currentState});
}

// New state for permission handling
class PermissionRequired extends OrderListState {
  final OrderListState currentState;
  final String url;
  final String fileName;

  PermissionRequired({
    required this.currentState,
    required this.url,
    required this.fileName,
  });
}

class OrderListCubit extends Cubit<OrderListState> {
  final DioClient _dioClient = DioClient();

  OrderListCubit() : super(OrderListInitial());

  Future<void> fetchOrderHistory() async {
    emit(OrderListLoading());
    try {
      final response = await _dioClient.sendGetRequest(
        ApiEndpoints.orderHistory,
      );

      if (response.data['status'] == 1) {
        final orderHistoryModel = OrderHistoryModel.fromJson(response.data);

        if (orderHistoryModel.data != null) {
          emit(
            OrderListLoaded(
              ebooks: orderHistoryModel.data!.ebook,
              videos: orderHistoryModel.data!.video,
              playlists: orderHistoryModel.data!.playlist,
            ),
          );
        } else {
          emit(OrderListError(message: 'No data available'));
        }
      } else {
        emit(
          OrderListError(
            message: response.data['message'] ?? 'Failed to load orders',
          ),
        );
      }
    } catch (e, stackTrace) {
      emit(OrderListError(message: e.toString()));
    }
  }

  Future<void> downloadPdf(
    String url,
    String fileName,
    BuildContext context,
  ) async {
    if (url.isEmpty) {
      CommonMethods.showSnackBar(context, 'No PDF available for download');
      return;
    }

    // Request permission based on platform and version
    // bool hasPermission = await _checkStoragePermission(context);
    // if (!hasPermission) return;

    try {
      // Use external/app-specific directory
      Directory baseDir;
      if (Platform.isAndroid) {
        baseDir = (await getExternalStorageDirectory())!;
      } else {
        baseDir = await getApplicationDocumentsDirectory();
      }

      final savePath = baseDir.path;

      await FlutterDownloader.enqueue(
        url: url,
        savedDir: savePath,
        fileName: "$fileName.pdf",
        showNotification: true,
        openFileFromNotification: true,
      );

      CommonMethods.showSnackBar(context, 'Download started for $fileName.pdf');
      // Restore state after successful download
      if (state is DownloadProgress) {
        final currentState = (state as DownloadProgress).currentState;
        emit(
          currentState is OrderListLoaded
              ? currentState
              : await _refreshCurrentState(),
        );
      }

      CommonMethods.showSnackBar(context, 'Downloaded $fileName successfully');
    } catch (e) {
      CommonMethods.showSnackBar(context, 'Download failed: $e');
    }
  }

  Future<bool> _checkStoragePermission(BuildContext context) async {
    if (Platform.isIOS) {
      return true; // No explicit permission required
    }

    // Android 13+ recommends media access or manageExternalStorage
    if (await Permission.manageExternalStorage.request().isGranted) {
      return true;
    }

    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Storage Permission Needed'),
            content: const Text(
              'We need permission to save your file. Please grant it in settings.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Open Settings'),
              ),
            ],
          ),
    );

    if (result == true) {
      await openAppSettings();
    }

    return false;
  }

  Future<OrderListState> _refreshCurrentState() async {
    try {
      final response = await _dioClient.sendGetRequest(
        ApiEndpoints.orderHistory,
      );
      if (response.data['status'] == 1) {
        final orderHistoryModel = OrderHistoryModel.fromJson(response.data);
        if (orderHistoryModel.data != null) {
          return OrderListLoaded(
            ebooks: orderHistoryModel.data!.ebook,
            videos: orderHistoryModel.data!.video,
            playlists: orderHistoryModel.data!.playlist,
          );
        } else {
          return OrderListError(message: 'No data available');
        }
      } else {
        return OrderListError(
          message: response.data['message'] ?? 'Failed to load orders',
        );
      }
    } catch (e) {
      return OrderListError(message: e.toString());
    }
  }
}
