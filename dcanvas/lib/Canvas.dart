import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart';

import './CanvasRenderingContext.dart';
import './backend/Backend.dart';

/*
 * FontFace describes a font file in terms of one PangoFontDescription that
 * will resolve to it and one that the user describes it as (like @font-face)
 */
class FontFace {
    ffi.Pointer<PangoFontDescription> sys_desc = ffi.nullptr;
    ffi.Pointer<PangoFontDescription> user_desc = ffi.nullptr;
    String file_path = "";
    FontFace();
}

typedef canvas_draw_mode_t = int;
class CanvasDrawMode {
    static final int TEXT_DRAW_PATHS = 0;
    static final int TEXT_DRAW_GLYPHS = 1;
}

List<FontFace> font_face_list = [];

typedef text_align_t = int;
class TextAlign {
    static const text_align_t TEXT_ALIGNMENT_LEFT = -1;
    static const text_align_t TEXT_ALIGNMENT_CENTER = 0;
    static const text_align_t TEXT_ALIGNMENT_RIGHT = 1;
    // Currently same as LEFT and RIGHT without RTL support:
    static const text_align_t TEXT_ALIGNMENT_START = -2;
    static const text_align_t TEXT_ALIGNMENT_END = 2;
}

typedef text_baseline_t = int;
class TextBaseline {
    static const text_baseline_t TEXT_BASELINE_ALPHABETIC = 0;
    static const text_baseline_t TEXT_BASELINE_TOP = 1;
    static const text_baseline_t TEXT_BASELINE_BOTTOM = 2;
    static const text_baseline_t TEXT_BASELINE_MIDDLE = 3;
    static const text_baseline_t TEXT_BASELINE_IDEOGRAPHIC = 4;
    static const text_baseline_t TEXT_BASELINE_HANGING = 5;
}

class Canvas {
    Context2D? context;
    Backend? _backend;

    late int width;
    late int height;

    Canvas(num width, num height) {
        this.width = width.toInt();
        this.height = height.toInt();
        Backend backend = Backend(this.width, this.height);
        backend.setCanvas(this);
        this._backend = backend;
    }

    Backend backend() { return this._backend!; }
    ffi.Pointer<cairo_surface_t> surface(){ return _backend!.getSurface(); }


    ffi.Pointer<ffi.Uint8> data(){ return cairo.cairo_image_surface_get_data(surface()).cast(); }
    int stride(){ return cairo.cairo_image_surface_get_stride(surface()); }
    int nBytes(){
      return _backend!.height * stride();
    }

    int getWidth() { return _backend!.width; }
    int getHeight() { return _backend!.height; }

    /**
     * Wrapper around cairo_create()
     * (do not call cairo_create directly, call this instead)
     */
    ffi.Pointer<cairo_t> createCairoContext() {
        ffi.Pointer<cairo_t> ret = cairo.cairo_create(surface());
        cairo.cairo_set_line_width(ret, 1); // Cairo defaults to 2
        return ret;
    }

    Context2D getContext(String ctxType, [Map<String, Object>? ctxAttribs]) {
        if (ctxType == "2d") {
            if (this.context == null) {
                ctxAttribs ??= {};
                this.context = new Context2D(this, ctxAttribs);
            }
            this.context!.canvas = this;
            return this.context!;
        }
        throw "Only 2d context are supported";
    }
}

/*
 * Get a PangoStyle from a CSS string (like "italic")
 */

PangoStyle getStyleFromCSSString(String style) {
    PangoStyle s = PangoStyle.PANGO_STYLE_NORMAL;

    if (style.isNotEmpty) {
        if ("italic" == style) {
            s = PangoStyle.PANGO_STYLE_ITALIC;
        } else if ("oblique" == style) {
            s = PangoStyle.PANGO_STYLE_OBLIQUE;
        }
    }

    return s;
}

String dartStringFromPtr(ffi.Pointer<ffi.Char> ptr) {
    var out = "";
    var chIdx = 0;
    while (true) {
        final chCode = ffi.Pointer<ffi.Char>.fromAddress(ptr.address + chIdx).value;
        if (chCode == 0) {
            break;
        }
        final ch = String.fromCharCode(chCode);
        out += ch;
        chIdx++;
    }
    return out;
}

/*
 * Given a user description, return a description that will select the
 * font either from the system or @font-face
 */
ffi.Pointer<PangoFontDescription> resolveFontDescription(final ffi.Pointer<PangoFontDescription> desc) {
    // One of the user-specified families could map to multiple SFNT family names
    // if someone registered two different fonts under the same family name.
    // https://drafts.csswg.org/css-fonts-3/#font-style-matching
    FontFace best = FontFace();
    final families = dartStringFromPtr(pango.pango_font_description_get_family(desc)).split(",");
    Set<ffi.Pointer<ffi.Char>> seen_families = Set();
    String resolved_families = "";
    bool first = true;

    for (final family in families) {
        String renamed_families = "";
        for (final ff in font_face_list) {
            String pangofamily = dartStringFromPtr(pango.pango_font_description_get_family(ff.user_desc));
            if (family.toLowerCase() == pangofamily.toLowerCase()) {
                ffi.Pointer<ffi.Char> sys_desc_family_name = pango.pango_font_description_get_family(ff.sys_desc);
                bool unseen = !seen_families.contains(sys_desc_family_name);
                bool better = best.user_desc == ffi.nullptr || pango.pango_font_description_better_match(desc, best.user_desc, ff.user_desc) != 0;

                // Avoid sending duplicate SFNT font names due to a bug in Pango for macOS:
                // https://bugzilla.gnome.org/show_bug.cgi?id=762873
                if (unseen) {
                    seen_families.add(sys_desc_family_name);

                    if (better) {
                        renamed_families = dartStringFromPtr(sys_desc_family_name) + (renamed_families.isNotEmpty ? "," : "") + renamed_families;
                    } else {
                        renamed_families += (renamed_families.isNotEmpty ? "," : "") + dartStringFromPtr(sys_desc_family_name);
                    }
                }

                if (first && better) best = ff;
            }
        }

        if (resolved_families.isNotEmpty) resolved_families += ',';
        resolved_families += renamed_families.isNotEmpty ? renamed_families : family;
        first = false;
    }

    ffi.Pointer<PangoFontDescription> ret = pango.pango_font_description_copy(best.sys_desc != ffi.nullptr ? best.sys_desc : desc);
    var resolvedFamilies = resolved_families.toNativeUtf8();
    pango.pango_font_description_set_family(ret, resolvedFamilies.cast());
    malloc.free(resolvedFamilies);

    return ret;
}