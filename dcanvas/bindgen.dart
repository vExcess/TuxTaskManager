import 'dart:async';
import 'dart:io';

final cairoConfig = """
name: Cairo
description: "Cairo Dart bindings"

output: "./lib/backend/cairo/cairo-bindings.dart"
sort: true

headers:
  entry-points:
    - "/usr/include/cairo/cairo.h"
    - "/usr/include/cairo/cairo-boilerplate.h"

comments:
  style: any
  length: full

enums:
  rename:
    "_(.*)": "\$1"

unions:
  exclude:
    - "_cairo_path_data_t"

silence-enum-warning: true
""".trim();

final pangoConfig = """
name: Pango
description: "Pango Dart Bindings"

output: './lib/backend/pango/pango-bindings.dart'

headers:
  entry-points:
    - '/usr/include/pango-1.0/pango/pangocairo.h'
  include-directives:
    - '/usr/include/pango-1.0/pango/pangocairo.h'
    - '/usr/include/pango-1.0/pango/pango-font.h'
    - '/usr/include/pango-1.0/pango/pango-types.h'
    - '/usr/include/pango-1.0/pango/pango-layout.h'
    - '/usr/include/pango-1.0/pango/pango-context.h'

llvm-path:
  - '/usr/lib/llvm-18'

compiler-opts:
  - '-I /usr/include/pango-1.0'
  - '-I /usr/include/glib-2.0'
  - '-I /usr/lib/x86_64-linux-gnu/glib-2.0/include'
  - '-I /usr/include/harfbuzz'
  - '-I /usr/include/cairo'

silence-enum-warning: true
""".trim();

final sdlConfig = """
name: SDL
description: "SDL Dart Bindings"

output: './lib/backend/sdl/sdl-bindings.dart'

headers:
  entry-points:
    - '/usr/include/SDL2/SDL.h'
  include-directives:
    - '/usr/include/SDL2/SDL.h'
    - '/usr/include/SDL2/SDL_timer.h'
    - '/usr/include/SDL2/SDL_video.h'
    - '/usr/include/SDL2/SDL_render.h'
    - '/usr/include/SDL2/SDL_surface.h'
    - '/usr/include/SDL2/SDL_events.h'
    - '/usr/include/SDL2/SDL_mouse.h'

llvm-path:
  - '/usr/lib/llvm-18'

silence-enum-warning: true
""".trim();

void main(List<String> args) async {
    String config;
    switch (args[0]) {
        case "cairo":
            config = cairoConfig;
        case "pango":
            config = pangoConfig;
        case "sdl":
            config = sdlConfig;
        default:
            print("Unknown library");
            return;
    }
    var bindgenFile = File("bindgen-config.yaml");
    bindgenFile.writeAsStringSync(config);
    var res = await Process.run("dart", ["run", "ffigen", "--config", "bindgen-config.yaml"]);
    print(res.stdout);
    bindgenFile.deleteSync();
    print("Done Generating ${args[0]} Bindings");
}
