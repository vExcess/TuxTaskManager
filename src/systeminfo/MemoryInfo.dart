import 'dart:io';
import 'HardwareInfo.dart';
import 'utils.dart';

class Memoryinfo extends Hardwareinfo {
    // static info
    String speed;
    int capacity;
    int slotsUsed;
    int slotCapacity;
    String formFactor;
    int hardwareReserved;
    int size;
    int swapSize;
    
    // dynamic info
    int available;
    int swapAvailable;
    int committed;
    int cached;

    Memoryinfo({
        required super.name,
        required this.speed,
        required this.capacity,
        required this.slotsUsed,
        required this.slotCapacity,
        required this.formFactor,
        required this.hardwareReserved,
        required this.size,
        required this.swapSize,
        required this.available,
        required this.swapAvailable,
        required this.committed,
        required this.cached,
    });

    static Future<Memoryinfo> thisDeviceInfo() async {
        Memoryinfo lookupInfo = Memoryinfo(
            name: "Unknown RAM",
            speed: "",
            capacity: 0,
            slotsUsed: 0,
            slotCapacity: 0,
            formFactor: "",
            hardwareReserved: 0,
            size: 0,
            swapSize: 0,
            available: 0,
            swapAvailable: 0,
            committed: 0,
            cached: 0,
        );

        lookupInfo.updateDynamicStats();

        return lookupInfo;
    }

    Future<void> updateDynamicStats() async {
        var memInfoFile = File("/proc/meminfo");
        memInfoFile.readAsStringSync().split("\n").forEach((row) {
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

        this.utilization = (this.size - this.available) / this.size * 100;
    }

    String toString() {
        return """Memoryinfo(
    name: ${this.name},
    speed: ${this.speed},
    capacity: ${this.capacity},
    slotsUsed: ${this.slotsUsed},
    slotCapacity: ${this.slotCapacity},
    formFactor: ${this.formFactor},
    hardwareReserved: ${this.hardwareReserved},
    size: ${this.size},
    swapSize: ${this.swapSize},
    available: ${this.available},
    swapAvailable: ${this.swapAvailable},
    committed: ${this.committed},
    cached: ${this.cached},
)""";
    }
}
