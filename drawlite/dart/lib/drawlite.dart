/*
    drawlite.dart - a lightweight yet powerful graphics library based on Processing and p5

    Credits:
        - PRNG is from https://github.com/davidbau/seedrandom under the MIT license (https://opensource.org/license/mit/)
        - Perlin Noise functionality is based on p5.js (https://github.com/processing/p5.js) and is available under the GNU Lesser General Public License (https://www.gnu.org/licenses/lgpl-3.0.en.html)
        - This project was heavily influenced by Processing.js (https://github.com/processing-js/processing-js) and small snippets of code were occasionally taken and modified from it
        - Color.RGBtoHSB and Color.HSBtoRGB algorithms from https://www.30secondsofcode.org/
        - All other code is written by Vexcess and is available under the MIT license (https://opensource.org/license/mit/)

    Processing.js is nearly 755 KB, outdated, and slow
    p5.js is better than Processing, but is a massive 3,695 KB
    Drawlite can do almost everything the former two can, but is a tiny 30 KB meaning your browser will download it over 123 times faster than p5!

    Some functionalities from Processing and p5 aren't implemented in Drawlite not because Drawlite is incomplete but rather because the functionalities were considered too niche and people probably wouldn't ever use them if added.

    Dart Drawlite is lacking the following features from the JS version:
        getProperties
        enableContextMenu

*/

import 'dart:math' as Math;
import 'dart:async';
import 'dart:ffi' as ffi;
import 'dart:typed_data';

import "package:dcanvas/dcanvas.dart";
import 'package:dcanvas/backend/Window.dart';

export 'package:dcanvas/backend/Window.dart' show Event, MouseEvent, KeyboardEvent, QuitEvent;

final mathRandom = Math.Random();

T max_<T extends num>(List<T> arr) {
    if (arr.length > 0) {
        num val = arr[0] as num;
        for (var i = 0; i < arr.length; i++) {
            final num item = arr[i] as num;
            if (item > val) {
                val = item;
            }
        }
        return val as T;
    } else {
        throw "max() only List<num|int|double> where .length > 0";
    }
}

T min_<T extends num>(List<T> arr) {
    if (arr.length > 0) {
        num val = arr[0] as num;
        for (var i = 0; i < arr.length; i++) {
            final num item = arr[i] as num;
            if (item < val) {
                val = item;
            }
        }
        return val as T;
    } else {
        throw "max() only List<num|int|double> where .length > 0";
    }
}

int round_<T>(T n) {
    return (n as num).round();
}

// constants
const double PI_ = Math.pi;
const double TWO_PI_ = Math.pi * 2;
const double EPSILON_ = 0.0000000000000001;
const int CORNER_ = 0;
const int CORNERS_ = 1;
const int LEFT_ = 2;
const int RIGHT_ = 3;
const int TOP_ = 4;
const int CENTER_ = 5;
const int BOTTOM_ = 6;
const int BASELINE_ = 7;
const int RADIUS_ = 8;
const int DEGREES_ = 9;
const int RADIANS_ = 10;
const int POINTS_ = 11;
const int LINES_ = 12;
const int TRIANGLES_ = 13;
const int TRIANGLE_STRIP_ = 14;
const int TRIANGLE_FAN_ = 15;
const int QUADS_ = 16;
const int QUAD_STRIP_ = 17;
const int CLOSE_ = 18;
const String ROUND_ = "round";
const String SQUARE_ = "butt";
const String PROJECT_ = "square";
const String BEVEL_ = "bevel";
const String MITER_ = "miter";
const int RGB_ = 1;
const int HSB_ = 2;
const int NATIVE_ = 0;
const int VERTEX_NODE_ = 3;
const int CURVE_VERTEX_NODE_ = 4;
const int BEZIER_VERTEX_NODE_ = 5;
const int SPLINE_VERTEX_NODE_ = 6;
const int UNDEFINED = -1;

class TextMetrics {
    late double width;
    // late int actualBoundingBoxDescent;
    TextMetrics(this.width);
}

class Color {
    static fromInt(int num) {
        return new Color(num & 255, num >> 8 & 255, num >> 16 & 255, num >> 24);
    }

    List<int> fromHex(String hex) {
        hex = hex.replaceFirst("#", "");
        if (hex.length == 3) {
            final a = hex[0],
                b = hex[1],
                c = hex[2];
            hex = a+a + b+b + c+c;
        }
        var num = int.parse(hex, radix: 16);
        if (num < 0xffffff) {
            num = (num << 8) | 0xff;
        }
        Uint8List list = Uint8List(4)
            ..buffer.asByteData().setUint32(
                0,
                num,
                Endian.big,
            );
        return list;
    }

    static fromString(str) {
        final bytes = str.slice(str.indexOf("(")+1, str.length-1).split(",");
        return new Color(bytes[0], bytes[1], bytes[2], bytes[3]);
    }

    static RGBtoHSB(num r, num g, num b) {
        // https://www.30secondsofcode.org/js/s/rgb-to-hsb
        r = r / 255;
        g = g / 255;
        b = b / 255;
        final v = max_([r, g, b]),
        n = v - min_([r, g, b]);
        var h;
        if (n == 0) {
            h = 0;
        } else {
            if (n != 0 && v == r) {
                h = (g - b) / n;
            } else {
                if (v == g) {
                    h = 2 + (b - r) / n;
                } else {
                    h = 4 + (r - g) / n;
                }
            }
        }
        return [60 * (h < 0 ? h + 6 : h), v == 0 ? 0 : (n / v) * 100, v * 100];
    }

    static List<int> HSBtoRGB(num h, num s, num b) {
        // https://www.30secondsofcode.org/js/s/hsb-to-rgb
        final f = (num h, num s, num b, num n) {
            final num k = (n + h / 60) % 6;
            return b * (1 - s * max_([0, min_([k, 4 - k, 1])]));
        };
        s /= 100;
        b /= 100;
        return [(f(h, s, b, 5) * 255).toInt(), (f(h, s, b, 3) * 255).toInt(), (f(h, s, b, 1) * 255).toInt()];
    }

    late int r;
    late int g;
    late int b;
    late int a;
    static Color fromRGB(num r, [num? g, num? b, num a=255]) {
        final t = Color();
        if (g == null) {
            t.r = r.toInt();
            t.g = r.toInt();
            t.b = r.toInt();
            t.a = 255;
        } else if (b == null) {
            t.r = r.toInt();
            t.g = r.toInt();
            t.b = r.toInt();
            t.a = g.toInt();
        } else {
            t.r = r.toInt();
            t.g = g.toInt();
            t.b = b.toInt();
            t.a = a.toInt();
        }
        return t;
    }

    static Color fromHSB(num r, num g, num b, [num a=255]) {
        final t = Color();
        final c = Color.HSBtoRGB(r, g, b);
        t.r = c[0];
        t.g = c[1];
        t.b = c[2];
        t.a = a.toInt();
        return t;
    }

    Color([num? r, num? g, num? b, num a=255]) {
        if (r != null) {
            final t = this;
            final c = Color.fromRGB(r, g, b, a);
            t.r = c.r;
            t.g = c.g;
            t.b = c.b;
            t.a = c.a;
        }
    }

    bool equals(Color c) {
        return this.r == c.r && this.g == c.g && this.b == c.b && this.a == c.a;
    }

    int toInt() {
        return (this.a < 255 ? this.a : 0) << 24 | this.b << 16 | this.g << 8 | this.r;
    }

    String toHex() {
        var hex = "#" + (1 << 24 | this.r << 16 | this.g << 8 | this.b).toRadixString(16).substring(1);
        if (this.a < 255) {
            final ah = this.a.toInt().toRadixString(16);
            hex += this.a.toInt() < 16 ? "0" + ah : ah;
        }
        return hex;
    }

    String toString() {
        return this.a == 255 ? "rgb(${this.r.toInt()},${this.g.toInt()},${this.b.toInt()})" : "rgba(${this.r.toInt()},${this.g.toInt()},${this.b.toInt()},${this.a/255})";
    }

    Color toHSB() {
        return Color.RGBtoHSB(this.r, this.g, this.b);
    }
}

/*
    Copyright 2019 David Bau.

    Permission is hereby granted, free of charge, to any person obtaining
    a copy of this software and associated documentation files (the
    "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish,
    distribute, sublicense, and/or sell copies of the Software, and to
    permit persons to whom the Software is furnished to do so, subject to
    the following conditions:

    The above copyright notice and this permission notice shall be
    included in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
    EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
    CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
List<int> pool = [];
int width = 256; // each RC4 output is 0 <= x < 256
int chunks = 6; // at least six RC4 outputs for each double
int digits = 52; // there are 52 significant digits in a double
String rngname = 'random'; // rngname: name for Math.random and Math.seedrandom
int startdenom = Math.pow(width, chunks) as int;
int significance = Math.pow(2, digits) as int;
int overflow = significance * 2;
int mask = width - 1;
bool mixedKey = false;

double Function() PRNG(seed, [bool entropy=false]) {
    List<int> key = [];
    mixkey(flatten(
        entropy ? [seed, tostring(pool)] :
        (seed == null) ? autoseed() : seed, 3), key);

    var arc4 = new ARC4(key);

    double prng() {
        double n = arc4.g(chunks).toDouble(); // Start with a numerator n < 2 ^ 48
        double d = startdenom.toDouble(); //   and denominator d = 2 ^ 48.
        int x = 0; //   and no 'extra last byte'.
        while (n < significance) { // Fill up all significant digits by
            n = (n + x) * width; //   shifting numerator and
            d *= width; //   denominator and generating a
            x = arc4.g(1); //   new least-significant-byte.
        }
        while (n >= overflow) { // To avoid rounding up, before adding
            n /= 2; //   last byte, shift everything
            d /= 2; //   right using integer math until
            x >>>= 1; //   we have exactly the desired bits.
        }
        return (n + x) / d; // Form the number within [0, 1).
    };

    // Mix the randomness into accumulated entropy.
    mixkey(tostring(arc4.S), pool);

    if (!mixedKey) {
        mixkey(Math.Random().nextDouble(), pool);
        mixedKey = true;
    }

    // Calling convention: what to return as a function of prng, seed, is_math.
    return prng;
}

class ARC4 {
    late int i;
    late int j;
    late List<int> S;
    late int Function(int) g;

    ARC4(List<int> key) {
        var t;
        int keylen = key.length;
        int i = 0;
        int j = this.i = this.j = 0;
        List<int> s = this.S = [];

        if (keylen == 0) {
            key = [keylen++];
        }

        while (i < width) {
            s[i] = i++;
        }
        for (i = 0; i < width; i++) {
            s[i] = s[j = mask & (j + key[i % keylen] + (t = s[i]))];
            s[j] = t;
        }

        final that = this;
        this.g = (int count) {
            late int t;
            var r = 0;
            int i = that.i;
            int j = that.j;
            var s = that.S;
            while ((count--) != 0) {
                t = s[i = mask & (i + 1)];
                r = r * width + s[mask & ((s[i] = s[j = mask & (j + t)]) + (s[j] = t))];
            }
            that.i = i;
            that.j = j;
            return r;
        };

        that.g(width);
    }
}

Object flatten(Object obj, depth) {
    List<Object> result = [];
    if (depth && obj is List) {
        for (var i = 0; i < obj.length; i++) {
            try {
                result.add(flatten(obj[i], depth - 1));
            } catch (e) {}
        }
    }
    return (result.length != 0 ? result : obj is String ? obj : obj.toString() + '\0');
}

String mixkey(Object seed, List<int> key) {
    String stringseed = seed.toString();
    var smear, j = 0;
    while (j < stringseed.length) {
        key[mask & j] =
            mask & ((smear ^= key[mask & j] * 19) + stringseed[j++]);
    }
    return tostring(key);
}

String autoseed() {
    var out = Uint8List(width);
    var secureRandom = Math.Random.secure();
    for (var i = 0; i < out.length; i++) {
        out[i] = secureRandom.nextInt(256);
    }
    return tostring(out);
}

String tostring(List<int> a) {
    return String.fromCharCodes(a);
}

class Vec3 {
    num x, y, z;
    Vec3(num this.x, num this.y, [num this.z=0]);

    Vec3 fromArr(List<num> arr) {
        return Vec3(arr[0], arr[1], arr[2]);
    }

    List<num> toArr(Vec3 v) {
        return [v.x, v.y, v.z];
    }

    Vec3 clone(Vec3 v) {
        return Vec3(v.x, v.y, v.z);
    }

    Vec3 add(Vec3 v1, Object v2) {
        if (v2 is num) {
            return Vec3(
                v1.x + v2,
                v1.y + v2,
                v1.z + v2
            );
        } else if (v2 is Vec3) {
            return Vec3(
                v1.x + v2.x,
                v1.y + v2.y,
                v1.z + v2.z
            );
        }
        throw "invalid type passed to Vec3.add";
    }

    Vec3 sub(Vec3 v1, Object v2) {
        if (v2 is num) {
            return Vec3(
                v1.x - v2,
                v1.y - v2,
                v1.z - v2
            );
        } else if (v2 is Vec3) {
            return Vec3(
                v1.x - v2.x,
                v1.y - v2.y,
                v1.z - v2.z
            );
        }
        throw "invalid type passed to Vec3.sub";
    }

    Vec3 mul(Vec3 v1, Object v2) {
        if (v2 is num) {
            return Vec3(
                v1.x * v2,
                v1.y * v2,
                v1.z * v2
            );
        } else if (v2 is Vec3) {
            return Vec3(
                v1.x * v2.x,
                v1.y * v2.y,
                v1.z * v2.z
            );
        }
        throw "invalid type passed to Vec3.mul";
    }

    Vec3 div(Vec3 v1, Object v2) {
        if (v2 is num) {
            return Vec3(
                v1.x / v2,
                v1.y / v2,
                v1.z / v2
            );
        } else if (v2 is Vec3) {
            return Vec3(
                v1.x / v2.x,
                v1.y / v2.y,
                v1.z / v2.z
            );
        }
        throw "invalid type passed to Vec3.div";
    }

    Vec3 neg(Vec3 v) {
        return Vec3(
            -v.x,
            -v.y,
            -v.z
        );
    }
    
    double mag(Vec3 v1) {
        // benchmarks show that caching the values results in a 0.000008% performance boost
        final x = v1.x, y = v1.y, z = v1.z;
        return Math.sqrt(x * x + y * y + z * z);
    }

    Vec3 normalize(Vec3 v1) {
        final x = v1.x, y = v1.y, z = v1.z;
        final m = Math.sqrt(x * x + y * y + z * z);
        return m > 0 ? Vec3(
            v1.x / m,
            v1.y / m,
            v1.z / m
         ) : v1;
    }

    num dot(Vec3 v1, Vec3 v2) {
        return v1.x * v2.x + v1.y * v2.y + v1.z * v2.z;
    }

    Vec3 cross(Vec3 v1, Vec3 v2) {
        return Vec3(
            v1.y * v2.z - v1.z * v2.y,
            v1.z * v2.x - v1.x * v2.z,
            v1.x * v2.y - v1.y * v2.x
        );
    }
}

class GetObject {
    late int width;
    late int height;
    late int frameCount;
    late double FPS;
    late int pmouseX;
    late int pmouseY;
    late int mouseX;
    late int mouseY;
    late bool mouseIsPressed;
    late int mouseButton;
    late bool keyIsPressed;
    // imageData = this.imageData;
    late bool focused;

    GetObject() {}
}

class EventCallbacks {
    late void Function() focus;
    late void Function() blur;

    late void Function(MouseEvent) mousedown;
    late void Function(MouseEvent) mouseup;
    late void Function(MouseEvent) mousemove;

    late void Function(KeyboardEvent) keydown;
    late void Function(KeyboardEvent) keyup;
}


class DLImage {
    late int width;
    late int height;
    late ImageData imageData;
    late Canvas sourceImage;
    late Context2D _ctx;

    DLImage(Object src) {
        if (src is Canvas) {
            this.width = src.width;
            this.height = src.height;
            this.sourceImage = Canvas(this.width, this.height);
            this._ctx = this.sourceImage.getContext("2d");
            this._ctx.drawImage(src, 0, 0, this.width, this.height);
            this.imageData = this._ctx.getImageData(0, 0, this.width, this.height);
        } else if (src is ImageData) {
            this.width = src.width;
            this.height = src.height;
            this.sourceImage = Canvas(this.width, this.height);
            this._ctx = this.sourceImage.getContext("2d");
            this._ctx.putImageData(src, 0, 0);
            this.imageData = src;
        }
    }

    updatePixels() {
        this._ctx.putImageData(this.imageData, 0, 0);
    }

    mask(img) {
        var fillPix = this.imageData.data,
            imgData = img is DLImage ? img.imageData : img;

        if (imgData.width == this.width && imgData.height == this.height) {
            var shapePixs = imgData.data;
            for (var i = 0, len = fillPix.length; i < len; i += 4) {
                fillPix[i+3] = shapePixs[i];
            }
        } else {
            throw "mask must have the same dimensions as image.";
        }

        this.updatePixels();
    }
}

class Drawlite {
    static List<Drawlite> instances = [];
    static List<Object> addons = [];

    // Drawlite CONSTANTS
    final double PI = PI_;
    final double TWO_PI = TWO_PI_;
    final double EPSILON = EPSILON_;
    final int CORNER = CORNER_;
    final int CORNERS = CORNERS_;
    final int LEFT = LEFT_;
    final int RIGHT = RIGHT_;
    final int TOP = TOP_;
    final int CENTER = CENTER_;
    final int BOTTOM = BOTTOM_;
    final int BASELINE = BASELINE_;
    final int RADIUS = RADIUS_;
    final int DEGREES = DEGREES_;
    final int RADIANS = RADIANS_;
    final int POINTS = POINTS_;
    final int LINES = LINES_;
    final int TRIANGLES = TRIANGLES_;
    final int TRIANGLE_STRIP = TRIANGLE_STRIP_;
    final int TRIANGLE_FAN = TRIANGLE_FAN_;
    final int QUADS = QUADS_;
    final int QUAD_STRIP = QUAD_STRIP_;
    final int CLOSE = CLOSE_;
    final String ROUND = ROUND_;
    final String SQUARE = SQUARE_;
    final String PROJECT = PROJECT_;
    final String BEVEL = BEVEL_;
    final String MITER = MITER_;
    final int RGB = RGB_;
    final int HSB = HSB_;
    final int NATIVE = NATIVE_;

    late Canvas canvas;
    late Context2D ctx;
    late int frameCount = 0;
    late double FPS = 0;
    late int pmouseX = 0;
    late int pmouseY = 0;
    late int mouseX = 0;
    late int mouseY = 0;
    late bool mouseIsPressed = false;
    late int mouseButton = LEFT;
    late bool keyIsPressed = false;
    late int width = canvas.width;
    late int height = canvas.height;
    late bool focused = false;
    // late int imageData = new ImageData(canvas.width, canvas.height);

    void Function()? draw = null;
    void Function(MouseEvent)? mousePressed = null;
    void Function(MouseEvent)? mouseReleased = null;
    void Function(MouseEvent)? mouseMoved = null;
    void Function(MouseEvent)? mouseDragged = null;
    void Function(KeyboardEvent)? keyPressed = null;
    void Function(KeyboardEvent)? keyReleased = null;

    late EventCallbacks eventCallbacks;

    // LOCAL VARIABLE
    int curClrMode = RGB_;

    void DrawliteUpdate (Timer _) {
        if (this.draw != null) {
            try {
                (this.draw as void Function())();
            } catch (e, stacktrace) {
                print(e.toString());
                print(stacktrace);
                throw e;
            } finally { // rare case where finally is useful
                this.frameCount++;
                this._FPS_Counter++;

                final time = DateTime.now().millisecondsSinceEpoch;
                if (time - this._lastFPSCheck >= 1000) {
                    this._lastFPSCheck = time;
                    this.FPS = this._FPS_Counter.toDouble();
                    this._FPS_Counter = 0;
                }

                updateDynamics();
            }
        }
    }

    Drawlite(Canvas canvas, [Function? callback]) {
        this.canvas = canvas;
        this.ctx = canvas.getContext("2d");

        this.width = this.canvas.width;
        this.height = this.canvas.height;

        updateDynamics();
        font(_curFontName, _curFontSize);
        strokeCap(ROUND);

        this._drawTimer = Timer.periodic(Duration(milliseconds: (1000 / this._targetFPS).round()), DrawliteUpdate);

        void on_focus() {
            this.focused = true;
        }
        void on_blur() {
            this.focused = false;
        }

        void on_mousedown(MouseEvent e) {
            this.mouseButton = [LEFT, CENTER, RIGHT][e.which - 1];
            this.mouseIsPressed = true;
            if (this.mousePressed != null) this.mousePressed!(e);
        }
        void on_mouseup(MouseEvent e) {
            this.mouseIsPressed = false;
            if (this.mouseReleased != null) this.mouseReleased!(e);
        }
        void on_mousemove(MouseEvent e) {
            this.pmouseX = this.mouseX;
            this.pmouseY = this.mouseY;
            this.mouseX = e.clientX;
            this.mouseY = e.clientY;
            if (this.mouseMoved != null) this.mouseMoved!(e);
            if (this.mouseIsPressed && this.mouseDragged != null) this.mouseDragged!(e);
        }

        void on_keydown(KeyboardEvent e) {
            this.keyIsPressed = true;
            if (this.keyPressed != null) this.keyPressed!(e);
        }
        void on_keyup(KeyboardEvent e) {
            this.keyIsPressed = false;
            if (this.keyReleased != null) this.keyReleased!(e);
        }

        this.eventCallbacks = EventCallbacks();
        eventCallbacks.focus = on_focus;
        eventCallbacks.blur = on_blur;
        eventCallbacks.mousedown = on_mousedown;
        eventCallbacks.mouseup = on_mouseup;
        eventCallbacks.mousemove = on_mousemove;
        eventCallbacks.keydown = on_keydown;
        eventCallbacks.keyup = on_keyup;

        // let ads = Drawlite.addons;
        // for (let i = 0; i < ads.length; i++) {
        //     Object.assign(D, ads[i].static);
        //     if (typeof ads[i].methods === "object") {
        //         for (let meth in ads[i].methods) {
        //             D[meth] = (...args) => {
        //                 ads[i].methods[meth](D, ...args);
        //             };
        //         }
        //     }
        // }

        if (callback != null) callback(this);

        Drawlite.instances.add(this);
    }

    // let PERLIN_YWRAPB = 4,
    //     PERLIN_YWRAP = 1 << PERLIN_YWRAPB,
    //     PERLIN_ZWRAPB = 8,
    //     PERLIN_ZWRAP = 1 << PERLIN_ZWRAPB,
    //     PERLIN_SIZE = 4095,
    //     scaled_cosine;
    // {
    //     const cos = Math.cos;
    //     scaled_cosine = i => 0.5 * (1.0 - cos(i * Math.PI));
    // }
    // class PerlinNoise {
    //     #perlin;
    //     #perlin_octaves = 4;
    //     #perlin_amp_falloff = 0.5;
    //     seed;

    //     constructor(seed) {
    //         this.seed = seed ?? Math.random() << 2048;
    //         this.setSeed(this.seed);
    //     }

    //     setDetail(lod, falloff) {
    //         if (lod > 0) this.#perlin_octaves = lod;
    //         if (falloff > 0) this.#perlin_amp_falloff = falloff;
    //     }

    //     setSeed(seed) {
    //         this.seed = seed;

    //         const lcg = (() => {
    //             const m = 4294967296;
    //             const a = 1664525;
    //             const c = 1013904223;
    //             let seed, z;
    //             return {
    //                 setSeed(val) {
    //                     z = seed = (val == null ? Math.random() * m : val) >>> 0;
    //                 },
    //                 rand() {
    //                     z = (a * z + c) % m;
    //                     return z / m;
    //                 }
    //             };
    //         })();

    //         lcg.setSeed(seed);
    //         this.#perlin = new Array(PERLIN_SIZE + 1);
    //         for (let i = 0; i < PERLIN_SIZE + 1; i++) {
    //             this.#perlin[i] = lcg.rand();
    //         }
    //     }

    //     get(x, y = 0, z = 0) {        
    //         if (x < 0) x = -x;
    //         if (y < 0) y = -y;
    //         if (z < 0) z = -z;

    //         let xi = floor(x),
    //             yi = floor(y),
    //             zi = floor(z);
    //         let xf = x - xi;
    //         let yf = y - yi;
    //         let zf = z - zi;
    //         let rxf, ryf;

    //         let r = 0;
    //         let ampl = 0.5;

    //         let n1, n2, n3;

    //         let perlin = this.#perlin,
    //             perlin_octaves = this.#perlin_octaves,
    //             perlin_amp_falloff = this.#perlin_amp_falloff;
    //         for (let o = 0; o < perlin_octaves; o++) {
    //             let of = xi + (yi << PERLIN_YWRAPB) + (zi << PERLIN_ZWRAPB);

    //             rxf = scaled_cosine(xf);
    //             ryf = scaled_cosine(yf);

    //             n1 = perlin[of & PERLIN_SIZE];
    //             n1 += rxf * (perlin[(of + 1) & PERLIN_SIZE] - n1);
    //             n2 = perlin[(of + PERLIN_YWRAP) & PERLIN_SIZE];
    //             n2 += rxf * (perlin[(of + PERLIN_YWRAP + 1) & PERLIN_SIZE] - n2);
    //             n1 += ryf * (n2 - n1);

    //             of += PERLIN_ZWRAP;
    //             n2 = perlin[of & PERLIN_SIZE];
    //             n2 += rxf * (perlin[(of + 1) & PERLIN_SIZE] - n2);
    //             n3 = perlin[(of + PERLIN_YWRAP) & PERLIN_SIZE];
    //             n3 += rxf * (perlin[(of + PERLIN_YWRAP + 1) & PERLIN_SIZE] - n3);
    //             n2 += ryf * (n3 - n2);

    //             n1 += scaled_cosine(zf) * (n2 - n1);

    //             r += n1 * ampl;
    //             ampl *= perlin_amp_falloff;
    //             xi <<= 1;
    //             xf *= 2;
    //             yi <<= 1;
    //             yf *= 2;
    //             zi <<= 1;
    //             zf *= 2;

    //             if (xf >= 1.0) {
    //                 xi++;
    //                 xf--;
    //             }
    //             if (yf >= 1.0) {
    //                 yi++;
    //                 yf--;
    //             }
    //             if (zf >= 1.0) {
    //                 zi++;
    //                 zf--;
    //             }
    //         }
    //         return r;
    //     }
    // }

    // MORE LOCAL VARIABLES
    Timer? _drawTimer = null;
    num _targetFPS = 60;
    int _FPS_Counter = 0;
    int _lastFPSCheck = DateTime.now().millisecondsSinceEpoch;
    int _curAngleMode = DEGREES_;
    int _curRectMode = CORNER_;
    int _curEllipseMode = CENTER_;
    int _horTxtAlign = LEFT_;
    int _verTxtAlign = CENTER_;
    String _curFontName = "sans-serif";
    double _curFontSize = 12;
    double _curTxtAscent = 55;
    double _curTxtDescent = 2;
    double _curTxtLeading = 14;
    Color? _curStroke = new Color(0);
    num _curStrokeWeight = 1;
    Color? _curFill = new Color(255);
    List<(int, List<num>)> shapePath = [(UNDEFINED, [])];
    int shapePathType = UNDEFINED;
    int VERTEX_NODE = VERTEX_NODE_;
    int CURVE_VERTEX_NODE = CURVE_VERTEX_NODE_;
    int BEZIER_VERTEX_NODE = BEZIER_VERTEX_NODE_;
    int SPLINE_VERTEX_NODE = SPLINE_VERTEX_NODE_;
    bool autoUpdate = false;

    // ctxMenuEnabled = false,
    int _curImgMode = CORNER_;
    num _splineTightness = 0;
    void textLine(String str, num x, num y, int align) {
        var txtWidth = 0.0;
        var xOffset = 0.0;

        // horizontal offset/alignment
        if (align == RIGHT || align == CENTER) {
            txtWidth = textWidth(str);
            xOffset = align == RIGHT ? -txtWidth : -txtWidth / 2; // if (align === CENTER)
        }

        ctx.fillText(str, x + xOffset, y);
    }

    String calcFontString(String f, num sz) {
        const genericFonts = [
            "serif",
            "sans-serif",
            "monospace",
            "cursive",
            "fantasy",
            "system-ui",
            "ui-serif",
            "ui-sans-serif",
            "ui-monospace",
            "ui-rounded",
            "emoji",
            "math",
            "fangsong"
        ];

        if (genericFonts.contains(f)) {
            return "${sz}px ${f}";
        } else {
            return "${sz}px \"${f}\", sans-serif";
        }
    }


    // MORE STATIC VARIABLES
    void size(num w, num h) {
    //     D.width = canvas.width = w;
    //     D.height = canvas.height = h;
    //     font(curFontName, curFontSize);
    //     D.imageData = ctx.getImageData(0, 0, D.width, D.height);
    //     updateDynamics();
    }

    void angleMode(int m) {
        _curAngleMode = m;
    }

    void noLoop() {
        var timer = this._drawTimer;
        if (timer != null)
            timer.cancel();
    }

    void loop() {
        this._drawTimer = Timer.periodic(Duration(milliseconds: (1000 / this._targetFPS).round()), DrawliteUpdate);
    }

    double frameRate([num? r]) {
        if (r != null) {
            this._targetFPS = r;
            this.noLoop();
            this.loop();
        }
        return this.FPS;
    }

    Function min = min_;
    
    Function max = max_;
    
    num floor(num n) {
        return n.floor();
    }

    num round(num n) {
        return n.round();
    }

    num ceil(num n) {
        return n.ceil();
    }

    num abs(num n) {
        return n.abs();
    }

    num constrain(num n, num min, num max) {
        return n > max ? max : n < min ? min : n;
    }

    num sq(num n) {
        return n * n;
    }

    Function sqrt = Math.sqrt;

    Function pow = Math.pow;

    double sin(num a) {
        return Math.sin(_curAngleMode == DEGREES ? a*PI/180 : a);
    }

    double cos(num a) {
        return Math.cos(_curAngleMode == DEGREES ? a*PI/180 : a);
    }

    double tan(num a) {
        return Math.tan(_curAngleMode == DEGREES ? a*PI/180 : a);
    }

    double asin(num a) {
        return Math.asin(_curAngleMode == DEGREES ? a*PI/180 : a);
    }

    double acos(num a) {
        return Math.acos(_curAngleMode == DEGREES ? a*PI/180 : a);
    }

    double atan(num a) {
        return Math.atan(_curAngleMode == DEGREES ? a*PI/180 : a);
    }

    double atan2(num y, num x) {
        return _curAngleMode == DEGREES ? Math.atan2(y, x)*180/PI : Math.atan2(y, x);
    }

    Function log = Math.log;

    double random([num a=1, num? b]) {
        return b == null ? mathRandom.nextDouble() * a : a + mathRandom.nextDouble() * (b - a);
    }

    double dist(num a, num b, num c, num d, [num? e, num? f]) {
        if (f == null || e == null) {
            return Math.sqrt(Math.pow(a - c, 2) + Math.pow(b - d, 2));
        } else {
            return Math.sqrt(Math.pow(a - d, 2) + Math.pow(b - e, 2) + Math.pow(c - f, 2));
        }
    }

    double map(num v, num istart, num istop, num ostart, num ostop) {
        return ostart + (ostop - ostart) * ((v - istart) / (istop - istart));
    }

    num lerp(num a, num b, num amt) {
        return (b - a) * amt + a;
    }

    double radians(num d) {
        return d*PI/180;
    }

    double degrees(num r) {
        return r*180/PI;
    }

    Color color(num r, [num? g, num? b, num a=255]) {
        if (curClrMode == RGB_) {
            return Color.fromRGB(r, g, b, a);
        } else /* if (curClrMode === HSB_) */ {
            if (g == null || b == null)
                throw "HSB color needs all parameters";
            return Color.fromHSB(r, g, b, a);
        }
    }

    Color lerpColor(Color c1, Color c2, num amt) {
        return new Color(
            lerp(c1.r, c2.r, amt),
            lerp(c1.g, c2.g, amt),
            lerp(c1.b, c2.b, amt),
            lerp(c1.a, c2.a, amt)
        );
    }

    void fill(Object r, [num? g, num? b, num? a]) {
        if (r is Color) {
            this._curFill = color(r.r, r.g, r.b, r.a);
        } else {
            r = r as num;
            if (g == null) {
                this._curFill = color(r, r, r, 255);
            } else if (b == null) {
                this._curFill = color(r, r, r, g);
            } else if (a == null) {
                this._curFill = color(r, g, b, 255);
            } else {
                this._curFill = color(r, g, b, a);
            }
        }
    }

    void stroke(Object r, [num? g, num? b, num? a]) {
        if (r is Color) {
            this._curStroke = color(r.r, r.g, r.b, r.a);
        } else {
            r = r as num;
            if (g == null) {
                this._curStroke = color(r, r, r, 255);
            } else if (b == null) {
                this._curStroke = color(r, r, r, g);
            } else if (a == null) {
                this._curStroke = color(r, g, b, 255);
            } else {
                this._curStroke = color(r, g, b, a);
            }
        }
    }

    void strokeWeight(num w) {
        _curStrokeWeight = w;
        ctx.lineWidth = w;
    }

    void strokeCap(String m) {
        ctx.lineCap = m;
    }

    void strokeJoin(String m) {
        ctx.lineJoin = m;
    }

    void noStroke() {
        _curStroke = null;
    }

    void noFill() {
        _curFill = null;
    }

    void beginShape([int type=UNDEFINED]) {
        shapePath = [];
        shapePathType = type;
    }

    void vertex(num x, num y) {
        shapePath.add((VERTEX_NODE, [x, y]));
    }

    void curveVertex(num cx, num cy, num x, num y) {
        shapePath.add((CURVE_VERTEX_NODE, [cx, cy, x, y]));
    }

    void bezierVertex(num cx, num cy, num cX, num cY, num x, num y) {
        shapePath.add((BEZIER_VERTEX_NODE, [cx, cy, cX, cY, x, y]));
    }

    num bezierPoint(num a, num b, num c, num d, num t) {
        return (1 - t) * (1 - t) * (1 - t) * a + 3 * (1 - t) * (1 - t) * t * b + 3 * (1 - t) * t * t * c + t * t * t * d;
    }

    num bezierTangent(num a, num b, num c, num d, num t) {
        return 3 * t * t * (-a + 3 * b - 3 * c + d) + 6 * t * (a - 2 * b + c) + 3 * (-a + b);
    }

    void splineTightness(num t) {
        _splineTightness = t;
    }

    void splineVertex(num x, num y) {
        shapePath.add((SPLINE_VERTEX_NODE, [x, y]));
    }

    num splinePoint(num a, num b, num c, num d, num t) {
        return 0.5 * ((2 * b) + (-a + c) * t + (2 * a - 5 * b + 4 * c - d) * Math.pow(t, 2) + (-a + 3 * b - 3 * c + d) * Math.pow(t, 3));
    }

    num splineTangent(num a, num b, num c, num d, num t) {
        return 0.5 * ((-a + c) + 2 * (2 * a - 5 * b + 4 * c - d) * t + 3 * (-a + 3 * b - 3 * c + d) * t * t);
    }

    (num, num) lerpSpline(List<List<num>>pts, num t) {
        final ptsLenMin3 = pts.length - 3;
        t = t / (pts.length - 1) * ptsLenMin3;
        var i = t.toInt();
        t -= i;

        if (i < 0) {
            pts = [pts[1], pts[1], pts[2], pts[3]];
        } else if (i < ptsLenMin3) {
            pts = [pts[i], pts[i+1], pts[i+2], pts[i+3]];
        } else {
            pts = [pts[ptsLenMin3], pts[ptsLenMin3+1], pts[ptsLenMin3+2], pts[ptsLenMin3+2]];
        }

        return (
            splinePoint(pts[0][0], pts[1][0], pts[2][0], pts[3][0], t),
            splinePoint(pts[0][1], pts[1][1], pts[2][1], pts[3][1], t)
        );
    }

    void endShape([int mode=UNDEFINED]) {
        final fillClr = this._curFill;
        final strokeClr = this._curStroke;
        if (fillClr != null)
            ctx.fillStyle = CSSColor(fillClr.r, fillClr.g, fillClr.b, fillClr.a / 255);
        if (strokeClr != null)
            ctx.strokeStyle = CSSColor(strokeClr.r, strokeClr.g, strokeClr.b, strokeClr.a / 255);

        var i;
        if (shapePathType == UNDEFINED) {
            void doPath() {
                ctx.beginPath();
                var isSplineCurve = false;
                for (i = 0; i < shapePath.length; i++) {
                    if (shapePath[i].$1 == SPLINE_VERTEX_NODE) {
                        isSplineCurve = true;
                        break;
                    }
                }
                if (isSplineCurve && shapePath.length > 3) {
                    // improved from Processing.js source
                    var s = 1 - _splineTightness;
                    ctx.moveTo(shapePath[1].$2[0], shapePath[1].$2[1]);
                    for (i = 1; i < shapePath.length - 2; i++) {
                        final cachedPrev = shapePath[i-1].$2;
                        final cachedPt = shapePath[i].$2;
                        final cachedNext = shapePath[i+1].$2;
                        final cachedNextNext = shapePath[i+2].$2;
                        ctx.bezierCurveTo(
                            cachedPt[0] + (s * cachedNext[0] - s * cachedPrev[0]) / 6,
                            cachedPt[1] + (s * cachedNext[1] - s * cachedPrev[1]) / 6,
                            cachedNext[0] + (s * cachedPt[0] - s * cachedNextNext[0]) / 6,
                            cachedNext[1] + (s * cachedPt[1] - s * cachedNextNext[1]) / 6,
                            cachedNext[0],
                            cachedNext[1]
                        );
                    }
                } else {
                    final moveToArgs = shapePath[0].$2;
                    ctx.moveTo(moveToArgs[0], moveToArgs[1]);
                    for (i = 1; i < shapePath.length; i++) {
                        final node = shapePath[i];
                        final args = node.$2;
                        switch (node.$1) {
                            case VERTEX_NODE_:
                                ctx.lineTo(args[0], args[1]);
                                break;
                            case CURVE_VERTEX_NODE_:
                                ctx.quadraticCurveTo(args[0], args[1], args[2], args[3]);
                                break;
                            case BEZIER_VERTEX_NODE_:
                                ctx.bezierCurveTo(args[0], args[1], args[2], args[3], args[4], args[5]);
                                break;
                        }
                    }
                }

                if (mode == CLOSE) ctx.closePath();
            }
            
            doPath();
            if (fillClr != null) ctx.fill();
            doPath();
            if (strokeClr != null) ctx.stroke();
        } else if (shapePathType == POINTS) {
            for (i = 0; i < shapePath.length; i++) {
                final args = shapePath[i].$2;
                point(args[0], args[1]);
            }
        } else if (shapePathType == LINES) {
            for (i = 0; i < shapePath.length - 1; i += 2) {
                final a = shapePath[i].$2,
                    b = shapePath[i + 1].$2;
                line(a[0], a[1], b[0], b[1]);
            }
        } else if (shapePathType == TRIANGLES) {
            for (i = 0; i < shapePath.length - 2; i += 3) {
                final a = shapePath[i].$2,
                    b = shapePath[i + 1].$2,
                    c = shapePath[i + 2].$2;
                triangle(a[0], a[1], b[0], b[1], c[0], c[1]);
            }
        } else if (shapePathType == TRIANGLE_STRIP) {
            for (i = 0; i < shapePath.length - 2; i++) {
                final a = shapePath[i].$2,
                    b = shapePath[i + 1].$2,
                    c = shapePath[i + 2].$2;
                triangle(a[0], a[1], b[0], b[1], c[0], c[1]);
            }
        } else if (shapePathType == TRIANGLE_FAN) {
            for (i = 1; i < shapePath.length - 1; i++) {
                final a = shapePath[0].$2,
                    b = shapePath[i].$2,
                    c = shapePath[i + 1].$2;
                triangle(a[0], a[1], b[0], b[1], c[0], c[1]);
            }
        } else if (shapePathType == QUADS) {
            for (i = 0; i < shapePath.length - 3; i += 4) {
                final a = shapePath[i].$2,
                    b = shapePath[i + 1].$2,
                    c = shapePath[i + 2].$2,
                    d = shapePath[i + 3].$2;
                quad(a[0], a[1], b[0], b[1], c[0], c[1], d[0], d[1]);
            }
        } else if (shapePathType == QUAD_STRIP) {
            for (i = 0; i < shapePath.length - 3; i += 2) {
                final a = shapePath[i].$2,
                    b = shapePath[i + 1].$2,
                    c = shapePath[i + 3].$2,
                    d = shapePath[i + 2].$2;
                quad(a[0], a[1], b[0], b[1], c[0], c[1], d[0], d[1]);
            }
        }
    }

    void spline(num a, num b, num c, num d, num e, num f, num g, num h) {
        beginShape();
        splineVertex(a, b);
        splineVertex(c, d);
        splineVertex(e, f);
        splineVertex(g, h);
        endShape();
    }

    DLImage snip([num? x, num? y, num? w, num? h]) {
        if (x == null) {
            x = 0;
            y = 0;
            w = this.width;
            h = this.height;
        }

        if (y == null || h == null || w == null) {
            throw "Drawlite.snip args cannot be null";
        }

        final snipImgData = ctx.getImageData(x, y, w, h);
        return new DLImage(snipImgData);
    }

    Color getColor(num x, num y) {
        final snipImgData = ctx.getImageData(x, y, 1, 1);
        final d = snipImgData.data;
        return new Color(d[0], d[1], d[2], d[3]);
    }

    void imageMode(int mode) {
        _curImgMode = mode;
    }

    void image(Object img, num x, num y, [num? w, num? h]) {
        if (img is DLImage) {
            w = img.width;
            h = img.height;
            img = img.sourceImage;
        } else if (img is Canvas) {
            w = img.width;
            h = img.height;
        } else {
            throw "Drawlite.image incorrect arguments recieved";
        }
        switch (_curImgMode) {
            case CENTER_:
                x -= w / 2;
                y -= h / 2;
                break;
            case CORNERS_:
                w -= x;
                h -= y;
                break;
        }
        ctx.drawImage(img as Canvas, x, y, w, h);
    }

    // loadImage = (src, callback) => {
    //     let img = new Image();
    //     img.src = src;
    //     return new Promise(resolve => {
    //         img.onload = function () {
    //             let DLImg = new DLImage(img);
    //             if (callback) callback(DLImg);
    //             resolve(DLImg);
    //         };
    //     });
    // },

    void font(String f, [num? sz]) {
        if (sz == null) {
            sz = _curFontSize;
        }
        ctx.font = calcFontString(f, sz);
        _curFontName = f;
        _curFontSize = sz.toDouble();
        _curTxtLeading = sz * 1.2;
        _curTxtAscent = ctx.measureText('|').actualBoundingBoxAscent;
        _curTxtDescent = ctx.measureText('|').actualBoundingBoxDescent;
    }

    void textSize(num sz) {
        ctx.font = calcFontString(_curFontName, sz);
        _curFontSize = sz.toDouble();
        _curTxtLeading = sz * 1.2;
        _curTxtAscent = ctx.measureText('|').actualBoundingBoxAscent;
        _curTxtDescent = ctx.measureText('|').actualBoundingBoxDescent;
    }

    void textAlign(int xAlign, [int yAlign=BASELINE_]) {
        _horTxtAlign = xAlign;
        _verTxtAlign = yAlign;
    }

    double textWidth(String str) {
        var width = 0.0;
        var arr = str.split(RegExp(r'\r?\n'));
        for (var i = 0; i < arr.length; i++) {
            var w = ctx.measureText(arr[i]).width;
            if (w > width) width = w;
        }
        return width;
    }

    num textAscent() {
        return _curTxtAscent;
    }

    num textDescent() {
        return _curTxtDescent;
    }

    num textLeading(num? n) {
        if (n != null)
            _curTxtLeading = n.toDouble();
        return _curTxtLeading;
    }

    void text(dynamic tObj, num x, num y, [num? w, num? h]) {
        final fillClr = this._curFill;
        if (fillClr != null)
            ctx.fillStyle = CSSColor(fillClr.r, fillClr.g, fillClr.b, fillClr.a / 255);     

        String t;
        if (tObj == null) {
            t = "null";
        } else {
            t = tObj.toString();
        }

        List<String> lines;        
        if (w != null) {
            lines = [];
            var words = t.split(" ");
            var i = 0;
            while (i < words.length) {
                var line = "";
                var j = i;
                while (textWidth(line + words[j]) < w && j < words.length) {
                    line += words[j++] + " ";
                }
                lines.add(line);
                i = j;
            }
        } else if (t.indexOf('\n') == -1) {
            lines = [t];
        } else {
            // handle both carriage returns and line feeds
            lines = t.split(RegExp(r"/\r?\n/g"));
        }

        var yOffset = 0.0;
        switch (_verTxtAlign) {
            case TOP_:
                yOffset = _curTxtAscent + _curTxtDescent;
                break;
            case CENTER_:
                yOffset = _curTxtAscent / 2 - (lines.length - 1) * _curTxtLeading / 2;
                break;
            case BOTTOM_:
                yOffset = -(_curTxtDescent + (lines.length - 1) * _curTxtLeading);
                break;
        }

        for (var i = 0, len = lines.length; i < len; ++i) {
            textLine(lines[i], x, y + yOffset, _horTxtAlign);
            yOffset += _curTxtLeading;
        }
    }

    void background(Object r, [num? g, num? b, num? a]) {
        if (r is Color) {
            ctx.fillStyle = CSSColor(r.r, r.g, r.b, r.a / 255.0);
        } else {
            r = r as num;
            if (g == null) {
                final ir = r.toInt();
                ctx.fillStyle = CSSColor(ir, ir, ir, 1.0);
            } else if (b == null) {
                final ir = r.toInt();
                ctx.fillStyle = CSSColor(ir, ir, ir, g / 255.0);
            } else if (a == null) {
                final ir = r.toInt();
                final ig = g.toInt();
                final ib = b.toInt();
                ctx.fillStyle = CSSColor(ir, ig, ib, 1.0);
            } else {
                final ir = r.toInt();
                final ig = g.toInt();
                final ib = b.toInt();
                ctx.fillStyle = CSSColor(ir, ig, ib, a / 255.0);
            }
        }
        if ((ctx.fillStyle as CSSColor).a == 0.0) {
            ctx.clearRect(0, 0, this.width, this.height);
        } else {
            ctx.fillRect(0, 0, this.width, this.height);
        }
    }

    void point(num x, num y) {
        final strokeClr = this._curStroke;
        if (strokeClr != null)
            ctx.fillStyle = CSSColor(strokeClr.r, strokeClr.g, strokeClr.b, strokeClr.a / 255);

        ctx.beginPath();
        ctx.arc(x, y, _curStrokeWeight / 2, 0, TWO_PI);

        if (strokeClr != null) ctx.fill();
    }

    void line(num ax, num ay, num bx, num by) {
        final strokeClr = this._curStroke;
        if (strokeClr != null)
            ctx.strokeStyle = CSSColor(strokeClr.r, strokeClr.g, strokeClr.b, strokeClr.a / 255);

        ctx.beginPath();
        ctx.moveTo(ax, ay);
        ctx.lineTo(bx, by);

        ctx.stroke();
    }

    void rectMode(int m) {
        _curRectMode = m;
    }

    void rect(num x, num y, num w, num h, [num? r1, num? r2, num? r3, num? r4]) {
        final fillClr = this._curFill;
        final strokeClr = this._curStroke;
        if (fillClr != null)
            ctx.fillStyle = CSSColor(fillClr.r, fillClr.g, fillClr.b, fillClr.a / 255);
        if (strokeClr != null)
            ctx.strokeStyle = CSSColor(strokeClr.r, strokeClr.g, strokeClr.b, strokeClr.a / 255);

        switch (_curRectMode) {
            case CENTER_:
                x -= w / 2;
                y -= h / 2;
                break;
            case CORNERS_:
                w -= x;
                h -= y;
                break;
            case RADIUS_:
                w *= 2;
                h *= 2;
                x -= w / 2;
                y -= h / 2;
                break;
        }

        if (r1 == null) {
            if (fillClr != null)
                ctx.fillRect(x, y, w, h);
            if (strokeClr != null)
                ctx.strokeRect(x + 0.5, y + 0.5, w, h);
        } else {
            ctx.beginPath();
            List<num> corners;
            if (r2 == null) {
                corners = [r1, r1, r1, r1];
            } else if (r3 == null) {
                corners = [r1, r2, 0, 0];
            } else if (r4 == null) {
                corners = [r1, r2, r3, 0];
            } else {
                corners = [r1, r2, r3, r4];
            }

            // TODO: figure out why I have to repeat this
            ctx.roundRect(x, y, w, h, corners);
            if (fillClr != null) ctx.fill();

            // must stroke before fill for some reason?
            ctx.roundRect(x, y, w, h, corners);
            if (strokeClr != null) ctx.stroke();
        }
    }

    void triangle(num x1, num y1, num x2, num y2, num x3, num y3) {
        final fillClr = this._curFill;
        final strokeClr = this._curStroke;
        if (fillClr != null)
            ctx.fillStyle = CSSColor(fillClr.r, fillClr.g, fillClr.b, fillClr.a / 255);
        if (strokeClr != null)
            ctx.strokeStyle = CSSColor(strokeClr.r, strokeClr.g, strokeClr.b, strokeClr.a / 255);

        ctx.beginPath();
        ctx.moveTo(x1, y1);
        ctx.lineTo(x2, y2);
        ctx.lineTo(x3, y3);
        ctx.closePath();

        if (fillClr != null) ctx.fill();
        if (strokeClr != null) ctx.stroke();
    }

    void quad(num x1, num y1, num x2, num y2, num x3, num y3, num x4, num y4) {
        final fillClr = this._curFill;
        final strokeClr = this._curStroke;
        if (fillClr != null)
            ctx.fillStyle = CSSColor(fillClr.r, fillClr.g, fillClr.b, fillClr.a / 255);
        if (strokeClr != null)
            ctx.strokeStyle = CSSColor(strokeClr.r, strokeClr.g, strokeClr.b, strokeClr.a / 255);

        ctx.beginPath();
        ctx.moveTo(x1, y1);
        ctx.lineTo(x2, y2);
        ctx.lineTo(x3, y3);
        ctx.lineTo(x4, y4);
        ctx.closePath();
        if (fillClr != null) ctx.fill();

        // TODO: figure out why I have to repeat this
        ctx.beginPath();
        ctx.moveTo(x1, y1);
        ctx.lineTo(x2, y2);
        ctx.lineTo(x3, y3);
        ctx.lineTo(x4, y4);
        ctx.closePath();
        if (strokeClr != null) ctx.stroke();
    }

    void arc(num x, num y, num w, num h, num st, num sp) {
        final fillClr = this._curFill;
        final strokeClr = this._curStroke;
        if (fillClr != null)
            ctx.fillStyle = CSSColor(fillClr.r, fillClr.g, fillClr.b, fillClr.a / 255);
        if (strokeClr != null)
            ctx.strokeStyle = CSSColor(strokeClr.r, strokeClr.g, strokeClr.b, strokeClr.a / 255);

        w /= 2;
        h /= 2;

        ctx.beginPath();
        ctx.moveTo(x, y);
        for (var i = st; i < sp; i++) {
            ctx.lineTo(x + cos(i) * w, y + sin(i) * h);
        }

        if (fillClr != null) ctx.fill();


        ctx.beginPath();
        ctx.moveTo(x + cos(st) * w, y + sin(st) * h);
        for (var i = st; i < sp; i++) {
            ctx.lineTo(x + cos(i) * w, y + sin(i) * h);
        }

        if (strokeClr != null) ctx.stroke();
    }

    void circle(num x, num y, num d) {
        final fillClr = this._curFill;
        final strokeClr = this._curStroke;
        if (fillClr != null)
            ctx.fillStyle = CSSColor(fillClr.r, fillClr.g, fillClr.b, fillClr.a / 255);
        if (strokeClr != null)
            ctx.strokeStyle = CSSColor(strokeClr.r, strokeClr.g, strokeClr.b, strokeClr.a / 255);

        ctx.beginPath();
        ctx.arc(x, y, d / 2, 0, TWO_PI);

        if (fillClr != null) ctx.fill();
        if (strokeClr != null) ctx.stroke();
    }

    void ellipseMode(int m) {
        _curEllipseMode = m;
    }

    void ellipse(num x, num y, num w, num h) {
        final fillClr = this._curFill;
        final strokeClr = this._curStroke;
        if (fillClr != null)
            ctx.fillStyle = CSSColor(fillClr.r, fillClr.g, fillClr.b, fillClr.a / 255);
        if (strokeClr != null)
            ctx.strokeStyle = CSSColor(strokeClr.r, strokeClr.g, strokeClr.b, strokeClr.a / 255);

        void pathIt() {
            ctx.beginPath();

            switch (_curEllipseMode) {
                case CENTER_:
                    ctx.ellipse(x, y, w / 2, h / 2, 0, 0, TWO_PI);
                    break;
                case RADIUS_:
                    ctx.ellipse(x, y, w, h, 0, 0, TWO_PI);
                    break;
                case CORNER_:
                    w /= 2;
                    h /= 2;
                    ctx.ellipse(w + x, h + y, w, h, 0, 0, TWO_PI);
                    break;
                case CORNERS_:
                    w = (w - x) / 2;
                    h = (h - y) / 2;
                    ctx.ellipse(w / 2 + x, h / 2 + y, w, h, 0, 0, TWO_PI);
                    break;
                default: // defaults to CENTER
                    ctx.ellipse(x, y, w / 2, h / 2, 0, 0, TWO_PI);
                    break;
            }
        }
        pathIt();

        if (fillClr != null) ctx.fill();

        pathIt(); // TODO: figure out why I have to repeat this
        if (strokeClr != null) ctx.stroke();
    }

    void bezier(num a, num b, num c, num d, num e, num f, num g, num h) {
        final fillClr = this._curFill;
        final strokeClr = this._curStroke;
        if (fillClr != null)
            ctx.fillStyle = CSSColor(fillClr.r, fillClr.g, fillClr.b, fillClr.a / 255);
        if (strokeClr != null)
            ctx.strokeStyle = CSSColor(strokeClr.r, strokeClr.g, strokeClr.b, strokeClr.a / 255);

        ctx.beginPath();
        ctx.moveTo(a, b);
        ctx.bezierCurveTo(c, d, e, f, g, h);

        if (fillClr != null) ctx.fill();
        if (strokeClr != null) ctx.stroke();
    }

    GetObject get = GetObject();

    void updateDynamics() {
        this.get.width = this.width;
        this.get.height = this.height;
        this.get.frameCount = this.frameCount;
        this.get.FPS = this.FPS;
        this.get.pmouseX = this.pmouseX;
        this.get.pmouseY = this.pmouseY;
        this.get.mouseX = this.mouseX;
        this.get.mouseY = this.mouseY;
        this.get.mouseIsPressed = this.mouseIsPressed;
        this.get.mouseButton = this.mouseButton;
        this.get.keyIsPressed = this.keyIsPressed;
        // this.get.imageData = this.imageData;
        this.get.focused = this.focused;
    }

    void pushMatrix() {
        ctx.save();
    }

    void popMatrix() {
        ctx.restore();
    }

    void resetMatrix() {
        ctx.resetTransform();
    }

    void scale(num w, [num? h]) {
        if (h == null) {
            ctx.scale(w, w);
        } else {
            ctx.scale(w, h);
        }
    }

    void translate(num x, num y) {
        ctx.translate(x, y);
    }

    void rotate(num a) {
        if (_curAngleMode == DEGREES) ctx.rotate(a*PI/180);
        if (_curAngleMode == RADIANS) ctx.rotate(a);
    }

    // loadPixels = () => {
    //     D.imageData.data.set(ctx.getImageData(0, 0, D.width, D.height).data);
    // },

    // updatePixels = () => {
    //     ctx.putImageData(D.imageData, 0, 0);
    // },

    void colorMode(int m) {
        curClrMode = m;
    }

    int millis() {
        return DateTime.now().millisecondsSinceEpoch;
    }

    int second() {
        return DateTime.now().second;
    }

    int minute() {
        return DateTime.now().minute;
    }

    int hour() {
        return DateTime.now().hour;
    }

    int day() {
        return DateTime.now().day;
    }

    int month() {
        return DateTime.now().month;
    }

    int year() {
        return DateTime.now().year;
    }

    // smooth = () => {
    //     ctx.imageSmoothingEnabled = true;
    //     canvas.style.setProperty("image-rendering", "optimizeQuality", "important");
    // },

    // nosmooth = () => {
    //     ctx.imageSmoothingEnabled = false;
    //     canvas.style.setProperty("image-rendering", "pixelated", "important");
    // },

    // createGraphics = (width, height, type) => {
    //     let canvas = document.createElement("canvas");
    //     canvas.width = width;
    //     canvas.height = height;
    //     return new Drawlite(canvas);
    // };

    // // STATIC VARIABLES
    // Object.assign(D, {
    //     canvas,
    //     Color,
    //     PerlinNoise,
    //     PRNG,
    //     vec3,
    //     ctx,
    // });
}
