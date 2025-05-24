/* Pango
 *
 * Copyright (C) 1999 Red Hat Software
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	 See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public
 * License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 */

import 'dart:ffi';
import 'dart:io';

import './pango-bindings.dart' as PangoBindings;
export './pango-bindings.dart';

class PangoLib {
    static late PangoBindings.Pango pango;
    static late DynamicLibrary dynamicLibrary;

    //? Automatically load the library if not done?
    static load([String? libFile]) {
        if (libFile == null) {
            libFile = 'libpangocairo-1.0.so'; // on linux
            if (Platform.isMacOS) {
                libFile = 'libpangocairo-1.0.dylib';
            } else if (Platform.isWindows) {
                libFile = 'libpangocairo-1.0.dll';
            }
        }

        dynamicLibrary = DynamicLibrary.open(libFile);
        pango = PangoBindings.Pango(dynamicLibrary);
    }

    /**
     * PANGO_RBEARING:
     * @rect: a `PangoRectangle`
     *
     * Extracts the *right bearing* from a `PangoRectangle`
     * representing glyph extents.
     *
     * The right bearing is the distance from the horizontal
     * origin to the farthest right point of the character.
     * This is positive except for characters drawn completely
     * to the left of the horizontal origin.
     */
    static double PANGO_ASCENT(rect) {
        return (-(rect).y);
    }
    static double PANGO_DESCENT(rect) {
        return ((rect).y + (rect).height);
    }
    static double PANGO_LBEARING(rect) {
        return ((rect).x);
    }
    static double PANGO_RBEARING(rect) {
        return ((rect).x + (rect).width);
    }
}
