import 'dart:math' as Math;

import 'package:drawlite/drawlite.dart'
    show Color, Drawlite, Event, KeyboardEvent, MouseEvent, QuitEvent, DLImage;
import 'package:drawlite/dl.dart';

import 'systeminfo/HardwareInfo.dart';
import 'main.dart';

class PerformancePage {
    String title;

    String subtitle = "";
    String Function(PerformancePage) calcSubtitle;

    String graphRightLabel = "";
    String Function(PerformancePage) calcGraphRightLabel;

    List<List<String>> statLabels;
    List<List<String>> statValues = [];
    List<List<String>> Function(PerformancePage) calcStatValues;

    List<String> sideStatLabels;
    List<String> sideStatValues = [];
    List<String> Function(PerformancePage) calcSideStatValues;

    List<Color> colors;
    List<List<double>> graphDatas = [];

    Hardwareinfo info;

    PerformancePage({
        required this.colors,
        required this.title,
        required this.info,
        required this.calcSubtitle,
        required this.statLabels,
        required this.calcStatValues,
        required this.sideStatLabels,
        required this.calcSideStatValues,
        required this.calcGraphRightLabel,
        int graphsDatasLen=1
    }) {
        for (int i = 0; i < graphsDatasLen; i++) {
            this.graphDatas.add(List.filled(60, 0));
        }
    }

    void renderSidebarItem(int y, bool selected) {
        if (selected) {
            noStroke();
            fill(205, 232, 255);
            rect(0, y, sidebarEnd, 70);
        }

        drawGraph(5, y + 5, 72, 59, this.colors, this.graphDatas, false);

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
        text(this.graphRightLabel, rightEdge, 107);

        final baseHeight = height - 12;
        final sideStatsY = baseHeight - Math.max((this.statLabels.length - 1) * 56 + 24, (this.sideStatLabels.length - 1) * 22);

        drawGraph(leftEdge, 110, pageWidth, (sideStatsY - 110 - 27).toInt(), this.colors, this.graphDatas, true);        

        // stat labels
        textSize(15);
        fill(112);
        textAlign(LEFT, BOTTOM);
        for (int y = 0; y < this.statLabels.length; y++) {
            for (int x = 0; x < this.statLabels[y].length; x++) {
                text(this.statLabels[y][x], leftEdge + x * 100, sideStatsY + y * 56);
            }
        }

        // stat values
        textSize(20);
        fill(0);
        textAlign(LEFT, BOTTOM);
        for (int y = 0; y < this.statValues.length; y++) {
            for (int x = 0; x < this.statValues[y].length; x++) {
                text(this.statValues[y][x], leftEdge + x * 100, sideStatsY + y * 56 + 24);
            }    
        }

        // side stat labels text setup
        textSize(15);
        textAlign(LEFT, BOTTOM);

        // offset of the side stat labels
        var xOff = 0.0;
        for (final row in this.statLabels) {
            final w = (row.length - 1) * 100.0 + textWidth(row.last) + 25.0;
            if (w > xOff) {
                xOff = w;
            }
        }

        // calc width of labels
        var labelWidth = 0.0;
        for (final label in this.sideStatLabels) {
            final w = textWidth(label);
            if (w > labelWidth) {
                labelWidth = w;
            }
        }

        // display labels
        fill(112);
        for (int y = 0; y < this.sideStatLabels.length; y++) {
            text(this.sideStatLabels[y], leftEdge + xOff, sideStatsY + y * 22);
        }

        // side stat values
        textSize(15);
        textAlign(LEFT, BOTTOM);
        fill(0);
        for (int y = 0; y < this.sideStatValues.length; y++) {
            text(this.sideStatValues[y], leftEdge + xOff + labelWidth + 12, sideStatsY + y * 22);
        }
    }

    void update() {
        this.info.updateDynamicStats();

        for (int i = 0; i < this.graphDatas.length; i++) {
            var data = this.graphDatas[i];
            var utilization = this.info.utilization[i];
            final len = data.length;
            for (int i = 0; i < len; i++) {
                data[i] = (i + 1 < len) ? data[i + 1] : (utilization / 100);
            }
        }

        this.subtitle = this.calcSubtitle(this);
        this.statValues = this.calcStatValues(this);
        this.sideStatValues = this.calcSideStatValues(this);
        this.graphRightLabel = this.calcGraphRightLabel(this);
    }
}
