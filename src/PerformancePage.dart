import 'package:drawlite/drawlite.dart'
    show Color, Drawlite, Event, KeyboardEvent, MouseEvent, QuitEvent, DLImage;
import 'package:drawlite/dl.dart';

import 'systeminfo/HardwareInfo.dart';
import 'main.dart';

class PerformancePage {
    Color color;
    String title;

    String subtitle = "";
    String Function(PerformancePage) calcSubtitle;

    List<List<String>> statLabels;
    List<List<String>> statValues = [];
    List<List<String>> Function(PerformancePage) calcStatValues;

    List<String> sideStatLabels;
    List<String> sideStatValues = [];
    List<String> Function(PerformancePage) calcSideStatValues;

    List<double> graphData = [];

    Hardwareinfo info;

    PerformancePage({
        required this.color,
        required this.title,
        required this.info,
        required this.calcSubtitle,
        required this.statLabels,
        required this.calcStatValues,
        required this.sideStatLabels,
        required this.calcSideStatValues
    }) {
        this.graphData = List.filled(60, 0);
    }

    void renderSidebarItem(int y, bool selected) {
        if (selected) {
            noStroke();
            fill(205, 232, 255);
            rect(0, y, sidebarEnd, 70);
        }

        drawGraph(5, y + 5, 72, 59, this.color, this.graphData, false);

        fill(0);
        textAlign(LEFT, BOTTOM);
        textSize(20);
        text(this.title, 84, y + 26);

        textSize(14);
        text(this.subtitle, 84, y + 45);
    }

    void renderPage() {
        final leftEdge = sidebarEnd + 16;
        final pageWidth = (width - (212 + 15 * 2)).toInt();
        final rightEdge = leftEdge + pageWidth;

        fill(0);
        textSize(26);
        textAlign(LEFT, BOTTOM);
        text(this.title, leftEdge, 84);

        textSize(18);
        textAlign(RIGHT, BOTTOM);
        text(this.info.name, rightEdge, 84);

        textSize(14);
        fill(112);
        textAlign(LEFT, BOTTOM);
        text("% Utilization over 60 seconds", leftEdge, 107);
        textAlign(RIGHT, BOTTOM);
        text("100%", rightEdge, 107);

        final baseHeight = height - 12;
        final sideStatsY = baseHeight - 28 - (this.statLabels.length - 1) * 62;

        drawGraph(leftEdge, 110, pageWidth, (sideStatsY - 110 - 27).toInt(), this.color, this.graphData, true);        

        // stat labels
        textSize(15);
        fill(112);
        textAlign(LEFT, BOTTOM);
        for (int y = 0; y < this.statLabels.length; y++) {
            for (int x = 0; x < this.statLabels[y].length; x++) {
                text(this.statLabels[y][x], leftEdge + x * 100, baseHeight - 28 - (this.statLabels.length - y - 1) * 62);
            }
        }

        // stat values
        textSize(22);
        fill(0);
        textAlign(LEFT, BOTTOM);
        for (int y = 0; y < this.statValues.length; y++) {
            for (int x = 0; x < this.statValues[y].length; x++) {
                text(this.statValues[y][x], leftEdge + x * 100, baseHeight - (this.statLabels.length - y - 1) * 62);
            }    
        }

        // side stat labels
        textSize(15);
        fill(112);
        textAlign(LEFT, BOTTOM);
        for (int y = 0; y < this.sideStatLabels.length; y++) {
            text(this.sideStatLabels[y], leftEdge + 300, sideStatsY + y * 22);
        }

        // side stat values
        textSize(15);
        fill(0);
        textAlign(LEFT, BOTTOM);
        for (int y = 0; y < this.sideStatValues.length; y++) {
            text(this.sideStatValues[y], leftEdge + 450, sideStatsY + y * 22);
        }
    }

    void update() {
        this.info.updateDynamicStats();

        var data = this.graphData;
        final len = data.length;
        for (int i = 0; i < len; i++) {
            data[i] = (i + 1 < len) ? data[i + 1] : (this.info.utilization / 100);
        }

        this.subtitle = this.calcSubtitle(this);
        this.statValues = this.calcStatValues(this);
        this.sideStatValues = this.calcSideStatValues(this);
    }
}
