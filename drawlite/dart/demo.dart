// import 'package:ffi/ffi.dart';
// import 'package:dcanvas/backend/Backend.dart';

import 'package:dcanvas/dcanvas.dart' show Canvas;
import 'package:drawlite/drawlite.dart'
    show Color, Drawlite;
import 'package:drawlite/dl.dart';

void main() {
    var canvas = Canvas(400, 400);
    Drawlite dl = Drawlite(canvas);
    // initDl(dl);

    CENTER = dl.CENTER;
    CORNER = dl.CORNER;
    BASELINE = dl.BASELINE;
    CLOSE = dl.CLOSE;
    HSB = dl.HSB;
    RGB = dl.RGB;

    map = dl.map;
    sin = dl.sin;
    cos = dl.cos;
    radians = dl.radians;
    random = dl.random;
    floor = dl.floor;

    fill = dl.fill;
    noFill = dl.noFill;
    stroke = dl.stroke;
    noStroke = dl.noStroke;
    rect = dl.rect;
    rectMode = dl.rectMode;
    pushMatrix = dl.pushMatrix;
    popMatrix = dl.popMatrix;
    scale = dl.scale;
    text = dl.text;
    textAlign = dl.textAlign;
    font = dl.font;
    strokeWeight = dl.strokeWeight;
    textWidth = dl.textWidth;
    color = dl.color;
    translate = dl.translate;
    rotate = dl.rotate;
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

    get = dl.get;

    background(0, 0, 0, 0);
    translate(200, 200);
    scale(1.56);
    translate(-200, -200);

    noStroke();
    fill(255, 255, 255);
    ellipse(200, 200, 240, 240);

    var rot = 6.6;
    for (var i = 0; i < 6; i++) {
        pushMatrix();
            translate(200, 200);
            rotate(rot + i * 360 / 6);
            
            var idk = 28;
            var r = (240-16)/2;
            stroke(0);
            strokeWeight(10);
            triangle(cos(idk)*r, sin(idk)*r, -23, 67, 10, r);
        popMatrix();
    }

    noStroke();
    colorMode(HSB);
    for (var j = 0; j < 51; j++) {
        for (var i = 0; i < 6; i++) {
            pushMatrix();
                translate(200, 200);
                rotate(rot + j * 60 + i * 360 / 6);
                
                fill(i / 6 * 360, 255, 255, j * 2.5);
                var idk = 28;
                var r = (240-16)/2;
                beginShape();
                    vertex(cos(idk)*r, sin(idk)*r);
                    vertex(-23, 67);
                    vertex(10, r);
                    vertex(72, r-10);
                endShape();
            popMatrix();
        }
    }
    colorMode(RGB);

    noFill();
    strokeWeight(16);
    stroke(0, 0, 0);
    ellipse(200, 200, 240, 240);

    // ellipse(200, 200, 120, 120);

    // "Brushes" Icon
    void brushes(x, y, s, r) {
        pushMatrix();
            translate(x, y);
            scale(s);
            rotate(r);
            
            beginShape();
            vertex(0, 0);
            bezierVertex(12, -1, 12, 14, 0, 14);
            bezierVertex(-6, 14, -8, 13, -12, 12);
            bezierVertex(-4, 8, -10, 3, 0, 0);
            endShape();
            
            beginShape();
            vertex(5, 2);
            bezierVertex(5, -2, 7, -9, 40, -30);
            bezierVertex(48, -33, 44, -25, 44, -26);
            bezierVertex(26, -4, 7, 10, 5, 2);
            endShape();
        popMatrix();
    };

    // enableContextMenu();

    fill(0, 0, 0);
    rectMode(CENTER);
    noStroke();
    brushes(193, 174, 1.4, 130);
    noFill();
    strokeWeight(13);
    stroke(0, 0, 0);
    arc(200+1, 200-20, 50, 50, -94, 86);
    noStroke();
    fill(0, 0, 0);
    rectMode(CORNER);
    rotate(0.9);
    rect(198, 196, 6, 12);

    // final filename = './logo.png'.toNativeUtf8();
    // cairo.cairo_surface_write_to_png(canvas.backend().surface, filename.cast());
    // malloc.free(filename);
}
