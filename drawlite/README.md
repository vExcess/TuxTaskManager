# Drawlite
A lightweight (17 KB minified) yet powerful cross platform graphics library inspired by Processing

Drawlite has a JavaScript implementation for drawing graphics in web browsers and a Dart implementation for drawing graphics natively. The Dart implementation relies on my dcanvas library which is a native implementation of HTML Canvas in Dart.

## Examples
You can find example usage in `demo.html` in the `javascript` directory and `demo.dart` in the `dart` directory.

## Quick Start Templates
### JavaScript
```js
let DL = Drawlite(canvas);
let { size, fill, rect, get } = DL;

size(400, 400);
DL.draw = function () {
    fill(255, 0, 0);
    rect(get.mouseX, get.mouseY, 100, 100);
};
```

### Dart
```dart
import 'package:dcanvas/dcanvas.dart' show Canvas;
import '../drawlite/drawlite.dart'
    show Drawlite;
import '../drawlite/dl.dart';

void main() {
    var canvas = Canvas(400, 400);
    var dl = Drawlite(canvas);
    fill = dl.fill;
    rect = dl.rect;
    get = dl.get;
    
    fill(255, 0, 0);
    rect(get.mouseX, get.mouseY, 100, 100);
}
```

## Documentation
View the documentation in the `docs.md` file.