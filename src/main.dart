import 'dart:ffi';
import 'dart:math' as Math;
import 'dart:async';

import 'package:dcanvas/dcanvas.dart';
import 'package:dcanvas/backend/Window.dart';

import 'package:drawlite/drawlite.dart'
    show Color, Drawlite, Event, KeyboardEvent, MouseEvent, QuitEvent, DLImage;
import 'package:drawlite/dl.dart';
import 'package:drawlite/drawlite-touch.dart';

import 'systeminfo/cpu.dart';

late Drawlite dl;

late SDLWindow window;

double appScale = 1.0;
// render dimensions
late int rwidth;
late int rheight;
// logical dimensions
late double width;
late double height;

void drawGraph(int x, int y, int w, int h, Color clr, List<double> data, bool grid) {
    // draw box
    noStroke();
    fill(255);
    rect(x, y, w, h);

    // draw grid
    if (grid) {
        stroke(lerpColor(clr, color(255), 0.85));
        double lineDist = h / 10;
        var drawEndY = 0.5 + y + h;
        for (int i = 1; i < 10; i++) {
            line(x, drawEndY - lineDist*i, x + w, drawEndY - lineDist*i);
        }
        for (int i = 1; i < 6; i++) {
            line(0.5 + x + i*(w/6), y, 0.5 + x + i*(w/6), y+h);
        }
    }

    // draw data
    stroke(clr);
    fill(clr.r, clr.g, clr.b, 100);
    beginShape();
    vertex(0.5 + x, y + h);
    double lineDist = w / 59;
    for (int i = 0; i < data.length; i++) {
        vertex(0.5 + x + i*lineDist, 0.5 + y + h - data[i] * (h - 1));
    }
    // vertex(0.5 + x + w, y + h - data.last * h + 0.5);
    vertex(0.5 + x + w, y + h);
    endShape();

    // draw border
    stroke(clr);
    noFill();
    rect(x, y, w, h);
}

class PerformanceSubPage {
    Color color;
    String title;
    List<double> data = [];
    CPUInfo info;

    PerformanceSubPage({
        required this.color,
        required this.title,
        required this.info
    }) {
        this.data = List.filled(60, 0);
    }

    void renderSidebarItem(int y, bool selected) {
        if (selected) {
            noStroke();
            fill(205, 232, 255);
            rect(0, y, 211, 70);
        }

        drawGraph(5, y + 5, 72, 59, this.color, this.data, false);

        fill(0);
        textAlign(LEFT, BOTTOM);
        textSize(20);
        text(this.title, 88, 76);

        textSize(15);
        text("${this.info.utilization.toInt()}% ${(this.info.clockSpeed / 1000.0).toStringAsFixed(2)} GHz", 88, 95);
    }

    void renderPage() {
        final leftEdge = 212 + 15;
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

        drawGraph(leftEdge, 110, pageWidth, (height - 310).toInt(), this.color, this.data, true);

        List<List<String>> labels = [
            ["Utilization", "Speed"],
            ["Processes", "Threads", "Handles"],
            ["Uptime"],
        ];
        textSize(15);
        fill(112);
        textAlign(LEFT, BOTTOM);
        for (int y = 0; y < labels.length; y++) {
            for (int x = 0; x < labels[y].length; x++) {
                text(labels[y][x], leftEdge + x * 100, height - (137 + 32) + y * 62);
            }    
        }

        final up = this.info.uptime;
        final days =    ((up / 60 / 60 / 24)).toInt().toString();
        final hours =   ((up / 60 / 60) % 24).toInt().toString().padLeft(2, "0");
        final minutes = ((up / 60) % 60).toInt().toString().padLeft(2, "0");
        final seconds = ((up % 60)).toInt().toString().padLeft(2, "0");
        List<List<String>> values = [
            ["${this.info.utilization.toInt()}%", "${(this.info.clockSpeed / 1000.0).toStringAsFixed(2)} GHz"],
            ["${this.info.runningProcessCount}", "${this.info.runningThreadCount}", "${this.info.handlesCount}"],
            ["${days}:${hours}:${minutes}:${seconds}"],
        ];
        textSize(24);
        fill(0);
        textAlign(LEFT, BOTTOM);
        for (int y = 0; y < values.length; y++) {
            for (int x = 0; x < values[y].length; x++) {
                text(values[y][x], leftEdge + x * 100, height - 137 + y * 62);
            }    
        }

        List<String> sideLabels = [
            "Base speed:",
            "Sockets:",
            "Cores:",
            "Logical processors:",
            "Virtualization:",
            "L1 cache:",
            "L2 cache:",
            "L3 cache:",
        ];
        textSize(15);
        fill(112);
        textAlign(LEFT, BOTTOM);
        for (int y = 0; y < sideLabels.length; y++) {
            text(sideLabels[y], leftEdge + 300, height - (137 + 32) + y * 22);
        }

        List<String> sideValues = [
            this.info.baseClock,
            "1",
            this.info.coreCount.toString(),
            this.info.threadCount.toString(),
            this.info.virtualization ? "Enabled" : "Disabled",
            this.info.l1Cache,
            this.info.l2Cache,
            this.info.l3Cache,
        ];
        textSize(15);
        fill(0);
        textAlign(LEFT, BOTTOM);
        for (int y = 0; y < sideValues.length; y++) {
            text(sideValues[y], leftEdge + 450, height - (137 + 32) + y * 22);
        }
    }

    void update() {
        this.info.updateDynamicStats();

        var data = this.data;
        final len = data.length;
        for (int i = 0; i < len; i++) {
            data[i] = (i + 1 < len) ? data[i + 1] : (this.info.utilization / 100);
        }
    }
}

int selectedPerformancePage = 0;
late List<PerformanceSubPage> performancePages;

void draw() {
    // check for events
    window.pollInput();

    final mouseX = get.mouseX;
    final mouseY = get.mouseY;

    background(255, 255, 255);

    // File, Options, View
    noStroke();
    fill(240);
    rect(0, 22, width, 2);

    fill(0);
    font("sans-serif", 14);
    textAlign(LEFT, BOTTOM);
    const dropDownLabels = ["File", "Options", "View"];
    var x = 6.0;
    for (int i = 0; i < dropDownLabels.length; i++) {
        final label = dropDownLabels[i];
        text(label, x, 20);
        x += textWidth(label) + 14;
    }

    // Processes, Performance, App History, Startup, Users, Details, Services
    stroke(217);
    const tabLabels = ["Processes", "Performance", "App History", "Startup", "Users", "Details", "Services"];
    x = 0;
    for (int i = 0; i < tabLabels.length; i++) {
        final label = tabLabels[i];
        final tabWidth = textWidth(label) + 14;

        fill(240);
        rect(x, 22, tabWidth, 23);

        fill(0);
        text(label, x + 8, 22 + 21);

        x += tabWidth;
    }
    
    fill(217);
    rect(0, 45, width, 1);
    rect(211, 50, 1, height - 55);

    
    int y = 50;
    for (int i = 0; i < performancePages.length; i++) {
        final page = performancePages[i];
        final selected = i == selectedPerformancePage;
        page.renderSidebarItem(y, selected);
        if (selected) {
            page.renderPage();
        }
        y += 70;
    }   

    window.render();

    if (!running) {
        noLoop();
        window.free();
    }
}

void mousePressed(MouseEvent event) {
    
}

void mouseDragged(MouseEvent event) {
    
}

void mouseReleased(MouseEvent event) {
    
}

var running = true;
void myEventHandler(Event event) {
    if (event is MouseEvent) {
        if (event.type == EventType.MouseDown) {
            dl.eventCallbacks.mousedown(event);
        } else if (event.type == EventType.MouseUp) {
            dl.eventCallbacks.mouseup(event);
        } else if (event.type == EventType.MouseMove) {
            dl.eventCallbacks.mousemove(event);
        }
    } else if (event is KeyboardEvent) {
        if (event.type == EventType.KeyDown) {
            dl.eventCallbacks.keydown(event);
        } else if (event.type == EventType.KeyUp) {
            dl.eventCallbacks.keyup(event);
        }
        
        if (event.keyCode == Key.Escape) {
            running = false;
        }
    } else if (event is QuitEvent) {
        running = false;
    }
}

void initDL(Drawlite dl) {
    fill = dl.fill;
    noFill = dl.noFill;
    stroke = dl.stroke;
    noStroke = dl.noStroke;
    point = dl.point;
    rect = dl.rect;
    rectMode = dl.rectMode;
    map = dl.map;
    pushMatrix = dl.pushMatrix;
    popMatrix = dl.popMatrix;
    scale = dl.scale;
    text = dl.text;
    textAlign = dl.textAlign;
    font = dl.font;
    textSize = dl.textSize;
    strokeWeight = dl.strokeWeight;
    textWidth = dl.textWidth;
    color = dl.color;
    floor = dl.floor;
    get = dl.get;
    CENTER = dl.CENTER;
    CORNER = dl.CORNER;
    BASELINE = dl.BASELINE;
    BOTTOM = dl.BOTTOM;
    TOP = dl.TOP;
    LEFT = dl.LEFT;
    RIGHT = dl.RIGHT;
    CLOSE = dl.CLOSE;
    translate = dl.translate;
    rotate = dl.rotate;
    radians = dl.radians;
    random = dl.random;
    sin = dl.sin;
    cos = dl.cos;
    constrain = dl.constrain;
    line = dl.line;
    arc = dl.arc;
    beginShape = dl.beginShape;
    vertex = dl.vertex;
    curveVertex = dl.curveVertex;
    bezierVertex = dl.bezierVertex;
    endShape = dl.endShape;
    ellipse = dl.ellipse;
    triangle = dl.triangle;
    quad = dl.quad;
    background = dl.background;
    colorMode = dl.colorMode;
    noLoop = dl.noLoop;
    textAscent = dl.textAscent;
    textDescent = dl.textDescent;
    lerpColor = dl.lerpColor;
    snip = dl.snip;
    image = dl.image;
    frameRate = dl.frameRate;
    imageMode = dl.imageMode;
}

Future<void> main() async {
    rwidth = (900 * appScale).round();
    rheight = (700 * appScale).round();

    // create canvas and drawlite instance
    var canvas = Canvas(rwidth, rheight);
    dl = Drawlite(canvas);
    initDL(dl);

    // setup window
    initSDL(SDL_INIT_EVERYTHING);
    window = SDLWindow(
        title: "TuxTaskManager",
        width: canvas.width,
        height: canvas.height,
        flagsList: [SDL_WindowFlags.SDL_WINDOW_SHOWN]
    );
    window.setCanvas(canvas);
    window.eventHandler = myEventHandler;

    // begin app
    width = rwidth / appScale;
    height = rheight / appScale;

    performancePages = [
        PerformanceSubPage(
            color: color(17, 125, 187),
            title: "CPU",
            info: await CPUInfo.thisDeviceInfo()
        )
    ];

    Timer.periodic(Duration(seconds: 1), (_) {
        for (final page in performancePages) {
            page.update();
        }
    });

    frameRate(60);
    dl.draw = draw;
    dl.mousePressed = mousePressed;
    dl.mouseDragged = mouseDragged;
    dl.mouseReleased = mouseReleased;
}
