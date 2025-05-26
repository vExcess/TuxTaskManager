import 'package:drawlite/dl.dart';

import 'PerformancePage.dart';
import 'systeminfo/systeminfo.dart';

Future<List<PerformancePage>> createPerformancePages() async {
    return [
        // CPU Page
        PerformancePage(
            color: color(17, 125, 187),
            title: "CPU",
            info: await CPUInfo.thisDeviceInfo(),
            calcSubtitle: (PerformancePage that) {
                final info = that.info as CPUInfo;
                return "${info.utilization.toInt()}% ${(info.avgClockSpeed / 1000.0).toStringAsFixed(2)} GHz";
            },
            statLabels: [
                ["Utilization", "Speed (Avg/Top)"],
                ["Processes", "Threads", "Handles"],
                ["Uptime"],
            ],
            calcStatValues: (PerformancePage that) {
                final info = that.info as CPUInfo;
                final up = info.uptime;
                final days =    ((up / 60 / 60 / 24)).toInt().toString();
                final hours =   ((up / 60 / 60) % 24).toInt().toString().padLeft(2, "0");
                final minutes = ((up / 60) % 60).toInt().toString().padLeft(2, "0");
                final seconds = ((up % 60)).toInt().toString().padLeft(2, "0");
                return [
                    ["${info.utilization.toInt()}%", "${(info.avgClockSpeed / 1000.0).toStringAsFixed(2)} / ${(info.maxClockSpeed / 1000.0).toStringAsFixed(2)} GHz"],
                    ["${info.runningProcessCount}", "${info.runningThreadCount}", "${info.handlesCount}"],
                    ["${days}:${hours}:${minutes}:${seconds}"],
                ];
            },
            sideStatLabels: [
                "Base speed:",
                "Sockets:",
                "Cores:",
                "Logical processors:",
                "Virtualization:",
                "L1 cache:",
                "L2 cache:",
                "L3 cache:",
            ],
            calcSideStatValues: (PerformancePage that) {
                final info = that.info as CPUInfo;
                final l1Txt = info.l1CacheParenText;
                final l2Txt = info.l2CacheParenText;
                final l3Txt = info.l3CacheParenText;
                return [
                    info.baseClock,
                    "1",
                    info.coreCount.toString(),
                    info.threadCount.toString(),
                    info.virtualization ? "Enabled" : "Disabled",
                    "${formatByteAmount(info.l1Cache, 0)} ${l1Txt.isNotEmpty ? "(${l1Txt})" : ""}",
                    "${formatByteAmount(info.l2Cache, 0)} ${l2Txt.isNotEmpty ? "(${l2Txt})" : ""}",
                    "${formatByteAmount(info.l3Cache, 0)} ${l3Txt.isNotEmpty ? "(${l3Txt})" : ""}",
                ];
            }
        ),

        // Memory Page
        PerformancePage(
            color: color(139, 18, 174),
            title: "Memory",
            info: await Memoryinfo.thisDeviceInfo(),
            calcSubtitle: (PerformancePage that) {
                final info = that.info as Memoryinfo;
                final used = info.size - info.available;
                return "${formatByteAmount(used).split(" ")[0]}/${formatByteAmount(info.size)} (${(info.utilization).round()}%)";
            },
            statLabels: [
                ["In use", "Available"],
                ["Committed", "Cached"],
                // ["Uptime"],
            ],
            calcStatValues: (PerformancePage that) {
                final info = that.info as Memoryinfo;
                final used = info.size - info.available;
                return [
                    ["${formatByteAmount(used)}", "${formatByteAmount(info.available)}"],
                    ["${formatByteAmount(info.committed)}", "${formatByteAmount(info.cached)}"],
                    // ["${days}:${hours}:${minutes}:${seconds}"],
                ];
            },
            sideStatLabels: [
                "Speed:",
                "Slots used:",
                "Form factor:",
                "Hardware reserved:",
            ],
            calcSideStatValues: (PerformancePage that) {
                final info = that.info as Memoryinfo;
                return [
                    info.speed,
                    info.slotsUsed.toString(),
                    info.slotCapacity.toString(),
                    info.hardwareReserved.toString()
                ];
            }
        )
    ];
}
