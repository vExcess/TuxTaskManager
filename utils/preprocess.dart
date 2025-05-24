import 'dart:io';
import 'dart:convert';

List<List<String>> parseCSV(String csv) {
    return csv.split("\n").map((row) {
        List<String> rowItems = [];
        int i = 0;
        while (i < row.length) {
            if (row[i] == '"') {
                final start = i++;
                while (row[i] != '"' && i < row.length) {
                    i++;
                }
                final end = i++;
                final str = row.substring(start + 1, end);
                rowItems.add(str);
            } else {
                final start = i;
                while (row[i] != ',' && i < row.length) {
                    i++;
                }
                final end = i;
                final str = row.substring(start, end);
                rowItems.add(str);
            }
            i++;
        }
        return rowItems;
    }).toList();
}

double freqFromString(String freq) {
    freq = freq.toLowerCase();
    double multiplier = 1;
    if (!freq.contains("ghz")) {
        multiplier = 1/1000;
    }
    return double.parse(freq.replaceFirst("ghz", "").replaceFirst("mhz", "").trim()) * multiplier;
}

String stringFromFreq(double freq) {
    final str = freq.toString();
    final idx = str.indexOf("00");
    return str.substring(0, idx == -1 ? str.length : idx);
}

void main() {
    // AMD CPU Info: https://www.amd.com/en/products/specifications/processors.html
    var AMDCPUData = parseCSV(File("utils/Processor Specifications.csv").readAsStringSync().replaceAll(String.fromCharCode(8203), ""));
    final properties = AMDCPUData[0].map((label) { return label.toLowerCase().trim(); }).toList();
    int getPropIdx(String prop) {
        return properties.indexOf(prop);
    }
    var AMDCPUDataString = "";
    for (int i = 1; i < AMDCPUData.length; i++) {
        final row = AMDCPUData[i];
        var name = row[getPropIdx("name")].replaceFirst("(OEM Only)", "");
        var idx = name.indexOf("with");
        name = name.substring(0, idx == -1 ? name.length : idx).trim();
        final coreCountString = row[getPropIdx("# of cpu cores")];
        var coreCount = coreCountString.trim().isNotEmpty ? int.parse(coreCountString) : 0;
        if (coreCount == 0) {
            print("Lacking Info: ${name}");
        }
        final threadCountString = row[getPropIdx("# of threads")];
        final threadCount = threadCountString.isEmpty ? coreCount : int.parse(threadCountString);
        final baseClock = row[getPropIdx("base clock")].replaceAll(" ", "").toUpperCase();
        final boostClock = row[getPropIdx("max. boost clock")].replaceFirst("Up to", "").replaceAll(" ", "").toUpperCase();
        final l1Cache = row[getPropIdx("l1 cache")].trim();
        final l2Cache = row[getPropIdx("l2 cache")].trim();
        final l3Cache = row[getPropIdx("l3 cache")].trim();
        final tdp = row[getPropIdx("default tdp")].toLowerCase().replaceFirst("watts", "").replaceFirst("watt", "").replaceFirst("w", "").replaceFirst("+", "").trim();
        final iGPUName = row[getPropIdx("graphics model")].trim();
        final iGPUCoreCount = row[getPropIdx("graphics core count")].trim();
        final iGPUClock = row[getPropIdx("graphics frequency")].replaceAll(" ", "").toUpperCase();
        final storeString = "[${json.encode(name)},${coreCount},${threadCount},${json.encode(baseClock)},${json.encode(boostClock)},${json.encode(l1Cache)},${json.encode(l2Cache)},${json.encode(l3Cache)},${tdp.isNotEmpty ? tdp : 0},${(iGPUName.isNotEmpty && !iGPUName.contains("Discrete")) ? json.encode(iGPUName) : '""'},${iGPUCoreCount.isNotEmpty ? iGPUCoreCount : 0},${json.encode(iGPUClock)}],\n";
        AMDCPUDataString += storeString;
    }

    print("[\n${AMDCPUDataString.replaceAll(String.fromCharCode(8482), "")}]");
    
}
