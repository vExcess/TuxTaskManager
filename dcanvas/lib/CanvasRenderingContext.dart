import 'dart:typed_data';
import 'dart:math' as Math;
import './CanvasPattern.dart';
import './utils.dart';
import './Canvas.dart';
import './backend/Backend.dart';
import './color.dart';
import './font.dart' show ParsedFont, parseFontString, TextMetrics;
import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart';

class DOMPoint {
    late double x, y;
    DOMPoint(this.x, this.y);
    DOMPoint clone() {
        return DOMPoint(x, y);
    }
    String toString() {
        return "DOMPoint($x, $y)";
    }
}

class ImageData {
    late Uint8List data;
    late int width;
    late int height;
    ImageData(this.data, this.width, this.height);
}

sealed class FillInfo {}

class CSSColor extends FillInfo {
    int r, g, b;
    double a;
    CSSColor(this.r, this.g, this.b, this.a);
    String toString() {
        return "rgba($r, $g, $b, ${a.toStringAsFixed(2)})";
    }
}

class CanvasGradient extends FillInfo {
    double x0, y0, x1, y1;
    List<CSSColor> colors = [];
    List<double> stops = [];

    CanvasGradient(this.x0, this.y0, this.x1, this.y1);
    
    void addColorStop(double offset, CSSColor color) {
        this.stops.add(offset);
        this.colors.add(color);
    }
}

class CanvasPattern extends FillInfo {
    late Object image;
    late repeat_type_t repetition;
    
    CanvasPattern(Object image, String repetition) {
        this.image = image;
        switch (repetition) {
            case "repeat":
                this.repetition = RepeatType.REPEAT;
            case "repeat-x":
                this.repetition = RepeatType.REPEAT_X;
            case "repeat-y":
                this.repetition = RepeatType.REPEAT_Y;
            case "no-repeat":
                this.repetition = RepeatType.NO_REPEAT;
            default:
                this.repetition = RepeatType.REPEAT;
        }
    }
}

// typedef cairo_filter = int;
class CanvasState {
    RGBA fill = RGBA(0, 0, 0, 1);
    RGBA stroke = RGBA(0, 0, 0, 1);
    RGBA shadow = RGBA(0, 0, 0, 0);
    double shadowOffsetX = 0.0;
    double shadowOffsetY = 0.0;
    ffi.Pointer<cairo_pattern_t> fillPattern = ffi.nullptr;
    ffi.Pointer<cairo_pattern_t> strokePattern = ffi.nullptr;
    ffi.Pointer<cairo_pattern_t> fillGradient = ffi.nullptr;
    ffi.Pointer<cairo_pattern_t> strokeGradient = ffi.nullptr;
    ffi.Pointer<PangoFontDescription> fontDescription = ffi.nullptr;
    String font = "10px sans-serif";
    cairo_filter patternQuality = cairo_filter.CAIRO_FILTER_GOOD;
    double globalAlpha = 1.0;
    int shadowBlur = 0;
    text_align_t textAlignment = TextAlign.TEXT_ALIGNMENT_LEFT; // TODO default is supposed to be START
    text_baseline_t textBaseline = TextBaseline.TEXT_BASELINE_ALPHABETIC;
    canvas_draw_mode_t textDrawingMode = CanvasDrawMode.TEXT_DRAW_PATHS;
    bool imageSmoothingEnabled = true;

    CanvasState([final CanvasState? orig]) {
        if (orig != null) {
            fill = orig.fill.clone();
            stroke = orig.stroke.clone();
            patternQuality = orig.patternQuality;
            fillPattern = ffi.Pointer.fromAddress(orig.fillPattern.address);
            strokePattern = ffi.Pointer.fromAddress(orig.strokePattern.address);
            fillGradient = ffi.Pointer.fromAddress(orig.fillGradient.address);
            strokeGradient = ffi.Pointer.fromAddress(orig.strokeGradient.address);
            globalAlpha = orig.globalAlpha;
            textAlignment = orig.textAlignment;
            textBaseline = orig.textBaseline;
            shadow = orig.shadow.clone();
            shadowBlur = orig.shadowBlur;
            shadowOffsetX = orig.shadowOffsetX;
            shadowOffsetY = orig.shadowOffsetY;
            textDrawingMode = orig.textDrawingMode;
            fontDescription = pango.pango_font_description_copy(orig.fontDescription);
            font = orig.font;
            imageSmoothingEnabled = orig.imageSmoothingEnabled;
        } else {
            final fontname = "sans".toNativeUtf8();
            fontDescription = pango.pango_font_description_from_string(fontname.cast());
            pango.pango_font_description_set_absolute_size(fontDescription, 10.0 * PANGO_SCALE);
            malloc.free(fontname);
        }
    }
}

const f64Width = 8 /*ffi.sizeOf<ffi.Double>()*/; // set to literal for micro optimization

/*
 * Create temporary surface for gradient or pattern transparency
 */
ffi.Pointer<cairo_pattern_t> create_transparent_gradient(ffi.Pointer<cairo_pattern_t> source, double alpha) {
    final chunk = malloc.allocate(12 * f64Width);
    final CA = chunk.address;
    ffi.Pointer<ffi.Double> x0 = ffi.Pointer.fromAddress(CA + f64Width * 0);
    ffi.Pointer<ffi.Double> y0 = ffi.Pointer.fromAddress(CA + f64Width * 1);
    ffi.Pointer<ffi.Double> x1 = ffi.Pointer.fromAddress(CA + f64Width * 2);
    ffi.Pointer<ffi.Double> y1 = ffi.Pointer.fromAddress(CA + f64Width * 3);
    ffi.Pointer<ffi.Double> r0 = ffi.Pointer.fromAddress(CA + f64Width * 4);
    ffi.Pointer<ffi.Double> r1 = ffi.Pointer.fromAddress(CA + f64Width * 5);
    ffi.Pointer<ffi.Int> count = ffi.Pointer.fromAddress(CA + f64Width * 6);
    ffi.Pointer<ffi.Double> offset = ffi.Pointer.fromAddress(CA + f64Width * 7);
    ffi.Pointer<ffi.Double> r = ffi.Pointer.fromAddress(CA + f64Width * 8);
    ffi.Pointer<ffi.Double> g = ffi.Pointer.fromAddress(CA + f64Width * 9);
    ffi.Pointer<ffi.Double> b = ffi.Pointer.fromAddress(CA + f64Width * 10);
    ffi.Pointer<ffi.Double> a = ffi.Pointer.fromAddress(CA + f64Width * 11);
    ffi.Pointer<cairo_pattern_t> newGradient;
    cairo_pattern_type type = cairo.cairo_pattern_get_type(source);
    cairo.cairo_pattern_get_color_stop_count(source, count);
    if (type == cairo_pattern_type.CAIRO_PATTERN_TYPE_LINEAR) {
        cairo.cairo_pattern_get_linear_points(source, x0, y0, x1, y1);
        newGradient = cairo.cairo_pattern_create_linear(x0.value, y0.value, x1.value, y1.value);
    } else if (type == cairo_pattern_type.CAIRO_PATTERN_TYPE_RADIAL) {
        cairo.cairo_pattern_get_radial_circles(source, x0, y0, r0, x1, y1, r1);
        newGradient = cairo.cairo_pattern_create_radial(x0.value, y0.value, r0.value, x1.value, y1.value, r1.value);
    } else {
        return ffi.nullptr;
    }
    for (int i = 0; i < count.value; i++ ) {
        cairo.cairo_pattern_get_color_stop_rgba(source, i, offset, r, g, b, a);
        cairo.cairo_pattern_add_color_stop_rgba(newGradient, offset.value, r.value, g.value, b.value, a.value * alpha);
    }
    malloc.free(chunk);
    return newGradient;
}

ffi.Pointer<cairo_pattern_t> create_transparent_pattern(ffi.Pointer<cairo_pattern_t> source, double alpha) {
    var surface = malloc<ffi.Pointer<cairo_surface_t>>();
    cairo.cairo_pattern_get_surface(source, surface);
    int width = cairo.cairo_image_surface_get_width(surface.value);
    int height = cairo.cairo_image_surface_get_height(surface.value);
    ffi.Pointer<cairo_surface_t> mask_surface = cairo.cairo_image_surface_create(
        cairo_format.CAIRO_FORMAT_ARGB32,
        width,
        height
    );
    ffi.Pointer<cairo_t> mask_context = cairo.cairo_create(mask_surface);
    if (cairo.cairo_status(mask_context) != cairo_status.CAIRO_STATUS_SUCCESS) {
        return ffi.nullptr;
    }
    cairo.cairo_set_source(mask_context, source);
    cairo.cairo_paint_with_alpha(mask_context, alpha);
    cairo.cairo_destroy(mask_context);
    ffi.Pointer<cairo_pattern_t> newPattern = cairo.cairo_pattern_create_for_surface(mask_surface);
    cairo.cairo_surface_destroy(mask_surface);
    return newPattern;
}

bool isfinite(double n) {
    return !(n == double.infinity || n == double.negativeInfinity || n.isNaN);
}

@pragma("vm:prefer-inline")
bool getRadius(DOMPoint p, final Object v) {
    if (v is num) {
        double rv = v.toDouble();
        if (!isfinite(rv)) {
            return true;
        }
        if (rv < 0) {
            throw "radii must be positive.";
        }
        p.x = p.y = rv;
        return false;
    } else if (v is DOMPoint) { // 5.1 DOMPointInit
        double rx;
        double ry;
        var rxMaybe = v.x;
        var ryMaybe = v.y;
        if ((rx = rxMaybe) != 0.0 && (ry = ryMaybe) != 0.0) {
            var rxv = rx;
            var ryv = ry;
            if (!isfinite(rxv) || !isfinite(ryv)) {
                return true;
            }
            if (rxv < 0 || ryv < 0) {
                throw "radii must be positive.";
            }
            p.x = rxv;
            p.y = ryv;
            return false;
        }
    }
    return true;
}

// Draws an arc with two potentially different radii.
@pragma("vm:prefer-inline")
void elli_arc(ffi.Pointer<cairo_t> ctx, double xc, double yc, double rx, double ry, double a1, double a2, [bool clockwise=true]) {
    if (rx == 0.0 || ry == 0.0) {
        cairo.cairo_line_to(ctx, xc + rx, yc + ry);
    } else {
        cairo.cairo_save(ctx);
        cairo.cairo_translate(ctx, xc, yc);
        cairo.cairo_scale(ctx, rx, ry);
        if (clockwise) {
            cairo.cairo_arc(ctx, 0.0, 0.0, 1.0, a1, a2);
        } else {
            cairo.cairo_arc_negative(ctx, 0.0, 0.0, 1.0, a2, a1);
        }
        cairo.cairo_restore(ctx);
    }
}

double M_PI = 3.14159265358979323846;
double twoPi = M_PI * 2.0;

// Adapted from https://chromium.googlesource.com/chromium/blink/+/refs/heads/main/Source/modules/canvas2d/CanvasPathMethods.cpp
(double, double) canonicalizeAngle(double startAngle, double endAngle) {
    // Make 0 <= startAngle < 2*PI
    double newStartAngle = startAngle % twoPi;
    if (newStartAngle < 0) {
        newStartAngle += twoPi;
        // Check for possible catastrophic cancellation in cases where
        // newStartAngle was a tiny negative number (c.f. crbug.com/503422)
        if (newStartAngle >= twoPi)
            newStartAngle -= twoPi;
    }
    double delta = newStartAngle - startAngle;
    startAngle = newStartAngle;
    endAngle = endAngle + delta;
    return (startAngle, endAngle);
}

// Adapted from https://chromium.googlesource.com/chromium/blink/+/refs/heads/main/Source/modules/canvas2d/CanvasPathMethods.cpp
double adjustEndAngle(double startAngle, double endAngle, bool counterclockwise) {
    double newEndAngle = endAngle;
    /* http://www.whatwg.org/specs/web-apps/current-work/multipage/the-canvas-element.html#dom-context-2d-arc
    * If the counterclockwise argument is false and endAngle-startAngle is equal to or greater than 2pi, or,
    * if the counterclockwise argument is true and startAngle-endAngle is equal to or greater than 2pi,
    * then the arc is the whole circumference of this ellipse, and the point at startAngle along this circle's circumference,
    * measured in radians clockwise from the ellipse's semi-major axis, acts as both the start point and the end point.
    */
    if (!counterclockwise && endAngle - startAngle >= twoPi)
        newEndAngle = startAngle + twoPi;
    else if (counterclockwise && startAngle - endAngle >= twoPi)
        newEndAngle = startAngle - twoPi;
    /*
    * Otherwise, the arc is the path along the circumference of this ellipse from the start point to the end point,
    * going anti-clockwise if the counterclockwise argument is true, and clockwise otherwise.
    * Since the points are on the ellipse, as opposed to being simply angles from zero,
    * the arc can never cover an angle greater than 2pi radians.
    */
    /* NOTE: When startAngle = 0, endAngle = 2Pi and counterclockwise = true, the spec does not indicate clearly.
    * We draw the entire circle, because some web sites use arc(x, y, r, 0, 2*Math.PI, true) to draw circle.
    * We preserve backward-compatibility.
    */
    else if (!counterclockwise && startAngle > endAngle)
        newEndAngle = startAngle + (twoPi - ((startAngle - endAngle) % twoPi));
    else if (counterclockwise && startAngle < endAngle)
        newEndAngle = startAngle - (twoPi - ((endAngle - startAngle) % twoPi));
    return newEndAngle;
}

/*
 * Helper for fillText/strokeText
 */
double get_text_scale(ffi.Pointer<PangoLayout> layout, double maxWidth) {
    ffi.Pointer<PangoRectangle> logical_rect = malloc<PangoRectangle>();
    pango.pango_layout_get_pixel_extents(layout, ffi.nullptr, logical_rect);

    final logicalRectWidth = logical_rect.ref.width;
    malloc.free(logical_rect);
    if (logicalRectWidth > maxWidth) {
        return maxWidth / logicalRectWidth;
    } else {
        return 1.0;
    }
}

/*
 * Gets the baseline adjustment in device pixels
 */
@pragma("vm:prefer-inline")
double getBaselineAdjustment(ffi.Pointer<PangoLayout> layout, int baseline) {
    var logical_rect = malloc<PangoRectangle>();
    pango.pango_layout_line_get_extents(pango.pango_layout_get_line(layout, 0), ffi.nullptr, logical_rect);

    double scale = 1.0 / PANGO_SCALE;
    double ascent = scale * pango.pango_layout_get_baseline(layout);
    double descent = scale * logical_rect.ref.height - ascent;

    malloc.free(logical_rect);
    switch (baseline) {
        case TextBaseline.TEXT_BASELINE_ALPHABETIC:
            return ascent;
        case TextBaseline.TEXT_BASELINE_MIDDLE:
            return (ascent + descent) / 2.0;
        case TextBaseline.TEXT_BASELINE_BOTTOM:
            return ascent + descent;
        default:
            return 0;
    }
}

/*
 * Take a transform matrix and return its components
 * 0: angle, 1: scaleX, 2: scaleY, 3: skewX, 4: translateX, 5: translateY
 */
void decompose_matrix(cairo_matrix_t matrix, List<double> destination) {
    double denom = (Math.pow(matrix.xx, 2) + Math.pow(matrix.yx, 2)).toDouble();
    destination[0] = Math.atan2(matrix.yx, matrix.xx);
    destination[1] = Math.sqrt(denom);
    destination[2] = (matrix.xx * matrix.yy - matrix.xy * matrix.yx) / destination[1];
    destination[3] = Math.atan2(matrix.xx * matrix.xy + matrix.yx * matrix.yy, denom);
    destination[4] = matrix.x0;
    destination[5] = matrix.y0;
}

void memset(ffi.Pointer<ffi.Void> arr, int val, int size) {
    var bytes = arr.cast<ffi.Uint8>();
    for (int i = 0; i < size; i++) {
        bytes[i] = val;
    }
}

void memcpy(ffi.Pointer<ffi.Void> arr, ffi.Pointer<ffi.Void> srcPtr, int size) {
    var dest = arr.cast<ffi.Uint8>();
    var src = srcPtr.cast<ffi.Uint8>();
    for (int i = 0; i < size; i++) {
        dest[i] = src[i];
    }
}

/*
 * Equivalent to a PangoRectangle but holds floats instead of ints
 * (software pixels are stored here instead of pango units)
 *
 * Should be compatible with PANGO_ASCENT, PANGO_LBEARING, etc.
 */
class FloatRectangle {
    late double x;
    late double y;
    late double width;
    late double height;
    FloatRectangle();
}

class Context2D {
    Stack<CanvasState> states = Stack<CanvasState>();
    CanvasState state = CanvasState();
    late Canvas canvas;
    ffi.Pointer<cairo_t> _context = ffi.nullptr;
    late ffi.Pointer<cairo_path_t> _path;
    late ffi.Pointer<PangoLayout> _layout = ffi.nullptr;

    FillInfo _fillStyle = CSSColor(0, 0, 0, 1);
    FillInfo _strokeStyle = CSSColor(0, 0, 0, 1);

    // void setContext(cairo_t* ctx) { this._context = ctx; }

    Context2D(Canvas canvas, Map<String, Object> ctxAttribs) {
        this.canvas = canvas;

        bool isImageBackend = canvas.backend().getName() == "image";
        if (isImageBackend) {
            cairo_format format = Backend.DEFAULT_FORMAT;

            final pixelFormat = ctxAttribs["pixelFormat"];
            if (pixelFormat is String) {
                String utf8PixelFormat = pixelFormat;
                if (utf8PixelFormat == "RGBA32") {
                    format = cairo_format.CAIRO_FORMAT_ARGB32;
                } else if (utf8PixelFormat == "RGB24") {
                    format = cairo_format.CAIRO_FORMAT_RGB24;
                } else if (utf8PixelFormat == "A8") {
                    format = cairo_format.CAIRO_FORMAT_A8;
                } else if (utf8PixelFormat == "RGB16_565") {
                    format = cairo_format.CAIRO_FORMAT_RGB16_565;
                } else if (utf8PixelFormat == "A1") {
                    format = cairo_format.CAIRO_FORMAT_A1;
                }
            }

            // alpha: false forces use of RGB24
            final alpha = ctxAttribs["alpha"];
            if (alpha is bool && !alpha) {
                format = cairo_format.CAIRO_FORMAT_RGB24;
            }

            canvas.backend().setFormat(format);
        }

        _context = canvas.createCairoContext();
        _layout = pango.pango_cairo_create_layout(_context.cast());

        // As of January 2023, Pango rounds glyph positions which renders text wider
        // or narrower than the browser. See #2184 for more information
        final FALSE = 0;
        pango.pango_context_set_round_glyph_positions(pango.pango_layout_get_context(_layout), FALSE);

        states.push(CanvasState());
        state = states.top();
        pango.pango_layout_set_font_description(_layout, state.fontDescription);
    }

    /*
    * Destroy cairo context.
    */
    void free() {
        if (_layout != ffi.nullptr) malloc.free(_layout);
        if (_context != ffi.nullptr) cairo.cairo_destroy(_context);
    }

    /*
    * Save flat path.
    */
    void savePath() {
        _path = cairo.cairo_copy_path_flat(_context);
        cairo.cairo_new_path(_context);
    }

    /*
    * Set source RGBA for the current context
    */
    void setSourceRGBA(RGBA color) {
        setCtxSourceRGBA(_context, color);
    }

    /*
    * Set source RGBA
    */
    void setCtxSourceRGBA(ffi.Pointer<cairo_t> ctx, RGBA color) {
        cairo.cairo_set_source_rgba(
            ctx, 
            color.r, 
            color.g, 
            color.b, 
            color.a * state.globalAlpha);
    }

    /*
    * Check if the context has a drawable shadow.
    */
    bool hasShadow() {
        return state.shadow.a != 0.0
            && (state.shadowBlur != 0 || state.shadowOffsetX != 0 || state.shadowOffsetY != 0);
    }

    /*
    * Blur the given surface with the given radius.
    */
    void blur(ffi.Pointer<cairo_surface_t> surface, int radius) {
        // Steve Hanov, 2009
        // Released into the public domain.
        radius = (radius * 0.57735 + 0.5).toInt();
        // get width, height
        int width = cairo.cairo_image_surface_get_width( surface );
        int height = cairo.cairo_image_surface_get_height( surface );
        final int size = width * height * ffi.sizeOf<ffi.Uint32>();
        var precalc = malloc<ffi.Uint32>(size);
        cairo.cairo_surface_flush( surface );
        var src = cairo.cairo_image_surface_get_data( surface );
        double mul=1.0/((radius*2)*(radius*2));
        int channel;

        // The number of times to perform the averaging. According to wikipedia,
        // three iterations is good enough to pass for a gaussian.
        const int MAX_ITERATIONS = 3;
        int iteration;

        for ( iteration = 0; iteration < MAX_ITERATIONS; iteration++ ) {
            for( channel = 0; channel < 4; channel++ ) {
                int x,y;

                // precomputation step.
                ffi.Pointer<ffi.UnsignedChar> pix = src;
                ffi.Pointer<ffi.Uint32> pre = precalc;
                var preIdx = 0;

                bool modified = false;

                pix += channel;
                for (y=0;y<height;y++) {
                    for (x=0;x<width;x++) {
                        int tot=pix[0];
                        if (x>0) tot+=pre[preIdx-1];
                        if (y>0) tot+=pre[preIdx-width];
                        if (x>0 && y>0) tot-=pre[-width-1];
                        preIdx += 1;
                        pre[preIdx] = tot;
                        if (!modified) modified = true;
                        pix += 4;
                    }
                }

                if (!modified) {
                    memset(precalc.cast<ffi.Void>(), 0, size);
                }

                // blur step.
                pix = src + radius * width * 4 + radius * 4 + channel;
                for (y=radius;y<height-radius;y++) {
                    for (x=radius;x<width-radius;x++) {
                        int l = x < radius ? 0 : x - radius;
                        int t = y < radius ? 0 : y - radius;
                        int r = x + radius >= width ? width - 1 : x + radius;
                        int b = y + radius >= height ? height - 1 : y + radius;
                        int tot = precalc[r+b*width] + precalc[l+t*width] -
                            precalc[l+b*width] - precalc[r+t*width];
                        pix.value = (tot*mul).toInt();
                        pix += 4;
                    }
                    pix += radius * 2 * 4;
                }
            }
        }

        cairo.cairo_surface_mark_dirty(surface);
        malloc.free(precalc);
    }

    /*
    * Apply shadow with the given draw fn.
    */
    void shadow(void Function(ffi.Pointer<cairo_t> cr) fn) {
        ffi.Pointer<cairo_path_t> path = cairo.cairo_copy_path_flat(_context);
        cairo.cairo_save(_context);

        // shadowOffset is unaffected by current transform
        final path_matrixPtr = malloc<cairo_matrix_t>();
        // ptr.value = path_matrix;
        cairo.cairo_get_matrix(_context, path_matrixPtr);
        cairo.cairo_identity_matrix(_context);

        // Apply shadow
        cairo.cairo_push_group(_context);

        // No need to invoke blur if shadowBlur is 0
        if (state.shadowBlur != 0) {
            // find out extent of path
            final chunk = malloc.allocate(7 * f64Width);
            final CA = chunk.address;
            ffi.Pointer<ffi.Double> x1 = ffi.Pointer.fromAddress(CA + f64Width * 0);
            ffi.Pointer<ffi.Double> y1 = ffi.Pointer.fromAddress(CA + f64Width * 1);
            ffi.Pointer<ffi.Double> x2 = ffi.Pointer.fromAddress(CA + f64Width * 2);
            ffi.Pointer<ffi.Double> y2 = ffi.Pointer.fromAddress(CA + f64Width * 3);
            if (fn == cairo.cairo_fill || fn == cairo.cairo_fill_preserve) {
                cairo.cairo_fill_extents(_context, x1, y1, x2, y2);
            } else {
                cairo.cairo_stroke_extents(_context, x1, y1, x2, y2);
            }

            // create new image surface that size + padding for blurring
            ffi.Pointer<ffi.Double> dx = ffi.Pointer.fromAddress(CA + f64Width * 4); dx.value = x2.value-x1.value;
            ffi.Pointer<ffi.Double> dy = ffi.Pointer.fromAddress(CA + f64Width * 5); dy.value = y2.value-y1.value;
            cairo.cairo_user_to_device_distance(_context, dx, dy);
            int pad = state.shadowBlur * 2;
            ffi.Pointer<cairo_surface_t> shadow_surface = cairo.cairo_image_surface_create(
                cairo_format.CAIRO_FORMAT_ARGB32,
                (dx.value + 2 * pad).toInt(),
                (dy.value + 2 * pad).toInt()
            );
            ffi.Pointer<cairo_t> shadow_context = cairo.cairo_create(shadow_surface);

            // transform path to the right place
            cairo.cairo_translate(shadow_context, pad-x1.value, pad-y1.value);
            cairo.cairo_transform(shadow_context, path_matrixPtr);

            // set lineCap lineJoin lineDash
            cairo.cairo_set_line_cap(shadow_context, cairo.cairo_get_line_cap(_context));
            cairo.cairo_set_line_join(shadow_context, cairo.cairo_get_line_join(_context));

            ffi.Pointer<ffi.Double> offset = ffi.Pointer.fromAddress(CA + f64Width * 6);
            int dashes = cairo.cairo_get_dash_count(_context);
            // std::vector<double> a(dashes);
            // var a = Float64List(dashes);
            var a = malloc.allocate<ffi.Double>(dashes * ffi.sizeOf<ffi.Double>());
            cairo.cairo_get_dash(_context, a, offset);
            cairo.cairo_set_dash(shadow_context, a, dashes, offset.value);

            // draw the path and blur
            cairo.cairo_set_line_width(shadow_context, cairo.cairo_get_line_width(_context));
            cairo.cairo_new_path(shadow_context);
            cairo.cairo_append_path(shadow_context, path);
            setCtxSourceRGBA(shadow_context, state.shadow);
            fn(shadow_context);
            blur(shadow_surface, state.shadowBlur);

            // paint to original context
            cairo.cairo_set_source_surface(
                _context, shadow_surface,
                x1.value - pad + state.shadowOffsetX + 1,
                y1.value - pad + state.shadowOffsetY + 1
            );
            cairo.cairo_paint(_context);
            cairo.cairo_destroy(shadow_context);
            cairo.cairo_surface_destroy(shadow_surface);

            malloc.free(chunk);
        } else {
            // Offset first, then apply path's transform
            cairo.cairo_translate(
                _context, 
                state.shadowOffsetX, 
                state.shadowOffsetY
            );
            cairo.cairo_transform(_context, path_matrixPtr);

            // Apply shadow
            cairo.cairo_new_path(_context);
            cairo.cairo_append_path(_context, path);
            setSourceRGBA(state.shadow);

            fn(_context);
        }

        // Paint the shadow
        cairo.cairo_pop_group_to_source(_context);
        cairo.cairo_paint(_context);

        // Restore state
        cairo.cairo_restore(_context);
        cairo.cairo_new_path(_context);
        cairo.cairo_append_path(_context, path);
        fn(_context);

        cairo.cairo_path_destroy(path);
    }


    void fill([bool preserve=false]) {
        ffi.Pointer<cairo_pattern_t> new_pattern;
        bool needsRestore = false;
        if (state.fillPattern != ffi.nullptr) {
            if (state.globalAlpha < 1) {
                new_pattern = create_transparent_pattern(state.fillPattern, state.globalAlpha);
                if (new_pattern == ffi.nullptr) {
                    // failed to allocate
                    throw "Failed to initialize context";
                }
                cairo.cairo_set_source(_context, new_pattern);
                cairo.cairo_pattern_destroy(new_pattern);
            } else {
                cairo.cairo_pattern_set_filter(state.fillPattern, state.patternQuality);
                cairo.cairo_set_source(_context, state.fillPattern);
            }
            repeat_type_t repeat = Pattern.get_repeat_type_for_cairo_pattern(state.fillPattern);
            if (repeat == RepeatType.NO_REPEAT) {
                cairo.cairo_pattern_set_extend(cairo.cairo_get_source(_context), cairo_extend.CAIRO_EXTEND_NONE);
            } else if (repeat == RepeatType.REPEAT) {
                cairo.cairo_pattern_set_extend(cairo.cairo_get_source(_context), cairo_extend.CAIRO_EXTEND_REPEAT);
            } else {
                cairo.cairo_save(_context);
                ffi.Pointer<cairo_path_t> savedPath = cairo.cairo_copy_path(_context);
                ffi.Pointer<cairo_surface_t> patternSurface = ffi.nullptr;
                
                final cairoSurfacePtrPtr = malloc<ffi.Pointer<cairo_surface_t>>();
                cairoSurfacePtrPtr.value = patternSurface;
                cairo.cairo_pattern_get_surface(cairo.cairo_get_source(_context), cairoSurfacePtrPtr);

                final chunk = malloc.allocate(2 * f64Width);
                final CA = chunk.address;
                double width, height;
                if (repeat == RepeatType.REPEAT_X) {
                    ffi.Pointer<ffi.Double> x1 = ffi.Pointer.fromAddress(CA + f64Width * 0);
                    ffi.Pointer<ffi.Double> x2 = ffi.Pointer.fromAddress(CA + f64Width * 1);
                    cairo.cairo_path_extents(_context, x1, ffi.nullptr, x2, ffi.nullptr);
                    width = x2.value - x1.value;
                    height = cairo.cairo_image_surface_get_height(patternSurface).toDouble();
                } else {
                    ffi.Pointer<ffi.Double> y1 = ffi.Pointer.fromAddress(CA + f64Width * 0);
                    ffi.Pointer<ffi.Double> y2 = ffi.Pointer.fromAddress(CA + f64Width * 1);
                    cairo.cairo_path_extents(_context, ffi.nullptr, y1, ffi.nullptr, y2);
                    width = cairo.cairo_image_surface_get_width(patternSurface).toDouble();
                    height = y2.value - y1.value;
                }
                
                cairo.cairo_new_path(_context);
                cairo.cairo_rectangle(_context, 0, 0, width, height);
                cairo.cairo_clip(_context);
                cairo.cairo_append_path(_context, savedPath);
                cairo.cairo_path_destroy(savedPath);
                cairo.cairo_pattern_set_extend(cairo.cairo_get_source(_context), cairo_extend.CAIRO_EXTEND_REPEAT);
                needsRestore = true;
                malloc.free(chunk);
                malloc.free(cairoSurfacePtrPtr);
            }
        } else if (state.fillGradient != ffi.nullptr) {
            if (state.globalAlpha < 1) {
                new_pattern = create_transparent_gradient(state.fillGradient, state.globalAlpha);
                if (new_pattern == ffi.nullptr) {
                    // failed to recognize gradient
                    throw "Unexpected gradient type";
                }
                cairo.cairo_pattern_set_filter(new_pattern, state.patternQuality);
                cairo.cairo_set_source(_context, new_pattern);
                cairo.cairo_pattern_destroy(new_pattern);
            } else {
                cairo.cairo_pattern_set_filter(state.fillGradient, state.patternQuality);
                cairo.cairo_set_source(_context, state.fillGradient);
            }
        } else {
            setSourceRGBA(state.fill);
        }
        if (preserve) {
            hasShadow()
            ? shadow(cairo.cairo_fill_preserve)
            : cairo.cairo_fill_preserve(_context);
        } else {
            hasShadow()
            ? shadow(cairo.cairo_fill)
            : cairo.cairo_fill(_context);
        }
        if (needsRestore) {
            cairo.cairo_restore(_context);
        }
    }

    /*
    * Stroke and apply shadow.
    */
    void stroke([bool preserve=false]) {
        ffi.Pointer<cairo_pattern_t> new_pattern;
        if (state.strokePattern != ffi.nullptr) {
            if (state.globalAlpha < 1) {
                new_pattern = create_transparent_pattern(state.strokePattern, state.globalAlpha);
                if (new_pattern == ffi.nullptr) {
                    // failed to allocate
                    throw "Failed to initialize context";
                }
                cairo.cairo_set_source(_context, new_pattern);
                cairo.cairo_pattern_destroy(new_pattern);
            } else {
                cairo.cairo_pattern_set_filter(state.strokePattern, state.patternQuality);
                cairo.cairo_set_source(_context, state.strokePattern);
            }
            repeat_type_t repeat = Pattern.get_repeat_type_for_cairo_pattern(state.strokePattern);
            if (RepeatType.NO_REPEAT == repeat) {
                cairo.cairo_pattern_set_extend(cairo.cairo_get_source(_context), cairo_extend.CAIRO_EXTEND_NONE);
            } else {
                cairo.cairo_pattern_set_extend(cairo.cairo_get_source(_context), cairo_extend.CAIRO_EXTEND_REPEAT);
            }
        } else if (state.strokeGradient != ffi.nullptr) {
            if (state.globalAlpha < 1) {
                new_pattern = create_transparent_gradient(state.strokeGradient, state.globalAlpha);
                if (new_pattern == ffi.nullptr) {
                    // failed to recognize gradient
                    throw "Unexpected gradient type";
                }
                cairo.cairo_pattern_set_filter(new_pattern, state.patternQuality);
                cairo.cairo_set_source(_context, new_pattern);
                cairo.cairo_pattern_destroy(new_pattern);
            } else {
                cairo.cairo_pattern_set_filter(state.strokeGradient, state.patternQuality);
                cairo.cairo_set_source(_context, state.strokeGradient);
            }
        } else {
            setSourceRGBA(state.stroke);
        }

        if (preserve) {
            hasShadow()
            ? shadow(cairo.cairo_stroke_preserve)
            : cairo.cairo_stroke_preserve(_context);
        } else {
            hasShadow()
            ? shadow(cairo.cairo_stroke)
            : cairo.cairo_stroke(_context);
        }
    }

    /*
    * Restore flat path.
    */
    void restorePath() {
        cairo.cairo_new_path(_context);
        cairo.cairo_append_path(_context, _path);
        cairo.cairo_path_destroy(_path);
    }

    /*
    * Stroke the rectangle defined by x, y, width and height.
    */
    void strokeRect(num x, num y, num width, num height) {
        if (0 == width && 0 == height) return;
        ffi.Pointer<cairo_t> ctx = _context;
        savePath();
        cairo.cairo_rectangle(ctx, x.toDouble(), y.toDouble(), width.toDouble(), height.toDouble());
        stroke();
        restorePath();
    }

    /*
    * Clears all pixels defined by x, y, width and height.
    */
    void clearRect(num x, num y, num width, num height) {
        if (0 == width || 0 == height) return;
        var ctx = _context;
        cairo.cairo_save(ctx);
        savePath();
        cairo.cairo_rectangle(ctx, x.toDouble(), y.toDouble(), width.toDouble(), height.toDouble());
        cairo.cairo_set_operator(ctx, cairo_operator.CAIRO_OPERATOR_CLEAR);
        cairo.cairo_fill(ctx);
        restorePath();
        cairo.cairo_restore(ctx);
    }

    /*
    * Fill the rectangle defined by x, y, width and height.
    */
    void fillRect(num x, num y, num width, num height) {
        if (0 == width || 0 == height) return;
        ffi.Pointer<cairo_t> ctx = _context;
        savePath();
        cairo.cairo_rectangle(ctx, x.toDouble(), y.toDouble(), width.toDouble(), height.toDouble());
        fill();
        restorePath();
    }

    /*
     * https://html.spec.whatwg.org/multipage/canvas.html#dom-context-2d-roundrect
     * x, y, w, h, [radius|[radii]]
     */
    void roundRect(num x, num y, num width, num height, Object radii) {
        ffi.Pointer<cairo_t> ctx = _context;

        // 4. Let normalizedRadii be an empty list
        List<DOMPoint> normalizedRadii = [DOMPoint(0, 0), DOMPoint(0, 0), DOMPoint(0, 0), DOMPoint(0, 0)];
        int nRadii = 4;

        if (radii is List) {
            var radiiList = radii;
            nRadii = radiiList.length;
            if (!(nRadii >= 1 && nRadii <= 4)) {
                throw "radii must be a list of one, two, three or four radii.";
            }
            
            // 5. For each radius of radii
            for (int i = 0; i < nRadii; i++) {
                if (getRadius(normalizedRadii[i], radiiList[i])) {
                    return;
                }
            }
        } else {
            // 2. If radii is a double, then set radii to <<radii>>
            if (getRadius(normalizedRadii[0], radii)) {
                return;
            }
            for (int i = 1; i < 4; i++) {
                normalizedRadii[i].x = normalizedRadii[0].x;
                normalizedRadii[i].y = normalizedRadii[0].y;
            }
        }

        DOMPoint upperLeft, upperRight, lowerRight, lowerLeft;
        if (nRadii == 4) {
            upperLeft = normalizedRadii[0].clone();
            upperRight = normalizedRadii[1].clone();
            lowerRight = normalizedRadii[2].clone();
            lowerLeft = normalizedRadii[3].clone();
        } else if (nRadii == 3) {
            upperLeft = normalizedRadii[0];
            upperRight = normalizedRadii[1];
            lowerLeft = normalizedRadii[1].clone();
            lowerRight = normalizedRadii[2];
        } else if (nRadii == 2) {
            upperLeft = normalizedRadii[0];
            lowerRight = normalizedRadii[0].clone();
            upperRight = normalizedRadii[1];
            lowerLeft = normalizedRadii[1].clone();
        } else {
            upperLeft = normalizedRadii[0];
            upperRight = normalizedRadii[0].clone();
            lowerRight = normalizedRadii[0].clone();
            lowerLeft = normalizedRadii[0].clone();
        }

        bool clockwise = true;
        if (width < 0) {
            clockwise = false;
            x += width;
            width = -width;

            var temp = upperLeft;
            upperLeft = upperRight;
            upperRight = temp;

            temp = lowerLeft;
            lowerLeft = lowerRight;
            lowerRight = temp;
        }

        if (height < 0) {
            clockwise = !clockwise;
            y += height;
            height = -height;

            var temp = upperLeft;
            upperLeft = lowerLeft;
            lowerLeft = temp;

            temp = upperRight;
            upperRight = lowerRight;
            lowerRight = temp;
        }

        // 11. Corner curves must not overlap. Scale radii to prevent this.
        {
            var top = upperLeft.x + upperRight.x;
            var right = upperRight.y + lowerRight.y;
            var bottom = lowerRight.x + lowerLeft.x;
            var left = upperLeft.y + lowerLeft.y;
            var scale = min_([ width / top, height / right, width / bottom, height / left ]);
            if (scale < 1.0) {
                upperLeft.x *= scale;
                upperLeft.y *= scale;
                upperRight.x *= scale;
                upperRight.y *= scale;
                lowerLeft.x *= scale;
                lowerLeft.y *= scale;
                lowerRight.x *= scale;
                lowerRight.y *= scale;
            }
        }

        final dx = x.toDouble();
        final dy = y.toDouble();

        // 12. Draw
        cairo.cairo_move_to(ctx, x + upperLeft.x, dy);
        if (clockwise) {
            cairo.cairo_line_to(ctx, x + width - upperRight.x, dy);
            elli_arc(ctx, x + width - upperRight.x, y + upperRight.y, upperRight.x, upperRight.y, 3.0 * M_PI / 2.0, 0.0);
            cairo.cairo_line_to(ctx, dx + width, y + height - lowerRight.y);
            elli_arc(ctx, x + width - lowerRight.x, y + height - lowerRight.y, lowerRight.x, lowerRight.y, 0, M_PI / 2.0);
            cairo.cairo_line_to(ctx, x + lowerLeft.x, dy + height);
            elli_arc(ctx, x + lowerLeft.x, y + height - lowerLeft.y, lowerLeft.x, lowerLeft.y, M_PI / 2.0, M_PI);
            cairo.cairo_line_to(ctx, dx, y + upperLeft.y);
            elli_arc(ctx, x + upperLeft.x, y + upperLeft.y, upperLeft.x, upperLeft.y, M_PI, 3.0 * M_PI / 2.0);
        } else {
            elli_arc(ctx, x + upperLeft.x, y + upperLeft.y, upperLeft.x, upperLeft.y, M_PI, 3.0 * M_PI / 2.0, false);
            cairo.cairo_line_to(ctx, dx, y + upperLeft.y);
            elli_arc(ctx, x + lowerLeft.x, y + height - lowerLeft.y, lowerLeft.x, lowerLeft.y, M_PI / 2.0, M_PI, false);
            cairo.cairo_line_to(ctx, x + lowerLeft.x, dy + height);
            elli_arc(ctx, x + width - lowerRight.x, y + height - lowerRight.y, lowerRight.x, lowerRight.y, 0, M_PI / 2.0, false);
            cairo.cairo_line_to(ctx, dx + width, y + height - lowerRight.y);
            elli_arc(ctx, x + width - upperRight.x, y + upperRight.y, upperRight.x, upperRight.y, 3.0 * M_PI / 2.0, 0.0, false);
            cairo.cairo_line_to(ctx, x + width - upperRight.x, dy);
        }
        cairo.cairo_close_path(ctx);
    }

    /*
    * Adds an arc at x, y with the given radii and start/end angles.
    */
    void arc(num x_, num y_, num radius_, num startAngle_, num endAngle_, [bool counterclockwise=false]) {
        double x = x_.toDouble();
        double y = y_.toDouble();
        double radius = radius_.toDouble();
        double startAngle = startAngle_.toDouble();
        double endAngle = endAngle_.toDouble();

        if (radius < 0) {
            throw "The radius provided is negative.";
        }

        ffi.Pointer<cairo_t> ctx = _context;

        (startAngle, endAngle) = canonicalizeAngle(startAngle, endAngle);
        endAngle = adjustEndAngle(startAngle, endAngle, counterclockwise);

        if (counterclockwise) {
            cairo.cairo_arc_negative(ctx, x, y, radius, startAngle, endAngle);
        } else {
            cairo.cairo_arc(ctx, x, y, radius, startAngle, endAngle);
        }
    }

    /*
    * Adds an ellipse to the path which is centered at (x, y) position with the
    * radii radiusX and radiusY starting at startAngle and ending at endAngle
    * going in the given direction by anticlockwise (defaulting to clockwise).
    */
    void ellipse(num x_, num y_, num radiusX_, num radiusY_, num rotation_, num startAngle_, num endAngle_, [bool counterclockwise=false]) {
        double radiusX = radiusX_.toDouble();
        double radiusY = radiusY_.toDouble();

        if (radiusX == 0 || radiusY == 0) return;

        double x = x_.toDouble();
        double y = y_.toDouble();
        double rotation = rotation_.toDouble();
        double startAngle = startAngle_.toDouble();
        double endAngle = endAngle_.toDouble();

        ffi.Pointer<cairo_t> ctx = _context;

        // See https://www.cairographics.org/cookbook/ellipses/
        double xRatio = radiusX / radiusY;

        ffi.Pointer<cairo_matrix_t> saveMatrixPtr = malloc<cairo_matrix_t>();
        cairo.cairo_get_matrix(ctx, saveMatrixPtr);
        cairo.cairo_translate(ctx, x, y);
        cairo.cairo_rotate(ctx, rotation);
        cairo.cairo_scale(ctx, xRatio, 1.0);
        cairo.cairo_translate(ctx, -x, -y);
        if (counterclockwise && M_PI * 2 != rotation) {
            cairo.cairo_arc_negative(
                ctx,
                x,
                y,
                radiusY,
                startAngle,
                endAngle
            );
        } else {
            cairo.cairo_arc(
                ctx,
                x,
                y,
                radiusY,
                startAngle,
                endAngle
            );
        }
        cairo.cairo_set_matrix(ctx, saveMatrixPtr);
    }

    /*
    * Creates a new subpath.
    */
    void beginPath() {
        cairo.cairo_new_path(_context);
    }

    /*
    * Marks the subpath as closed.
    */
    void closePath() {
        cairo.cairo_close_path(_context);
    }

    /*
    * Creates a new subpath at the given point.
    */
    void moveTo(num x, num y) {
        cairo.cairo_move_to(_context, x.toDouble(), y.toDouble());
    }

    /*
    * Adds a point to the current subpath.
    */
    void lineTo(num x, num y) {
        cairo.cairo_line_to(_context, x.toDouble(), y.toDouble());
    }

    /*
    * Quadratic curve approximation from libsvg-cairo.
    */
    void quadraticCurveTo(num cpx, num cpy, num x_, num y_) {
        ffi.Pointer<cairo_t> ctx = _context;

        final chunk = malloc.allocate(2 * f64Width);
        final CA = chunk.address;
        ffi.Pointer<ffi.Double> x = ffi.Pointer.fromAddress(CA + f64Width * 0);
        ffi.Pointer<ffi.Double> y = ffi.Pointer.fromAddress(CA + f64Width * 1);
        double x1 = cpx.toDouble(), 
            y1 = cpy.toDouble(), 
            x2 = x_.toDouble(), 
            y2 = y_.toDouble();

        cairo.cairo_get_current_point(ctx, x, y);

        if (0 == x.value && 0 == y.value) {
            x.value = x1;
            y.value = y1;
        }

        cairo.cairo_curve_to(
            ctx, 
            x.value  + 2.0 / 3.0 * (x1 - x.value),  y.value  + 2.0 / 3.0 * (y1 - y.value), 
            x2 + 2.0 / 3.0 * (x1 - x2), y2 + 2.0 / 3.0 * (y1 - y2), 
            x2, y2
        );

        malloc.free(chunk);
    }

    /*
    * Bezier curve.
    */
    void bezierCurveTo(num cp1x, num cp1y, num cp2x, num cp2y, num x, num y) {
        cairo.cairo_curve_to(
            _context, 
            cp1x.toDouble(), cp1y.toDouble(),
            cp2x.toDouble(), cp2y.toDouble(),
            x.toDouble(), y.toDouble()
        );
    }

    /*
    * Get line width.
    */
    double GetLineWidth() {
        return cairo.cairo_get_line_width(_context);
    }

    /*
    * Set line width.
    */
    set lineWidth(num value) {
        double n = value.toDouble();
        if (n > 0 && n != double.infinity) {
            cairo.cairo_set_line_width(_context, n);
        }
    }

    /*
    * Get line cap.
    */
    String get lineCap {
        switch (cairo.cairo_get_line_cap(_context)) {
            case cairo_line_cap.CAIRO_LINE_CAP_ROUND:
                return "round";
            case cairo_line_cap.CAIRO_LINE_CAP_SQUARE:
                return "square";
            default:
                return "butt";
        }
    }

    /*
    * Set line cap.
    */
    set lineCap(String type) {
        ffi.Pointer<cairo_t> ctx = _context;
        switch (type[0]) {
            case 'r':
                cairo.cairo_set_line_cap(ctx, cairo_line_cap.CAIRO_LINE_CAP_ROUND);
            case 's':
                cairo.cairo_set_line_cap(ctx, cairo_line_cap.CAIRO_LINE_CAP_SQUARE);
            default:
                cairo.cairo_set_line_cap(ctx, cairo_line_cap.CAIRO_LINE_CAP_BUTT);
        }
    }

    /*
    * Get line join.
    */
    String get lineJoin {
        switch (cairo.cairo_get_line_join(_context)) {
            case cairo_line_join.CAIRO_LINE_JOIN_BEVEL:
                return "bevel";
            case cairo_line_join.CAIRO_LINE_JOIN_ROUND:
                return "round";
            default:
                return "miter";
        }
    }

    /*
    * Set line join.
    */
    set lineJoin(String type) {
        ffi.Pointer<cairo_t> ctx = _context;
        switch (type[0]) {
            case 'r':
                cairo.cairo_set_line_join(ctx, cairo_line_join.CAIRO_LINE_JOIN_ROUND);
            case 'b':
                cairo.cairo_set_line_join(ctx, cairo_line_join.CAIRO_LINE_JOIN_BEVEL);
            default:
                cairo.cairo_set_line_join(ctx, cairo_line_join.CAIRO_LINE_JOIN_MITER);
        }
    }

    /*
    * Get current fill style.
    */
    FillInfo get fillStyle {
        return this._fillStyle;
    }

    /*
    * Set current fill style.
    */
    set fillStyle(Object value) {
        if (value is String) {
            final rgba = RGBA.fromString(value);
            this.state.fillPattern = this.state.fillGradient = ffi.nullptr;
            this.state.fill = rgba;
            this._fillStyle = CSSColor(
                (rgba.r * 255).toInt(),
                (rgba.g * 255).toInt(),
                (rgba.b * 255).toInt(),
                rgba.a
            );
        } else if (value is FillInfo) {
            this._fillStyle = value;
            if (value is CSSColor) {
                this.state.fillPattern = this.state.fillGradient = ffi.nullptr;
                this.state.fill = RGBA(value.r / 255, value.g / 255, value.b / 255, value.a);
            } else if (value is CanvasGradient) {
                // state.fillGradient = Gradient(_pattern, _repeat).pattern();
            } else if (value is CanvasGradient) {
                // state.fillPattern = Pattern(_pattern, _repeat)->pattern();
            }
        }
    }

    /*
    * Get current stroke style.
    */
    FillInfo get strokeStyle {
        return this._strokeStyle;
    }

    /*
    * Set current stroke style.
    */
    set strokeStyle(Object value) {
        if (value is String) {
            final rgba = RGBA.fromString(value);
            this.state.strokePattern = this.state.strokeGradient = ffi.nullptr;
            this.state.stroke = rgba;
            this._strokeStyle = CSSColor(
                (rgba.r * 255).toInt(),
                (rgba.g * 255).toInt(),
                (rgba.b * 255).toInt(),
                rgba.a
            );
        } else if (value is FillInfo) {
            this._strokeStyle = value;
            if (value is CSSColor) {
                this.state.strokePattern = this.state.strokeGradient = ffi.nullptr;
                this.state.stroke = RGBA(value.r / 255, value.g / 255, value.b / 255, value.a);
            } else if (value is CanvasGradient) {
                // state.strokeGradient = Gradient(_pattern, _repeat).pattern();
            } else if (value is CanvasGradient) {
                // state.strokePattern = Pattern(_pattern, _repeat)->pattern();
            }
        }
    }

    /*
    * Save state.
    */
    void save() {
        cairo.cairo_save(_context);
        states.push(CanvasState(states.top()));
        this.state = states.top();
    }

    /*
    * Restore state.
    */
    void restore() {
        if (states.size() > 1) {
            cairo.cairo_restore(_context);
            states.pop();
            state = states.top();
            pango.pango_layout_set_font_description(_layout, state.fontDescription);
        }
    }

    /*
    * Reset the CTM, used internally by setTransform().
    */
    void resetTransform() {
        cairo.cairo_identity_matrix(_context);
    }

    /*
    * Scale transformation.
    */
    void scale(num xs, num ys) {
        cairo.cairo_scale(_context, xs.toDouble(), ys.toDouble());
    }

    /*
    * Translate transformation.
    */
    void translate(num x, num y) {
        cairo.cairo_translate(_context, x.toDouble(), y.toDouble());
    }

    /*
    * Rotate transformation.
    */
    void rotate(num rads) {
        cairo.cairo_rotate(_context, rads.toDouble());
    }

    /*
    * Get font.
    */
    String get font {
        return this.state.font;
    }

    /*
    * Set font:
    *   - weight
    *   - style
    *   - size
    *   - unit
    *   - family
    */
    void setFont(ParsedFont font) {
        int weight = font.weight;
        String style = font.style;
        double size = font.size;
        String family = font.family;

        ffi.Pointer<PangoFontDescription> desc = pango.pango_font_description_copy(state.fontDescription);
        pango.pango_font_description_free(state.fontDescription);

        pango.pango_font_description_set_style(desc, getStyleFromCSSString(style));
        pango.pango_font_description_set_weight(desc, PangoWeight.fromValue(weight));

        if (family.isNotEmpty) {
            // See #1643 - Pango understands "sans" whereas CSS uses "sans-serif"
            String s1 = family;
            String s2 = "sans-serif";
            ffi.Pointer<Utf8>  familyName;
            if (s1.toLowerCase() == s2) {
                familyName = "sans".toNativeUtf8();
            } else {
                familyName = family.toNativeUtf8();
            }
            pango.pango_font_description_set_family(desc, familyName.cast());
            malloc.free(familyName);
        }

        ffi.Pointer<PangoFontDescription> sys_desc = resolveFontDescription(desc);
        pango.pango_font_description_free(desc);

        if (size > 0) pango.pango_font_description_set_absolute_size(sys_desc, size * PANGO_SCALE);

        state.fontDescription = sys_desc;
        pango.pango_layout_set_font_description(_layout, sys_desc);
    }

    set font(String fontStr) {
        if (fontStr.isEmpty) return;

        ParsedFont? mparsed = parseFontString(fontStr);

        // parseFont returns undefined for invalid CSS font strings
        if (mparsed == null) return;

        this.setFont(mparsed);
        state.font = fontStr;
    }

    /*
    * Set text path for the string in the layout at (x, y).
    * This function is called by paintText and won't behave correctly
    * if is not called from there.
    * it needs pango_layout_set_text and pango_cairo_update_layout to be called before
    */
    void setTextPath(double x, double y) {
        var logical_rect = malloc<PangoRectangle>();

        switch (state.textAlignment) {
            case TextAlign.TEXT_ALIGNMENT_CENTER:
                pango.pango_layout_get_pixel_extents(_layout, ffi.nullptr, logical_rect);
                x -= logical_rect.ref.width / 2;
            case TextAlign.TEXT_ALIGNMENT_END:
            case TextAlign.TEXT_ALIGNMENT_RIGHT:
                pango.pango_layout_get_pixel_extents(_layout, ffi.nullptr, logical_rect);
                x -= logical_rect.ref.width;
            default:
        }

        y -= getBaselineAdjustment(_layout, state.textBaseline);

        cairo.cairo_move_to(_context, x, y);
        if (state.textDrawingMode == CanvasDrawMode.TEXT_DRAW_PATHS) {
            pango.pango_cairo_layout_path(_context.cast(), _layout);
        } else if (state.textDrawingMode == CanvasDrawMode.TEXT_DRAW_GLYPHS) {
            pango.pango_cairo_show_layout(_context.cast(), _layout);
        }
        
        malloc.free(logical_rect);
    }

    void paintText(bool stroke, String text, double x, double y, [num? maxWidth]) {
        int argsNum = 3;
        if (maxWidth == null)
            argsNum = 2;

        String strValue = text;

        var str = strValue.toNativeUtf8();
        double scaled_by = 1;

        ffi.Pointer<PangoLayout> layout = _layout;

        pango.pango_layout_set_text(layout, str.cast(), -1);
        pango.pango_cairo_update_layout(_context.cast(), layout);

        if (maxWidth != null) {
            scaled_by = get_text_scale(layout, maxWidth.toDouble());
            cairo.cairo_save(_context);
            cairo.cairo_scale(_context, scaled_by, 1);
        }

        savePath();
        if (state.textDrawingMode == CanvasDrawMode.TEXT_DRAW_GLYPHS) {
            if (stroke == true) { this.stroke(); } else { this.fill(); }
            setTextPath(x / scaled_by, y);
        } else if (state.textDrawingMode == CanvasDrawMode.TEXT_DRAW_PATHS) {
            setTextPath(x / scaled_by, y);
            if (stroke == true) { this.stroke(); } else { this.fill(); }
        }
        restorePath();
        if (argsNum == 3) {
            cairo.cairo_restore(_context);
        }
    }

    /*
    * Fill text at (x, y).
    */
    void fillText(String text, num x, num y, [num? maxWidth]) {
        paintText(false, text, x.toDouble(), y.toDouble(), maxWidth);
    }

    /*
    * Stroke text at (x ,y).
    */
    void strokeText(String text, num x, num y, [num? maxWidth]) {
        paintText(true, text, x.toDouble(), y.toDouble(), maxWidth);
    }

    /*
    * Return the given text extents.
    * TODO: Support for:
    * hangingBaseline, ideographicBaseline,
    * fontBoundingBoxAscent, fontBoundingBoxDescent
    */
    TextMetrics measureText(String str) {
        var ctx = _context;

        ffi.Pointer<PangoRectangle> _ink_rect = malloc<PangoRectangle>();
        ffi.Pointer<PangoRectangle> _logical_rect = malloc<PangoRectangle>();
        FloatRectangle ink_rect = FloatRectangle();
        FloatRectangle logical_rect = FloatRectangle();
        var layout = _layout;

        var cStr = str.toNativeUtf8();
        pango.pango_layout_set_text(layout, cStr.cast(), -1);
        pango.pango_cairo_update_layout(ctx.cast(), layout);
        malloc.free(cStr);

        // Normally you could use pango_layout_get_pixel_extents and be done, or use
        // pango_extents_to_pixels, but both of those round the pixels, so we have to
        // divide by PANGO_SCALE manually
        pango.pango_layout_get_extents(layout, _ink_rect, _logical_rect);

        double inverse_pango_scale = 1.0 / PANGO_SCALE;

        final logicalRect = _logical_rect.ref;
        logical_rect.x = logicalRect.x * inverse_pango_scale;
        logical_rect.y = logicalRect.y * inverse_pango_scale;
        logical_rect.width = logicalRect.width * inverse_pango_scale;
        logical_rect.height = logicalRect.height * inverse_pango_scale;

        final inkRect = _ink_rect.ref;
        ink_rect.x = inkRect.x * inverse_pango_scale;
        ink_rect.y = inkRect.y * inverse_pango_scale;
        ink_rect.width = inkRect.width * inverse_pango_scale;
        ink_rect.height = inkRect.height * inverse_pango_scale;

        ffi.Pointer<PangoFontMetrics> metrics = pango.pango_context_get_metrics(
            pango.pango_layout_get_context(layout.cast()),
            pango.pango_layout_get_font_description(layout.cast()),
            pango.pango_context_get_language(pango.pango_layout_get_context(layout.cast()))
        );

        double x_offset;
        switch (state.textAlignment) {
            case TextAlign.TEXT_ALIGNMENT_CENTER:
                x_offset = logical_rect.width / 2.0;
            case TextAlign.TEXT_ALIGNMENT_END:
            case TextAlign.TEXT_ALIGNMENT_RIGHT:
                x_offset = logical_rect.width;
            case TextAlign.TEXT_ALIGNMENT_START:
            case TextAlign.TEXT_ALIGNMENT_LEFT:
            default:
                x_offset = 0.0;
        }

        double y_offset = getBaselineAdjustment(layout, state.textBaseline);

        final obj = TextMetrics(
            width: logical_rect.width,
            actualBoundingBoxLeft: PangoLib.PANGO_LBEARING(ink_rect) + x_offset,
            actualBoundingBoxRight: PangoLib.PANGO_RBEARING(ink_rect) - x_offset,
            actualBoundingBoxAscent: y_offset + PangoLib.PANGO_ASCENT(ink_rect),
            actualBoundingBoxDescent: PangoLib.PANGO_DESCENT(ink_rect) - y_offset,
            emHeightAscent: -(PangoLib.PANGO_ASCENT(logical_rect) - y_offset),
            emHeightDescent: PangoLib.PANGO_DESCENT(logical_rect) - y_offset,
            alphabeticBaseline: -(pango.pango_font_metrics_get_ascent(metrics) * inverse_pango_scale - y_offset),
        );

        pango.pango_font_metrics_unref(metrics);

        malloc.free(_ink_rect);
        malloc.free(_logical_rect);

        return obj;
    }

    /*
    * Get image data.
    *
    *  - sx, sy, sw, sh
    *
    */
    ImageData getImageData(num sx_, num sy_, num sw_, num sh_) {
        Canvas canvas = this.canvas;

        int sx = sx_.toInt();
        int sy = sy_.toInt();
        int sw = sw_.toInt();
        int sh = sh_.toInt();

        if (sw == 0) {
            throw "IndexSizeError: The source width is 0.";
        }
        if (sh == 0) {
            throw "IndexSizeError: The source height is 0.";
        }

        int width = canvas.getWidth();
        int height = canvas.getHeight();

        if (width == 0) {
            throw "Canvas width is 0";
        }
        if (height == 0) {
            throw "Canvas height is 0";
        }

        // WebKit and Firefox have this behavior:
        // Flip the coordinates so the origin is top/left-most:
        if (sw < 0) {
            sx += sw;
            sw = -sw;
        }
        if (sh < 0) {
            sy += sh;
            sh = -sh;
        }

        if (sx + sw > width) sw = width - sx;
        if (sy + sh > height) sh = height - sy;

        // WebKit/moz functionality. node-canvas used to return in either case.
        if (sw <= 0) sw = 1;
        if (sh <= 0) sh = 1;

        // Non-compliant. "Pixels outside the canvas must be returned as transparent
        // black." This instead clips the returned array to the canvas area.
        if (sx < 0) {
            sw += sx;
            sx = 0;
        }
        if (sy < 0) {
            sh += sy;
            sy = 0;
        }

        int srcStride = canvas.stride();
        int bpp = (srcStride / width).toInt();
        int size = sw * sh * bpp;
        int dstStride = sw * bpp;

        ffi.Pointer<ffi.Uint8> src = canvas.data();

        Uint8List dataArray = Uint8List(size);
        int dst = 0;

        switch (canvas.backend().format) {
            case cairo_format.CAIRO_FORMAT_ARGB32: {
                // Rearrange alpha (argb -> rgba), undo alpha pre-multiplication,
                // and store in big-endian format
                for (int y = 0; y < sh; ++y) {
                    final row = ffi.Pointer<ffi.Uint32>.fromAddress(src.address + srcStride * (sy + y));
                    for (int x = 0; x < sw; ++x) {
                        int bx = x * 4;
                        int pixel = (row + sx + x).value;
                        int a = (pixel >> 24) & 255;
                        int r = (pixel >> 16) & 255;
                        int g = (pixel >> 8) & 255;
                        int b = pixel & 255;
                        dataArray[dst + bx + 3] = a;

                        // Performance optimization: fully transparent/opaque pixels can be
                        // processed more efficiently.
                        if (a == 0 || a == 255) {
                            dataArray[dst + bx + 0] = r;
                            dataArray[dst + bx + 1] = g;
                            dataArray[dst + bx + 2] = b;
                        } else {
                            // Undo alpha pre-multiplication
                            double alphaR = 255 / a;
                            dataArray[dst + bx + 0] = (r * alphaR).toInt();
                            dataArray[dst + bx + 1] = (g * alphaR).toInt();
                            dataArray[dst + bx + 2] = (b * alphaR).toInt();
                        }
                    }
                    dst += dstStride;
                }
                break;
            }
            case cairo_format.CAIRO_FORMAT_RGB24: {
                // Rearrange alpha (argb -> rgba) and store in big-endian format
                for (int y = 0; y < sh; ++y) {
                    ffi.Pointer<ffi.Uint32> row = ffi.Pointer.fromAddress(src.address + srcStride * (y + sy));
                    for (int x = 0; x < sw; ++x) {
                        int bx = x * 4;
                        ffi.Pointer<ffi.Uint32> pixel = row + x + sx;
                        int r = ffi.Pointer.fromAddress(pixel.address >> 16).cast<ffi.Uint8>().value;
                        int g = ffi.Pointer.fromAddress(pixel.address >> 8).cast<ffi.Uint8>().value;
                        int b = pixel.cast<ffi.Uint8>().value;

                        dataArray[dst + bx + 0] = r;
                        dataArray[dst + bx + 1] = g;
                        dataArray[dst + bx + 2] = b;
                        dataArray[dst + bx + 3] = 255;
                    }
                    dst += dstStride;
                }
                break;
            }
            case cairo_format.CAIRO_FORMAT_A8: {
                for (int y = 0; y < sh; ++y) {
                    ffi.Pointer<ffi.Uint8> row = src + srcStride * (y + sy);
                    for (int i = 0; i < dstStride; i++) {
                        dataArray[dst] = (row + sx).value;
                    }
                    dst += dstStride;
                }
                break;
            }
            case cairo_format.CAIRO_FORMAT_A1: {
                // TODO Should this be totally packed, or maintain a stride divisible by 4?
                throw "getImageData for CANVAS_FORMAT_A1 is not yet implemented";
            }
            case cairo_format.CAIRO_FORMAT_RGB16_565: {
                for (int y = 0; y < sh; ++y) {
                    ffi.Pointer<ffi.Uint16> row = (src.cast<ffi.Uint16>() + srcStride * (y + sy));
                    for (int i = 0; i < dstStride; i++) {
                        dataArray[dst] = (row + sx + i).value;
                    }
                    dst += dstStride;
                }
            }
            default: {
                // Unlikely
                throw "Invalid pixel format or not an image canvas";
            }
        }
        
        return ImageData(dataArray, sw, sh);
    }

    /*
    * Put image data.
    *
    *  - imageData, dx, dy
    *  - imageData, dx, dy, sx, sy, sw, sh
    *
    */
    void putImageData(ImageData imageData, num dx_, num dy_, [num? dirtyX, num? dirtyY, num? dirtyWidth, num? dirtyHeight]) {
        var src = imageData.data;
        var dst = this.canvas.data();

        int dstStride = this.canvas.stride();
        int Bpp = (dstStride / this.canvas.getWidth()).toInt();
        int srcStride = (Bpp * imageData.width).toInt();

        int sx = 0, 
            sy = 0, 
            sw = 0, 
            sh = 0, 
            dx = dx_.toInt(), 
            dy = dy_.toInt(), 
            rows, 
            cols;

        if (dirtyX == null) {
            // imageData, dx, dy
            sw = imageData.width;
            sh = imageData.height;
        } else {
            // imageData, dx, dy, sx, sy, sw, sh

            if (dirtyX == null || dirtyY == null || dirtyWidth == null || dirtyHeight == null) {
                throw "invalid arguments";
            }

            sx = dirtyX.toInt();
            sy = dirtyY.toInt();
            sw = dirtyWidth.toInt();
            sh = dirtyHeight.toInt();
            // fix up negative height, width
            if (sw < 0) {
                sx += sw;
                sw = -sw;
            }
            if (sh < 0) {
                sy += sh;
                sh = -sh;
            }
            // clamp the left edge
            if (sx < 0) {
                sw += sx;
                sx = 0;
            }
            if (sy < 0) {
                sh += sy;
                sy = 0;
            }
            // clamp the right edge
            if (sx + sw > imageData.width) sw = imageData.width - sx;
            if (sy + sh > imageData.height) sh = imageData.height - sy;
            // start destination at source offset
            dx += sx;
            dy += sy;
        }

        // chop off outlying source data
        if (dx < 0) {
            sw += dx;
            sx -= dx;
            dx = 0;
        }
        if (dy < 0) {
            sh += dy;
            sy -= dy;
            dy = 0;
        }
        // clamp width at canvas size
        // Need to wrap std::min calls using parens to prevent macro expansion on
        // windows. See http://stackoverflow.com/questions/5004858/stdmin-gives-error
        cols = Math.min(sw, this.canvas.getWidth() - dx);
        rows = Math.min(sh, this.canvas.getHeight() - dy);

        if (cols <= 0 || rows <= 0) return;

        int srcIdx = 0;
        int dstIdx = 0;

        switch (this.canvas.backend().format) {
            case cairo_format.CAIRO_FORMAT_ARGB32: {
                srcIdx += sy * srcStride + sx * 4;
                dstIdx += dstStride * dy + 4 * dx;
                for (int y = 0; y < rows; ++y) {
                    int dstRowIdx = dstIdx;
                    int srcRowIdx = srcIdx;
                    for (int x = 0; x < cols; ++x) {
                        // rgba
                        int r = src[srcRowIdx++];
                        int g = src[srcRowIdx++];
                        int b = src[srcRowIdx++];
                        int a = src[srcRowIdx++];

                        // argb
                        // performance optimization: fully transparent/opaque pixels can be
                        // processed more efficiently.
                        if (a == 0) {
                            dst[dstRowIdx++] = 0;
                            dst[dstRowIdx++] = 0;
                            dst[dstRowIdx++] = 0;
                            dst[dstRowIdx++] = 0;
                        } else if (a == 255) {
                            dst[dstRowIdx++] = b;
                            dst[dstRowIdx++] = g;
                            dst[dstRowIdx++] = r;
                            dst[dstRowIdx++] = a;
                        } else {
                            double alpha = a / 255;
                            dst[dstRowIdx++] = (b * alpha).toInt();
                            dst[dstRowIdx++] = (g * alpha).toInt();
                            dst[dstRowIdx++] = (r * alpha).toInt();
                            dst[dstRowIdx++] = a;
                        }
                    }
                    dstIdx += dstStride;
                    srcIdx += srcStride;
                }
                break;
            }
            case cairo_format.CAIRO_FORMAT_RGB24: {
                srcIdx += sy * srcStride + sx * 4;
                dstIdx += dstStride * dy + 4 * dx;
                for (int y = 0; y < rows; ++y) {
                    int dstRowIdx = dstIdx;
                    int srcRowIdx = srcIdx;
                    for (int x = 0; x < cols; ++x) {
                        // rgba
                        int r = src[srcRowIdx++];
                        int g = src[srcRowIdx++];
                        int b = src[srcRowIdx++];
                        srcRowIdx++;

                        // argb
                        dst[dstRowIdx++] = b;
                        dst[dstRowIdx++] = g;
                        dst[dstRowIdx++] = r;
                        dst[dstRowIdx++] = 255;
                    }
                    dstIdx += dstStride;
                    srcIdx += srcStride;
                }
                break;
            }
            case cairo_format.CAIRO_FORMAT_A8: {
                srcIdx += sy * srcStride + sx;
                dstIdx += dstStride * dy + dx;
                if (srcStride == dstStride && cols == dstStride) {
                    // fast path: strides are the same and doing a full-width put
                    for (int i = 0; i < cols * rows; i++) {
                        dst[dstIdx + i] = src[srcIdx + i];
                    }
                } else {
                    for (int y = 0; y < rows; ++y) {
                        for (int i = 0; i < cols; i++) {
                            dst[dstIdx + i] = src[srcIdx + i];
                        }
                        dstIdx += dstStride;
                        srcIdx += srcStride;
                    }
                }
                break;
            }
            case cairo_format.CAIRO_FORMAT_A1: {
                // TODO Should this be totally packed, or maintain a stride divisible by 4?
                throw "putImageData for CANVAS_FORMAT_A1 is not yet implemented";
            }
            case cairo_format.CAIRO_FORMAT_RGB16_565: {
                srcIdx += sy * srcStride + sx * 2;
                dstIdx += dstStride * dy + 2 * dx;
                for (int y = 0; y < rows; ++y) {
                    for (int i = 0; i < cols * 2; i++) {
                        dst[dstIdx + i] = src[srcIdx + i];
                    }
                    dstIdx += dstStride;
                    srcIdx += srcStride;
                }
                break;
            }
            default: {
                throw "Invalid pixel format or not an image canvas";
            }
        }

        cairo.cairo_surface_mark_dirty_rectangle(
            this.canvas.surface(), 
            dx, dy, 
            cols, rows
        );
    }

    /*
    * Draw image src image to the destination (context).
    *
    *  - dx, dy
    *  - dx, dy, dw, dh
    *  - sx, sy, sw, sh, dx, dy, dw, dh
    *
    */
    void drawImage(Canvas image, num a, num b, [num? c, num? d, num? e, num? f, num? g, num? h]) {
        double sx = 0,
            sy = 0,
            sw = 0, 
            sh = 0, 
            dx = 0, 
            dy = 0, 
            dw = 0, 
            dh = 0;
        double source_w = 0;
        double source_h = 0;

        ffi.Pointer<cairo_surface_t> surface;

        // TODO: Implement Images
        // Image
        // if (image is Image) {
        //     Image *img = Image::Unwrap(obj);
        //     if (!img->isComplete()) {
        //         Napi::Error::New(env, "Image given has not completed loading").ThrowAsJavaScriptException();
        //         return;
        //     }
        //     source_w = sw = img->width;
        //     source_h = sh = img->height;
        //     surface = img->surface();
        // } 

        // Canvas
        if (image is Canvas) {
            Canvas canvas = image;
            source_w = sw = canvas.getWidth().toDouble();
            source_h = sh = canvas.getHeight().toDouble();
            surface = canvas.surface();

        // Invalid
        } else {
            throw "Image or Canvas expected";
        }

        ffi.Pointer<cairo_t> ctx = _context;

        // Arguments
        if (h != null) {
            // img, sx, sy, sw, sh, dx, dy, dw, dh
            if (c == null || d == null || e == null || f == null || g == null) {
                return;
            }

            sx = a.toDouble();
            sy = b.toDouble();
            sw = c.toDouble();
            sh = d.toDouble();
            dx = e.toDouble();
            dy = f.toDouble();
            dw = g.toDouble();
            dh = h.toDouble();
        }
        if (d != null) {
            // img, dx, dy, dw, dh
            if (c == null) {
                return;
            }

            dx = a.toDouble();
            dy = b.toDouble();
            dw = c.toDouble();
            dh = d.toDouble();
        } else {
            dx = a.toDouble();
            dy = b.toDouble();
            dw = sw;
            dh = sh;
        }
        
        if (sw == 0 || sh == 0 || dw == 0 || dh == 0)
            return;

        // Start draw
        cairo.cairo_save(ctx);

        ffi.Pointer<cairo_matrix_t> matrix = malloc();
        List<double> transforms = [0, 0, 0, 0, 0, 0];
        cairo.cairo_get_matrix(ctx, matrix);
        decompose_matrix(matrix.ref, transforms);
        malloc.free(matrix);
        // extract the scale value from the current transform so that we know how many pixels we
        // need for our extra canvas in the drawImage operation.
        double current_scale_x = transforms[1].abs();
        double current_scale_y = transforms[2].abs();
        double extra_dx = 0;
        double extra_dy = 0;
        double fx = dw / sw * current_scale_x; // transforms[1] is scale on X
        double fy = dh / sh * current_scale_y; // transforms[2] is scale on X
        bool needScale = dw != sw || dh != sh;
        bool needCut = sw != source_w || sh != source_h || sx < 0 || sy < 0;
        bool sameCanvas = surface == this.canvas.surface();
        bool needsExtraSurface = sameCanvas || needCut || needScale;
        ffi.Pointer<cairo_surface_t> surfTemp = ffi.nullptr;
        ffi.Pointer<cairo_t> ctxTemp = ffi.nullptr;

        if (needsExtraSurface) {
            // we want to create the extra surface as small as possible.
            // fx and fy are the total scaling we need to apply to sw, sh.
            // from sw and sh we want to remove the part that is outside the source_w and soruce_h
            double real_w = sw;
            double real_h = sh;
            double translate_x = 0;
            double translate_y = 0;
            // if sx or sy are negative, a part of the area represented by sw and sh is empty
            // because there are empty pixels, so we cut it out.
            // On the other hand if sx or sy are positive, but sw and sh extend outside the real
            // source pixels, we cut the area in that case too.
            if (sx < 0) {
                extra_dx = -sx * fx;
                real_w = sw + sx;
            } else if (sx + sw > source_w) {
                real_w = sw - (sx + sw - source_w);
            }
            if (sy < 0) {
                extra_dy = -sy * fy;
                real_h = sh + sy;
            } else if (sy + sh > source_h) {
                real_h = sh - (sy + sh - source_h);
            }
            // if after cutting we are still bigger than source pixels, we restrict again
            if (real_w > source_w) {
                real_w = source_w;
            }
            if (real_h > source_h) {
                real_h = source_h;
            }
            // TODO: find a way to limit the surfTemp to real_w and real_h if fx and fy are bigger than 1.
            // there are no more pixel than the one available in the source, no need to create a bigger surface.
            surfTemp = cairo.cairo_image_surface_create(cairo_format.CAIRO_FORMAT_ARGB32, (real_w * fx).round(), (real_h * fy).round());
            ctxTemp = cairo.cairo_create(surfTemp);
            cairo.cairo_scale(ctxTemp, fx, fy);
            if (sx > 0) {
                translate_x = sx;
            }
            if (sy > 0) {
                translate_y = sy;
            }
            cairo.cairo_set_source_surface(ctxTemp, surface, -translate_x, -translate_y);
            cairo.cairo_pattern_set_filter(cairo.cairo_get_source(ctxTemp), state.imageSmoothingEnabled ? state.patternQuality : cairo_filter.CAIRO_FILTER_NEAREST);
            cairo.cairo_pattern_set_extend(cairo.cairo_get_source(ctxTemp), cairo_extend.CAIRO_EXTEND_REFLECT);
            cairo.cairo_paint_with_alpha(ctxTemp, 1);
            surface = surfTemp;
        }
        // apply shadow if there is one
        if (hasShadow()) {
            if (state.shadowBlur != 0) {
                // we need to create a new surface in order to blur
                int pad = state.shadowBlur * 2;
                ffi.Pointer<cairo_surface_t> shadow_surface = cairo.cairo_image_surface_create(cairo_format.CAIRO_FORMAT_ARGB32, (dw + 2 * pad).toInt(), (dh + 2 * pad).toInt());
                ffi.Pointer<cairo_t> shadow_context = cairo.cairo_create(shadow_surface);

                // mask and blur
                setCtxSourceRGBA(shadow_context, state.shadow);
                cairo.cairo_mask_surface(shadow_context, surface, pad.toDouble(), pad.toDouble());
                blur(shadow_surface, state.shadowBlur);

                // paint
                // @note: ShadowBlur looks different in each browser. This implementation matches chrome as close as possible.
                //        The 1.4 offset comes from visual tests with Chrome. I have read the spec and part of the shadowBlur
                //        implementation, and its not immediately clear why an offset is necessary, but without it, the result
                //        in chrome is different.
                cairo.cairo_set_source_surface(
                    ctx, shadow_surface,
                    dx + state.shadowOffsetX - pad + 1.4,
                    dy + state.shadowOffsetY - pad + 1.4
                );
                cairo.cairo_paint(ctx);
                // cleanup
                cairo.cairo_destroy(shadow_context);
                cairo.cairo_surface_destroy(shadow_surface);
            } else {
                setSourceRGBA(state.shadow);
                cairo.cairo_mask_surface(
                    ctx, surface,
                    dx + (state.shadowOffsetX),
                    dy + (state.shadowOffsetY)
                );
            }
        }

        double scaled_dx = dx;
        double scaled_dy = dy;

        if (needsExtraSurface && (current_scale_x != 1 || current_scale_y != 1)) {
            // in this case our surface contains already current_scale_x, we need to scale back
            cairo.cairo_scale(ctx, 1 / current_scale_x, 1 / current_scale_y);
            scaled_dx *= current_scale_x;
            scaled_dy *= current_scale_y;
        }
        // Paint
        cairo.cairo_set_source_surface(ctx, surface, scaled_dx + extra_dx, scaled_dy + extra_dy);
        cairo.cairo_pattern_set_filter(cairo.cairo_get_source(ctx), state.imageSmoothingEnabled ? state.patternQuality : cairo_filter.CAIRO_FILTER_NEAREST);
        cairo.cairo_pattern_set_extend(cairo.cairo_get_source(ctx), cairo_extend.CAIRO_EXTEND_NONE);
        cairo.cairo_paint_with_alpha(ctx, state.globalAlpha);

        cairo.cairo_restore(ctx);

        if (needsExtraSurface) {
            cairo.cairo_destroy(ctxTemp);
            cairo.cairo_surface_destroy(surfTemp);
        }
    }
}