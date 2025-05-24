/*
  Simple DirectMedia Layer
  Copyright (C) 1997-2024 Sam Lantinga <slouken@libsdl.org>

  This software is provided 'as-is', without any express or implied
  warranty.  In no event will the authors be held liable for any damages
  arising from the use of this software.

  Permission is granted to anyone to use this software for any purpose,
  including commercial applications, and to alter it and redistribute it
  freely, subject to the following restrictions:

  1. The origin of this software must not be misrepresented; you must not
     claim that you wrote the original software. If you use this software
     in a product, an acknowledgment in the product documentation would be
     appreciated but is not required.
  2. Altered source versions must be plainly marked as such, and must not be
     misrepresented as being the original software.
  3. This notice may not be removed or altered from any source distribution.
*/

import 'dart:ffi';
import 'dart:io';

import './sdl-bindings.dart' as SDLBindings;
export './sdl-bindings.dart';

class SDLLib {
    static late SDLBindings.SDL sdl;
    static late DynamicLibrary dynamicLibrary;

    //? Automatically load the library if not done?
    static load([String? libFile]) {
        if (libFile == null) {
            libFile = 'libSDL2-2.0.so'; // on linux
            if (Platform.isMacOS) {
                libFile = 'libSDL2-2.0.dylib';
            } else if (Platform.isWindows) {
                libFile = 'libSDL2-2.0.dll';
            }
        }

        dynamicLibrary = DynamicLibrary.open(libFile);
        sdl = SDLBindings.SDL(dynamicLibrary);
    }
}
