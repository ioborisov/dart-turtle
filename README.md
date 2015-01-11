# turtle

Simple Turtle graphics.
Ported from http://www.berniepope.id.au/html/js-turtle/turtle.html

## Usage

A simple usage example:

    import 'package:turtle/turtle.dart';

    main() {
      Turtle turtle = new Turtle(300, 300);
      turtle.right(90);
      turtle.forward(100);
    }

## Features and bugs

### Constructor. Сreates a canvas specified dimensions as the last child of the parentNode

Turtle(int width, int height, [String parentNode = "body"])

### Specifies the color turtle. ("green" by default)

void setTurtleColor(String color)

### Reset the whole system. Clear the display and move turtle back to origin, facing the Y axis.

void reset()

### Trace the forward motion of the turtle, allowing for possible wrap-around at the boundaries of the canvas.

void forward(int distance)

### Trace the backward motion of the turtle via forward

void backward(int distance)

### Trace the motion of the turtle via forward or backword

void move(int distance)
	
### Turn edge wrapping on/off. (false by default)

void wrap(bool boolean)

### Hide the turtle.

void hideTurtle()

### Show the turtle. By default.

void showTurtle()

### Turn on/off redrawing when the turtle moves (false by default)

void redrawOnMove(bool boolean)

### Lift up the pen (don't draw).

void up()

### Put the pen down (do draw). By default

void down()

### Turn right by an angle in degrees.

void right([num angle=90])

### Turn left by an angle in degrees.

void left([num angle=90])

### Turn turtle by an angle in degrees via right or left.

void turn(num angle)
	
### Move the turtle to a particular coordinate (don't draw on the way there).

void goto(num x, num y)

### Set the width of the line. (1 by default)

void width(num w)

### Write some text at the turtle position.

void write(String msg)

### Set the colour of the line using RGB values in the range [0,255], and an alpha value in the range [0,1].

void color([int r = 0, int g = 0, int b = 0, int a = 1])

### Set the font used in text written in the image context.

void setFont(String font) {

### Set the border of canvas. ("none" by default)

void setBorder(String border) {

Please file feature requests and bugs at the mail@igor-borisov.ru.
