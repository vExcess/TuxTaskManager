import 'dart:ffi' as ffi;
import 'package:dcanvas/backend/sdl/sdl-bindings.dart';

import '../Canvas.dart';

import './cairo/cairo.dart' as CairoBindings;
export './cairo/cairo.dart'
    show cairo_surface_t, cairo_t, cairo_path_t, cairo_pattern_t, cairo_matrix_t,
    cairo_user_data_key_t, cairo_pattern_type, cairo_format, cairo_extend, cairo_filter,
    cairo_operator, cairo_line_cap, cairo_line_join;

import './pango/pango.dart' as PangoBindings;
export './pango/pango.dart' 
    show PangoLib, PangoFontDescription, PANGO_SCALE, PangoLayout, PangoStyle, PangoWeight, 
    PangoRectangle, PangoFontMetrics;

import './sdl/sdl.dart' as SDLBindings;
export './sdl/sdl.dart'
    show SDL_Window, SDL_Renderer, SDL_Surface, SDL_WINDOWPOS_UNDEFINED, SDL_WindowFlags,
    SDL_RendererFlags, SDL_EventType, SDL_Event, SDL_INIT_EVERYTHING, SDL_BUTTON_LEFT, SDL_BUTTON_MIDDLE, SDL_BUTTON_RIGHT;

typedef cairo_status = CairoBindings.cairo_status1;
typedef cairo_pattern_type_t = int;

bool systemLibrariesLoaded = false;
late CairoBindings.Cairo cairo;
late PangoBindings.Pango pango;
late SDLBindings.SDL sdl;
void loadSDLPangoCairo() {
    if (!systemLibrariesLoaded) {
        // load cairo
        CairoBindings.CairoLib.load();
        cairo = CairoBindings.CairoLib.cairo;

        // load pango
        PangoBindings.PangoLib.load();
        pango = PangoBindings.PangoLib.pango;

        // load sdl
        SDLBindings.SDLLib.load();
        sdl = SDLBindings.SDLLib.sdl;

        systemLibrariesLoaded = true;
    }
}

typedef cairo_format = CairoBindings.cairo_format;

class Backend {
    String name = "image";
    String error = "NULL";

    late int width;
    late int height;
    ffi.Pointer<CairoBindings.cairo_surface_t> surface = ffi.nullptr;
    Canvas? canvas = null;

    Backend(this.width, this.height) {
        loadSDLPangoCairo();
    }

    static const cairo_format DEFAULT_FORMAT = cairo_format.CAIRO_FORMAT_ARGB32;
    cairo_format format = DEFAULT_FORMAT;

    int approxBytesPerPixel() {
        switch (format) {
            case cairo_format.CAIRO_FORMAT_ARGB32: case cairo_format.CAIRO_FORMAT_RGB24:
                return 4;
            case cairo_format.CAIRO_FORMAT_RGB16_565:
                return 2;
            case cairo_format.CAIRO_FORMAT_A8: case cairo_format.CAIRO_FORMAT_A1:
                return 1;
            default:
                return 0;
        }
    }

    void setCanvas(Canvas canvas) {
        this.canvas = canvas;
    }

    String getName() {
        return this.name;
    }

    ffi.Pointer<CairoBindings.cairo_surface_t> createSurface() {
        surface = cairo.cairo_image_surface_create(format, width, height);
        return surface;
    }

    ffi.Pointer<CairoBindings.cairo_surface_t> getSurface() {
        if (surface == ffi.nullptr) createSurface();
        return surface;
    }

    void setFormat(cairo_format format) {
        this.format = format;
    }
}
