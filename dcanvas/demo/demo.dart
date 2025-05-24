import 'dart:math';

import 'package:dcanvas/dcanvas.dart';
import 'package:dcanvas/backend/Window.dart' as Window;

typedef Event = Window.Event;
typedef EventType = Window.EventType;
typedef Key = Window.Key;

var running = true;
void myEventHandler(Event event) {
    if (event.type == EventType.Quit) {
        running = false;
    } else if (event.type == EventType.KeyDown) {
        event = event as Window.KeyboardEvent;
        if (event.keyCode == Key.Escape) {
            running = false;
        }
    }
}

void main() {
    Canvas canvas = Canvas(700, 300);
    Context2D ctx = canvas.getContext("2d");

    Window.initSDL(Window.SDL_INIT_EVERYTHING);
    var window = Window.SDLWindow(
        title: "Demo Window",
        width: canvas.width,
        height: canvas.height,
        flagsList: [Window.SDL_WindowFlags.SDL_WINDOW_SHOWN]
    );
    window.setCanvas(canvas);
    window.eventHandler = myEventHandler;

    // Set line width
    ctx.lineWidth = 10;

    // Wall
    ctx.strokeRect(75, 140, 150, 110);

    // Door
    ctx.fillRect(130, 190, 40, 60);

    // Roof
    ctx.beginPath();
    ctx.moveTo(50, 140);
    ctx.lineTo(150, 60);
    ctx.lineTo(250, 140);
    ctx.closePath();
    ctx.stroke();

    // Rounded rectangle with zero radius (specified as a number)
    ctx.strokeStyle = "red";
    ctx.beginPath();
    ctx.roundRect(10, 20, 150, 100, 0);
    ctx.stroke();

    // Rounded rectangle with 40px radius (single element list)
    ctx.strokeStyle = "blue";
    ctx.beginPath();
    ctx.roundRect(10, 20, 150, 100, [40]);
    ctx.stroke();

    // Rounded rectangle with 2 different radii
    ctx.strokeStyle = "orange";
    ctx.beginPath();
    ctx.roundRect(10, 150, 150, 100, [10, 40]);
    ctx.stroke();

    // Rounded rectangle with four different radii
    ctx.strokeStyle = "green";
    ctx.beginPath();
    ctx.roundRect(400, 20, 200, 100, [0, 30, 50, 60]);
    ctx.stroke();

    // Same rectangle drawn backwards
    ctx.strokeStyle = "magenta";
    ctx.beginPath();
    ctx.roundRect(400, 150, -200, 100, [0, 30, 50, 60]);
    ctx.stroke();

    // text
    ctx.fillStyle = rgb(255, 0, 0);
    ctx.font = "50px serif";
    ctx.fillText("Hello world", 50, 90);

    while (running) {
        // check for events
        window.pollInput();

        // render frame
        window.render();

        // wait for 16ms
        Window.wait(16);
    }

    window.free();
}