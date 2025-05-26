import 'dart:math' as Math;
import 'dart:async';

import 'package:dcanvas/dcanvas.dart';
import 'package:dcanvas/backend/Window.dart';

import 'package:drawlite/drawlite.dart'
    show Color, Drawlite, Event, KeyboardEvent, MouseEvent, QuitEvent, DLImage;
import 'package:drawlite/dl.dart';
import 'package:drawlite/drawlite-touch.dart';

import 'systeminfo/systeminfo.dart';
import 'PerformancePage.dart';
import 'pages.dart';

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

late List<PerformancePage> performancePages;
int selectedPerformancePage = 1;
int sidebarEnd = 211;

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
    fill(217);
    rect(0, 45, width, 1);
    rect(sidebarEnd, 50, 1, height - 55);

    const tabLabels = ["Processes", "Performance", "App History", "Startup", "Users", "Details", "Services"];
    x = 0;
    for (int i = 0; i < tabLabels.length; i++) {
        final label = tabLabels[i];
        final tabWidth = (textWidth(label) + 14).round();

        stroke(217);
        fill(240);
        rect(x, 22, tabWidth, 23);
        if (label == "Performance") {
            noStroke();
            fill(255);
            rect(x+1, 23, tabWidth-1, 24);
        }

        fill(0);
        text(label, x + 8, 22 + 21);

        x += tabWidth;
    }
    
    int y = 50;
    for (int i = 0; i < performancePages.length; i++) {
        final page = performancePages[i];
        final selected = i == selectedPerformancePage;
        page.renderSidebarItem(y, selected);
        if (selected) {
            page.renderPage();
        }
        if (point_rect(get.mouseX, get.mouseY, 0, y, 211, 70)) {
            noFill();
            stroke(0, 100, 255);
            rect(0, y, 211, 69);
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
    int y = 50;
    for (int i = 0; i < performancePages.length; i++) {
        if (point_rect(get.mouseX, get.mouseY, 0, y, 211, 70)) {
            selectedPerformancePage = i;
        }
        y += 70;
    }
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

    performancePages = await createPerformancePages();

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
