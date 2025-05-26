bool isNumber(int chCode) {
    return chCode >= 48 && chCode <= 57;
}

String noZeroesToFixed(double num, [int decimalPlaces=4]) {
    var str = num.toStringAsFixed(decimalPlaces);
    final idx = str.indexOf("00");
    str = str.substring(0, idx == -1 ? str.length : idx);
    return str;
}

int parseByteAmountString(String str) {
    str = str.trimLeft();
    if (str.isNotEmpty) {
        var i = 0;
        while (i < str.length && isNumber(str.codeUnitAt(i))) {
            i++;
        }
        final val = int.parse(str.substring(0, i));
        final scaler = str.substring(i).trimLeft();
        var multiplier = 1;
        if (scaler.startsWith("kB")) {
            multiplier = 1024;
        } else if (scaler.startsWith("MB")) {
            multiplier = 1024 * 1024;
        } else if (scaler.startsWith("KiB")) {
            multiplier = 1024;
        } else if (scaler.startsWith("MiB")) {
            multiplier = 1024 * 1024;
        } else if (scaler.startsWith("GiB")) {
            multiplier = 1024 * 1024 * 1024;
        } else {
            throw "unknown byte scaler: ${scaler}";
        }
        return val * multiplier;
    }
    return 0;
}

String formatByteAmount(int byteCount, [int decimalPlaces=1]) {
    double bytes = byteCount.toDouble();
    String modifier = "bytes";
    if (bytes >= 1024) {
        bytes /= 1024;
        modifier = "KB";
    }
    if (bytes >= 1024) {
        bytes /= 1024;
        modifier = "MB";
    }
    if (bytes >= 1024) {
        bytes /= 1024;
        modifier = "GB";
    }
    return "${noZeroesToFixed(bytes, decimalPlaces)} ${modifier}";
}

