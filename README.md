# Flutter_App_Version_update_without_PlayStore



Project Overview
This project consists of two Flutter applications (Version 1 App and Version 2 App) designed
to showcase a version update mechanism. The process involves checking for a newer version
using a remote JSON file, notifying the user, downloading the new version, and installing it
without relying on the Google Play Store.
Components
1. Version 1 App: The initial application, featuring a basic UI with version-check
2. 3. functionality.
Version 2 App: An updated application with new features, reflecting the next version of
the project.
Remote JSON File: Deployed to Vercel, containing metadata like version number, APK
download link, and release notes.
How Requirements Were Met :
1. Version Detection and Notification
● In Version 1 App, a mechanism is implemented to check for newer versions:
○ The app retrieves the current version using the “ PackageInfo ” package.
○ It fetches metadata from a remote JSON file hosted on Vercel.
○ If the JSON version (2.0.0) is newer than the current version, a dialog prompts
the user about the update.
○ The dialog contains "Update" and "Later" buttons, offering a choice for immediate
or postponed updates.
2. JSON File Deployment and Content
{
"version": "2.0.0"
,
"apk
_
url": "https://version-update-project-flutter.vercel.app/app-release.apk"
,
"release
_
colorful UI"
note": "Reset button, count increase, count decrease button added with
}
This JSON file is deployed on Vercel to make it accessible via URL. The file includes:
○ version: Version number of the new release.
○ apk
_
○ release
url: Direct link to the APK file for download.
_
note: Summary of the new features or changes.
3, APK Download and Installation Process
● If an update is detected, the app requests storage permissions using the
“ permission_handler ” package.
● The new APK is downloaded to a local directory using “ Dio”
.
● Once downloaded, the APK is opened using “OpenFilex”
, initiating the installation
process.
● For devices requiring additional permissions to install APKs from unknown sources, the
app uses “AndroidIntent” to guide users to the settings page.
4. Feature Enhancements in Version 2
● Version 2 App introduces a new colorful UI with counter functionalities:
○ Features include buttons to increment, decrement, and reset a counter.
○ The UI clearly displays the new version (2.0.0), fulfilling the updated user
requirements.
○ A more engaging visual layout is introduced using color-coded buttons.
Conclusion
The project successfully implements a version management solution without using the Google
Play Store, demonstrating a flexible and user-friendly approach to handling app updates. The
JSON-based versioning mechanism, combined with permission handling and APK installation
features, ensures that users are seamlessly guided through the update process.
