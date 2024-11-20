import 'package:basic_app_version1/Controllers/controllers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomePage extends StatelessWidget {
  final AppController appController = Get.put(AppController());

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Version 1 App'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                elevation: 5,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.update, color: Colors.white),
              label: const Text(
                'Check for Update',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              onPressed: () {
                appController.showUpdateDialog();
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Current Version displayed at the top center
          Obx(() => Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Current Version: ${appController.currentVersion.value}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              )),
          const Divider(thickness: 1, indent: 20, endIndent: 20),

          // Remaining content is centered
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Obx(() => Text(
                        "Count : ${appController.count.value.toString()}",
                        style: const TextStyle(fontSize: 24),
                      )),
                  Obx(() {
                    if (appController.isDownloading.value) {
                      return Column(
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 10),
                          Text(
                              'Downloading update... ${appController.downloadProgress.value.toStringAsFixed(0)}%'),
                        ],
                      );
                    }
                    if (appController.isInstalling.value) {
                      return const Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 10),
                          Text('Installing update...'),
                        ],
                      );
                    } else {
                      return Container();
                    }
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          child: const Icon(
            Icons.add,
          ),
          onPressed: () {
            appController.counter();
          }),
    );
  }
}
