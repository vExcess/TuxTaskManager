# dcanvas
Cairo backed HTML Canvas implementation in Dart

**dcanvas is a port of [node-canvas](https://github.com/Automattic/node-canvas) from C++ to Dart**

## Why
I wanted to use HTML Canvas to create native apps, but all the existing HTML Canvas implementations are integrated with JS using NAPI and JS cannot compile to native code. Because of NAP I can't just rebind the C++ library to Dart. Even so binding the C++ library to Dart would be messy as I would have to create a C wrapper API around the C++ library and then create Dart bindings to the C wrapper. Instead I just ported all of the C++ code to Dart.

## Install Dependencies
`sudo apt-get install build-essential libsdl2-dev libcairo2-dev libpango1.0-dev`