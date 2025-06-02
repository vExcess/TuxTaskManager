import 'dart:io';

import 'package:drawlite/dl.dart';

import 'PerformancePage.dart';
import 'systeminfo/systeminfo.dart';

Future<List<PerformancePage>> createPerformancePages() async {
    var cacheFile = File("/home/${Platform.environment['USER']}/.tuxtaskmanager/info-cache.txt");
    Map<String, String> cachedInfo = {};
    if (cacheFile.existsSync()) {
        var str = cacheFile.readAsStringSync();
        str.substring(str.indexOf("{") + 1, str.indexOf("}")).trim().split("\n").forEach((line) {
            line = line.trim();
            final idx = line.indexOf(":");
            final key = line.substring(0, idx);
            final val = line.substring(idx + 1).trimLeft();
            cachedInfo[key] = val.substring(0, val.length-1); // remove comma
        });

        // don't used cached info if it's default values
        if (cachedInfo["capacity"] == "0") {
            cachedInfo = {};
        }
    }

    final (res1, res2, res3) = await (
        CPUInfo.thisDeviceInfo(),
        MemoryInfo.thisDeviceInfo(cachedInfo),
        DriveInfo.thisDeviceInfo()
    ).wait;

    return [
        // CPU Page
        PerformancePage(
            colors: [color(17, 125, 187)],
            title: "CPU",
            info: res1,
            calcSubtitle: (PerformancePage that) {
                final info = that.info as CPUInfo;
                return "${info.utilization[0].toInt()}% ${(info.avgClockSpeed / 1000.0).toStringAsFixed(2)} GHz";
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
                    ["${info.utilization[0].toInt()}%", "${(info.avgClockSpeed / 1000.0).toStringAsFixed(2)} / ${(info.maxClockSpeed / 1000.0).toStringAsFixed(2)} GHz"],
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
            },
            calcGraphRightLabel: (PerformancePage that) {
                return "100%";
            }
        ),

        // Memory Page
        PerformancePage(
            graphsDatasLen: 2,
            colors: [color(139, 18, 174), color(246, 97, 81)],
            title: "Memory",
            info: res2,
            calcSubtitle: (PerformancePage that) {
                final info = that.info as MemoryInfo;
                final used = info.size - info.available;
                final swapUsed = info.swapSize - info.swapAvailable;
                return "${formatByteAmount(used).split(" ")[0]}/${formatByteAmount(info.size)} (${info.utilization[0].round()}%)\n${formatByteAmount(swapUsed).split(" ")[0]}/${formatByteAmount(info.swapSize)} (${info.utilization[1].round()}%)";
            },
            statLabels: [
                ["In use", "Available"],
                ["Swap used", "Swap Available"],
                ["Committed", "Cached"],
            ],
            calcStatValues: (PerformancePage that) {
                final info = that.info as MemoryInfo;
                final used = info.size - info.available;
                final swapUsed = info.swapSize - info.swapAvailable;
                return [
                    ["${formatByteAmount(used)}", "${formatByteAmount(info.available)}"],
                    ["${formatByteAmount(swapUsed)}", "${formatByteAmount(info.swapAvailable)}"],
                    ["${formatByteAmount(info.committed)}", "${formatByteAmount(info.cached)}"],
                ];
            },
            sideStatLabels: [
                "Speed:",
                "Slots used:",
                "Form factor:",
                "Hardware reserved:",
            ],
            calcSideStatValues: (PerformancePage that) {
                final info = that.info as MemoryInfo;
                return [
                    info.speed,
                    info.slotsUsed.toString(),
                    info.formFactor.toString(),
                    info.hardwareReserved > 0 ? formatByteAmount(info.hardwareReserved) : "Unknown"
                ];
            },
            calcGraphRightLabel: (PerformancePage that) {
                return "100%";
            }
        ),

        
    ];
}
