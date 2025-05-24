import './CanvasRenderingContext.dart';

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

List<int> HSBtoRGB(num h, num s, num b) {
    // https://www.30secondsofcode.org/js/s/hsb-to-rgb
    final f = (num h, num s, num b, num n) {
        final num k = (n + h / 60) % 6;
        return b * (1 - s * max_([0, min_([k, 4 - k, 1])]));
    };
    s /= 100;
    b /= 100;
    return [(f(h, s, b, 5) * 255).toInt(), (f(h, s, b, 3) * 255).toInt(), (f(h, s, b, 1) * 255).toInt()];
}

RGBA hexToRGBA(String hex) {
    List<double> vals = [0.0, 0.0, 0.0, 255.0];
    for (int i = 1; i < hex.length; i += 2) {
        final s = hex.substring(i, i + 2);
        vals[((i - 1) / 2).toInt()] = int.parse(s, radix: 16) / 255;
    }
    return RGBA(vals[0], vals[1], vals[2], vals[3]);
}

RGBA rgbrgbaStringToRGBA(String str) {
    List<double> vals = [0.0, 0.0, 0.0, 255.0];
    var slc = str.substring(str.indexOf("(") + 1, str.length - 1);
    var strVals = slc.split(","); 
    for (int i = 0; i < strVals.length; i++) {
        var valSlc = strVals[i];
        late double val;
        if (i != 3) {
            val = int.parse(valSlc.trimLeft()) / 255;
        } else {
            val = double.parse(valSlc.trimLeft());
        }
        vals[i] = val;
    }
    return RGBA(vals[0], vals[1], vals[2], vals[3]);
}

const namedColorPairs = {
    "transparent": 0xFFFFFF00,
    "aliceblue": 0xF0F8FFFF,
    "antiquewhite": 0xFAEBD7FF,
    "aqua": 0x00FFFFFF,
    "aquamarine": 0x7FFFD4FF,
    "azure": 0xF0FFFFFF,
    "beige": 0xF5F5DCFF,
    "bisque": 0xFFE4C4FF,
    "black": 0x000000FF,
    "blanchedalmond": 0xFFEBCDFF,
    "blue": 0x0000FFFF,
    "blueviolet": 0x8A2BE2FF,
    "brown": 0xA52A2AFF,
    "burlywood": 0xDEB887FF,
    "cadetblue": 0x5F9EA0FF,
    "chartreuse": 0x7FFF00FF,
    "chocolate": 0xD2691EFF,
    "coral": 0xFF7F50FF,
    "cornflowerblue": 0x6495EDFF,
    "cornsilk": 0xFFF8DCFF,
    "crimson": 0xDC143CFF,
    "cyan": 0x00FFFFFF,
    "darkblue": 0x00008BFF,
    "darkcyan": 0x008B8BFF,
    "darkgoldenrod": 0xB8860BFF,
    "darkgray": 0xA9A9A9FF,
    "darkgreen": 0x006400FF,
    "darkgrey": 0xA9A9A9FF,
    "darkkhaki": 0xBDB76BFF,
    "darkmagenta": 0x8B008BFF,
    "darkolivegreen": 0x556B2FFF,
    "darkorange": 0xFF8C00FF,
    "darkorchid": 0x9932CCFF,
    "darkred": 0x8B0000FF,
    "darksalmon": 0xE9967AFF,
    "darkseagreen": 0x8FBC8FFF,
    "darkslateblue": 0x483D8BFF,
    "darkslategray": 0x2F4F4FFF,
    "darkslategrey": 0x2F4F4FFF,
    "darkturquoise": 0x00CED1FF,
    "darkviolet": 0x9400D3FF,
    "deeppink": 0xFF1493FF,
    "deepskyblue": 0x00BFFFFF,
    "dimgray": 0x696969FF,
    "dimgrey": 0x696969FF,
    "dodgerblue": 0x1E90FFFF,
    "firebrick": 0xB22222FF,
    "floralwhite": 0xFFFAF0FF,
    "forestgreen": 0x228B22FF,
    "fuchsia": 0xFF00FFFF,
    "gainsboro": 0xDCDCDCFF,
    "ghostwhite": 0xF8F8FFFF,
    "gold": 0xFFD700FF,
    "goldenrod": 0xDAA520FF,
    "gray": 0x808080FF,
    "green": 0x008000FF,
    "greenyellow": 0xADFF2FFF,
    "grey": 0x808080FF,
    "honeydew": 0xF0FFF0FF,
    "hotpink": 0xFF69B4FF,
    "indianred": 0xCD5C5CFF,
    "indigo": 0x4B0082FF,
    "ivory": 0xFFFFF0FF,
    "khaki": 0xF0E68CFF,
    "lavender": 0xE6E6FAFF,
    "lavenderblush": 0xFFF0F5FF,
    "lawngreen": 0x7CFC00FF,
    "lemonchiffon": 0xFFFACDFF,
    "lightblue": 0xADD8E6FF,
    "lightcoral": 0xF08080FF,
    "lightcyan": 0xE0FFFFFF,
    "lightgoldenrodyellow": 0xFAFAD2FF,
    "lightgray": 0xD3D3D3FF,
    "lightgreen": 0x90EE90FF,
    "lightgrey": 0xD3D3D3FF,
    "lightpink": 0xFFB6C1FF,
    "lightsalmon": 0xFFA07AFF,
    "lightseagreen": 0x20B2AAFF,
    "lightskyblue": 0x87CEFAFF,
    "lightslategray": 0x778899FF,
    "lightslategrey": 0x778899FF,
    "lightsteelblue": 0xB0C4DEFF,
    "lightyellow": 0xFFFFE0FF,
    "lime": 0x00FF00FF,
    "limegreen": 0x32CD32FF,
    "linen": 0xFAF0E6FF,
    "magenta": 0xFF00FFFF,
    "maroon": 0x800000FF,
    "mediumaquamarine": 0x66CDAAFF,
    "mediumblue": 0x0000CDFF,
    "mediumorchid": 0xBA55D3FF,
    "mediumpurple": 0x9370DBFF,
    "mediumseagreen": 0x3CB371FF,
    "mediumslateblue": 0x7B68EEFF,
    "mediumspringgreen": 0x00FA9AFF,
    "mediumturquoise": 0x48D1CCFF,
    "mediumvioletred": 0xC71585FF,
    "midnightblue": 0x191970FF,
    "mintcream": 0xF5FFFAFF,
    "mistyrose": 0xFFE4E1FF,
    "moccasin": 0xFFE4B5FF,
    "navajowhite": 0xFFDEADFF,
    "navy": 0x000080FF,
    "oldlace": 0xFDF5E6FF,
    "olive": 0x808000FF,
    "olivedrab": 0x6B8E23FF,
    "orange": 0xFFA500FF,
    "orangered": 0xFF4500FF,
    "orchid": 0xDA70D6FF,
    "palegoldenrod": 0xEEE8AAFF,
    "palegreen": 0x98FB98FF,
    "paleturquoise": 0xAFEEEEFF,
    "palevioletred": 0xDB7093FF,
    "papayawhip": 0xFFEFD5FF,
    "peachpuff": 0xFFDAB9FF,
    "peru": 0xCD853FFF,
    "pink": 0xFFC0CBFF,
    "plum": 0xDDA0DDFF,
    "powderblue": 0xB0E0E6FF,
    "purple": 0x800080FF,
    "rebeccapurple": 0x663399FF,
    "red": 0xFF0000FF,
    "rosybrown": 0xBC8F8FFF,
    "royalblue": 0x4169E1FF,
    "saddlebrown": 0x8B4513FF,
    "salmon": 0xFA8072FF,
    "sandybrown": 0xF4A460FF,
    "seagreen": 0x2E8B57FF,
    "seashell": 0xFFF5EEFF,
    "sienna": 0xA0522DFF,
    "silver": 0xC0C0C0FF,
    "skyblue": 0x87CEEBFF,
    "slateblue": 0x6A5ACDFF,
    "slategray": 0x708090FF,
    "slategrey": 0x708090FF,
    "snow": 0xFFFAFAFF,
    "springgreen": 0x00FF7FFF,
    "steelblue": 0x4682B4FF,
    "tan": 0xD2B48CFF,
    "teal": 0x008080FF,
    "thistle": 0xD8BFD8FF,
    "tomato": 0xFF6347FF,
    "turquoise": 0x40E0D0FF,
    "violet": 0xEE82EEFF,
    "wheat": 0xF5DEB3FF,
    "white": 0xFFFFFFFF,
    "whitesmoke": 0xF5F5F5FF,
    "yellow": 0xFFFF00FF,
    "yellowgreen": 0x9ACD32FF,
};

RGBA nameToRGBA(String name) {
    final out = namedColorPairs[name.toLowerCase()];
    if (out != null) {
        final r = (out >> 24) / 255, 
              g = (out >> 16 & 0xff) / 255, 
              b = (out >> 8 & 0xff) / 255, 
              a = (out & 0xff) / 255;
        return RGBA(r, g, b, a == 0 ? 1 : a);
    }
    throw "unknown color name";
}

class RGBA {
    double r, g, b, a;
    RGBA(this.r, this.g, this.b, this.a);

    static RGBA fromString(String str) {
        str = str.trimLeft();
        if ('#' == str[0]) {
            return hexToRGBA(str);
        }
        if (str.startsWith("rgb")) {
            return rgbrgbaStringToRGBA(str);
        }
        if (str.startsWith("hsl")) {
            var out = rgbrgbaStringToRGBA(str);
            var rgb = HSBtoRGB(out.r * 255, out.g * 255, out.b * 255);
            out.r = rgb[0].toDouble();
            out.g = rgb[1].toDouble();
            out.b = rgb[2].toDouble();
            return out;
        }
        return nameToRGBA(str);
    }

    RGBA clone() {
        return RGBA(r, g, b, a);
    }

    String toString() {
        return "RGBA(${r.toStringAsFixed(2)}, ${g.toStringAsFixed(2)}, ${b.toStringAsFixed(2)}, ${a.toStringAsFixed(2)})";
    }
}
