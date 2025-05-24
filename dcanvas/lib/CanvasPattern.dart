// import 'package:cairo/cairo.dart';
import 'package:ffi/ffi.dart';

import './backend/Backend.dart';
import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart';

/*
 * Canvas types.
 */
typedef repeat_type_t = int;
class RepeatType {
    static const repeat_type_t NO_REPEAT = 0;  // match CAIRO_EXTEND_NONE
    static const repeat_type_t REPEAT = 1;  // match CAIRO_EXTEND_REPEAT
    static const repeat_type_t REPEAT_X = 2; // needs custom processing
    static const repeat_type_t REPEAT_Y = 3; // needs custom processing
}

ffi.Pointer<cairo_user_data_key_t> pattern_repeat_key = malloc<cairo_user_data_key_t>();

class Pattern {
    ffi.Pointer<cairo_pattern_t> _pattern;
    repeat_type_t _repeat = RepeatType.REPEAT;

    Pattern(this._pattern, this._repeat);
    // static void Initialize(Napi::Env& env, Napi::Object& target);
    // void setTransform(const Napi::CallbackInfo& info);
    static repeat_type_t get_repeat_type_for_cairo_pattern(ffi.Pointer<cairo_pattern_t> pattern) {
        ffi.Pointer<ffi.Void> ud = cairo.cairo_pattern_get_user_data(pattern, pattern_repeat_key);
        final enumVal = ud.cast<ffi.Pointer<ffi.Int>>().value.value;
        if (enumVal < 0 || enumVal > 3)
            throw "repeat_type_t out of bounds";
        return enumVal;
    }
    ffi.Pointer<cairo_pattern_t> pattern(){ return this._pattern; }
}
