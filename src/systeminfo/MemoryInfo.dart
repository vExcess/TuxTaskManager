import 'dart:io';
import 'package:drawlite/dl.dart';

import 'HardwareInfo.dart';
import 'utils.dart';

class RAMStickInfo {
    int size;
    String type;
    int baseSpeed;
    int speed;
    String manufacturer;
    String partName;

    RAMStickInfo({
        required this.size,
        required this.type,
        required this.baseSpeed,
        required this.speed,
        required this.manufacturer,
        required this.partName,
    });

    String toString() {
        return """RAMStickInfo{
    size: ${this.size},
    type: ${this.type},
    baseSpeed: ${this.baseSpeed},
    speed: ${this.speed},
    manufacturer: ${this.manufacturer},
    partName: ${this.partName},
}""";
    }
}

class MemoryInfo extends Hardwareinfo {
    // static info
    String speed;
    int capacity;
    int slotsUsed;
    String formFactor;
    int hardwareReserved;
    int size;
    int swapSize;
    
    // dynamic info
    int available;
    int swapAvailable;
    int committed;
    int cached;

    MemoryInfo({
        required super.name,
        required this.speed,
        required this.capacity,
        required this.slotsUsed,
        required this.formFactor,
        required this.hardwareReserved,
        required this.size,
        required this.swapSize,
        required this.available,
        required this.swapAvailable,
        required this.committed,
        required this.cached,
    }) {
        // main, swap
        this.utilization = [0.0, 0.0];
    }

    static Future<MemoryInfo> thisDeviceInfo(Map<String, String> cachedInfo) async {
        MemoryInfo lookupInfo = MemoryInfo(
            name: cachedInfo["name"] ?? "Unknown RAM",
            speed: cachedInfo["speed"] ?? "Unknown",
            capacity: int.parse(cachedInfo["capacity"] ?? "0"),
            slotsUsed: int.parse(cachedInfo["slotsUsed"] ?? "0"),
            formFactor: cachedInfo["formFactor"] ?? "Unknown",
            hardwareReserved: int.parse(cachedInfo["hardwareReserved"] ?? "0"),
            size: 0,
            swapSize: 0,
            available: 0,
            swapAvailable: 0,
            committed: 0,
            cached: 0,
        );

        if (cachedInfo.isEmpty) {
            final res = await Process.run("pkexec", ["dmidecode", "--type", "17"]);
            if (!res.stderr.startsWith("Error")) {
                List<RAMStickInfo> ramSticks = [];
                res.stdout.split("\n\n").forEach((String str) {
                    final lines = str.trim().split("\n");
                    if (lines.length >= 2 && lines[1] == "Memory Device") {
                        int size = 0;
                        String type = "DDR";
                        int baseSpeed = 0;
                        int speed = 0;
                        String manufacturer = "Unknown Manufacturer";
                        String partName = "Unknown RAM";
                        for (int i = 2; i < lines.length; i++) {
                            final row = lines[i].trimLeft();
                            var idx = row.indexOf(":");
                            if (idx != -1) {
                                final key = row.substring(0, idx);
                                final val = row.substring(idx + 1).trimLeft();
                                if (key == "Size") {
                                    size = parseByteAmountString(val);
                                } else if (key == "Type") {
                                    type = val;
                                } else if (key == "Speed") {
                                    baseSpeed = int.parse(val.substring(0, val.indexOf(" ")));
                                } else if (key == "Configured Memory Speed") {
                                    speed = int.parse(val.substring(0, val.indexOf(" ")));
                                } else if (key == "Manufacturer") {
                                    manufacturer = val.trim();
                                } else if (key == "Part Number") {
                                    partName = val.trim();
                                } else if (key == "Form Factor") {
                                    lookupInfo.formFactor =  val.trim();
                                }
                            }
                        }
                        
                        lookupInfo.capacity += size;
                        lookupInfo.speed = "${speed} MT/s";
                        
                        ramSticks.add(RAMStickInfo(
                            size: size,
                            type: type,
                            baseSpeed: baseSpeed,
                            speed: speed,
                            manufacturer: manufacturer,
                            partName: partName,
                        ));
                    }
                });

                lookupInfo.slotsUsed = ramSticks.length;

                if (ramSticks.isNotEmpty) {
                    final stick0 = ramSticks[0];
                    var allSameName = true;
                    for (int i = 1; i < ramSticks.length; i++) {
                        if (
                            ramSticks[i].manufacturer != ramSticks[i-1].manufacturer ||
                            ramSticks[i].partName != ramSticks[i-1].partName
                        ) {
                            allSameName = false;
                            break;
                        }
                    }
                    var name = "${formatByteAmount(lookupInfo.capacity, 0)} ${stick0.type}-${stick0.speed}";
                    if (allSameName) {
                        lookupInfo.name = "${name} (${stick0.manufacturer} ${stick0.partName})";
                    } else {
                        lookupInfo.name = "${name} (Assorted RAM)";
                    }
                }
            }
        }

        await lookupInfo.updateDynamicStats();

        return lookupInfo;
    }

    Future<void> updateDynamicStats() async {
        final memInfoFile = File("/proc/meminfo");
        final contents = await memInfoFile.readAsString();
        contents.split("\n").forEach((row) {
            var idx = row.indexOf(":");
            if (idx != -1) {
                final key = row.substring(0, idx);
                final val = row.substring(idx + 1).trimLeft();
                if (key == "MemTotal") {
                    this.size = parseByteAmountString(val);
                } else if (key == "SwapTotal") {
                    this.swapSize = parseByteAmountString(val);
                } else if (key == "MemAvailable") {
                    this.available = parseByteAmountString(val);
                } else if (key == "SwapFree") {
                    this.swapAvailable = parseByteAmountString(val);
                } else if (key == "Committed_AS") {
                    this.committed = parseByteAmountString(val);
                } else if (key == "Cached") {
                    this.cached = parseByteAmountString(val);
                }                
            }
        });

        this.utilization[0] = (this.size - this.available) / this.size * 100;
        this.utilization[1] = (this.swapSize - this.swapAvailable) / this.swapSize * 100;
        this.hardwareReserved = this.capacity - this.size;
    }

    String toString() {
        return """MemoryInfo{
    name: ${this.name},
    speed: ${this.speed},
    capacity: ${this.capacity},
    slotsUsed: ${this.slotsUsed},
    formFactor: ${this.formFactor},
    hardwareReserved: ${this.hardwareReserved},
    size: ${this.size},
    swapSize: ${this.swapSize},
    available: ${this.available},
    swapAvailable: ${this.swapAvailable},
    committed: ${this.committed},
    cached: ${this.cached},
}""";
    }
}
