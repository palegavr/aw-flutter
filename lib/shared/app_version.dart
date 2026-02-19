
import 'package:package_info_plus/package_info_plus.dart';

String appVersion = '';

Future<void> initAppVersion() async {
  final packageInfo = await PackageInfo.fromPlatform();
  appVersion = packageInfo.version;
}