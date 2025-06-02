import 'dart:io';
import 'HardwareInfo.dart';
import 'utils.dart';

class DriveInfo extends Hardwareinfo {
    // static info
    

    DriveInfo({
        required super.name
    });

    static Future<List<DriveInfo>> thisDeviceInfo() async {
        await for (final diskName in Directory("/sys/block/").list()) {
            final subpath = diskName.path.substring("/sys/block/".length);
            if (!subpath.startsWith("loop")) {
                print(diskName);
            }
        }
        return [];
    }

    Future<void> updateDynamicStats() async {

    }

    String toString() {
        return """DriveInfo{
    
}""";
    }
}
