import 'package:dcanvas/CanvasRenderingContext.dart';

export './Canvas.dart';
export './CanvasRenderingContext.dart';

CSSColor rgba(num r, num g, num b, num a) {
    return CSSColor(r.toInt(), g.toInt(), b.toInt(), a.toDouble());
}

CSSColor rgb(num r, num g, num b) {
    return CSSColor(r.toInt(), g.toInt(), b.toInt(), 1.0);
}

