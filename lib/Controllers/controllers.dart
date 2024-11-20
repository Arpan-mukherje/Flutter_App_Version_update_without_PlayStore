import 'dart:developer';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

class AppController extends GetxController {
  var currentVersion = '1.0'.obs;
  var latestVersion = ''.obs;
  var downloadUrl = ''.obs;
  var releaseNode = ''.obs;
  var isDownloading = false.obs;
  var downloadProgress = 0.0.obs;
  var isInstalling = false.obs;
  var count = 0.obs;
  @override
  void onInit() {
    super.onInit();
    _checkVersion();
    requestStoragePermission();
  }

  counter() {
    count++;
  }

  Future<void> requestStoragePermission() async {
    if (await Permission.storage.isGranted) {
      log("Storage permission already granted.");
      return;
    }

    final status = await Permission.storage.request();
    if (status.isGranted) {
      log("Storage permission granted.");
    } else if (status.isPermanentlyDenied) {
      log("Storage permission permanently denied. Opening settings...");
      await openAppSettings();
    }
  }

  Future<void> requestInstallPackagesPermission() async {
    if (Platform.isAndroid) {
      if (await Permission.requestInstallPackages.isGranted) {
        log("Install packages permission already granted.");
      } else {
        final status = await Permission.requestInstallPackages.request();
        if (status.isGranted) {
          log("Install packages permission granted.");
        } else {
          log("Install packages permission denied.");
        }
      }
    }
  }

  Future<void> requestInstallUnknownSourcesPermission() async {
    if (Platform.isAndroid &&
        await Permission.requestInstallPackages.isDenied) {
      final packageInfo = await PackageInfo.fromPlatform();
      final intent = AndroidIntent(
        action: 'android.settings.MANAGE_UNKNOWN_APP_SOURCES',
        data: 'package:${packageInfo.packageName}',
      );

      try {
        await intent.launch();
      } catch (e) {
        log('Error opening unknown sources settings: $e');
      }
    }
  }

  Future<void> _checkVersion() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      currentVersion.value = packageInfo.version;

      final response = await Dio().get(
          'https://version-update-project-flutter.vercel.app/versiondata.json');
      latestVersion.value = response.data['version'];
      downloadUrl.value = response.data['apk_url'];
      releaseNode.value = response.data['release_note'];

      if (currentVersion.value != latestVersion.value) {
        showUpdateDialog();
      }
    } catch (e) {
      log('Error checking version: $e');
    }
  }

  void showUpdateDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        backgroundColor: Colors.white,
        title: Text(
          'Update Available',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'A new version (${latestVersion.value}) of the app is available.',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Changes: ${releaseNode.value}.',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actionsPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.grey[300],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            ),
            onPressed: () => Get.back(),
            child: Text(
              'Later',
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.black87,
              ),
            ),
          ),
          SizedBox(
            width: 10.w,
          ),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            ),
            onPressed: () {
              Get.back();
              _downloadAndInstallUpdate();
              requestInstallPackagesPermission();
            },
            child: Text(
              'Update',
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadAndInstallUpdate() async {
    try {
      isDownloading.value = true;

      if (await Permission.storage.request().isGranted) {
        final dir = await getExternalStorageDirectory();
        final filePath = '${dir!.path}/new_version.apk';

        await Dio().download(
          downloadUrl.value,
          filePath,
          onReceiveProgress: (received, total) {
            if (total != -1) {
              downloadProgress.value = (received / total * 100);
            }
          },
        );
        log('APK downloaded at: $filePath');

        isDownloading.value = false;

        await requestInstallUnknownSourcesPermission();
        isInstalling.value = true;

        final result = await OpenFilex.open(filePath);
        log("OpenFile result: ${result.message}");

        isInstalling.value = false;
      } else {
        log('Storage permission denied');
      }
    } catch (e) {
      isDownloading.value = false;
      isInstalling.value = false;
      log('Error downloading or installing update: $e');
    }
  }
}
