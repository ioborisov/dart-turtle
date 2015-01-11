// Copyright (c) 2014, Igor Borisov. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.
library turtle.base;
import "dart:html";
import "dart:math";

/**
 *
 * Get a handle for the canvases in the document.
 *
 * Source: http://www.berniepope.id.au/html/js-turtle/turtle.html
 * The image canvas acts as an off-screen buffer for the
 * images drawn by the turtle. The turtle itself is drawn
 * in the visible turtle canvas, which is composited with
 * the image canvas. This allows us to redraw the
 * turtle (triangle) without messing up the previously drawn graphics.
 *
 */
class Turtle {
	CanvasElement _imageCanvas;
	CanvasRenderingContext2D _imageContext;
	CanvasElement _turtleCanvas;
	CanvasRenderingContext2D _turtleContext;
	Map<String, int> _pos;
	/// position in turtle coordinates
	num _angle;
	/// angle in degrees in turtle space
	bool _penDown;
	/// is the turtle pen down (or up)?
	int _width;
	/// width of the line drawn by the turtle
	bool _visible;
	/// is the turtle visible?
	bool _redraw;
	/// do we redraw the image when the turtle moves?
	bool _wrap;
	/// do we wrap the turtle on the boundaries of the canvas?
	Map<String, int> _color;
	/// colour of the line drawn by the turtle
	String _turtleColor;

	Turtle(int width, int height, [String parentNode = "body"]) {
		_imageCanvas = new Element.canvas();
		_imageCanvas
				..width = width
				..height = height
				..style.display = "none";
		_turtleCanvas = new Element.canvas();
		_turtleCanvas
				..width = width
				..height = height;
		var parent = querySelector(parentNode);
		parent.append(_turtleCanvas);
		parent.append(_imageCanvas);
		_imageContext = _imageCanvas.getContext('2d');
		_turtleContext = _turtleCanvas.getContext('2d');
		reset();
	}

	void _initialise() {
		_pos = { "x": 0, "y": 0 };
		_angle = 0;
		_penDown = true;
		_width = 1;
		_visible = true;
		_redraw = true;
		_wrap = false;
		_turtleColor = "green";
		_color = { "r": 0, "g": 0, "b": 0, "a": 1 };
		/// set the image context and turtle context state to the default values
		_imageContext.lineWidth = _width;
		_imageContext.strokeStyle = "black";
		_imageContext.globalAlpha = 1;
		_imageContext.textAlign = "center";
		_imageContext.textBaseline = "middle";
		/// the turtle takes precedence when compositing
		_turtleContext.globalCompositeOperation = 'destination-over';
	}
	/**
	 * Draw the turtle and the current image if redraw is true.
	 * For complicated drawings it is much faster to turn redraw off.
	 */

	void _drawIf() {
		if (_redraw) _draw();
	}

	/**
	 * Use canvas centered coordinates facing upwards.
	 */
	void _centerCoords(CanvasRenderingContext2D context) {
		int width = context.canvas.width;
		int height = context.canvas.height;
		context.translate(width ~/ 2, height ~/ 2);
		context.transform(1, 0, 0, -1, 0, 0);
	}

	void setTurtleColor(String color) {
		_turtleColor = color;
	}

	/**
	 * Draw the turtle and the current image.
	 */
	void _draw() {
		_clearContext(_turtleContext);
		if (_visible) {
			num x = _pos["x"];
			num y = _pos["y"];
			int w = 10;
			int h = 15;
			_turtleContext.save();
			/// Use canvas centered coordinates facing upwards.
			_centerCoords(_turtleContext);
			/// Move the origin to the turtle center.
			_turtleContext.translate(x, y);
			/// Rotate about the center of the turtle.
			_turtleContext.rotate(-_angle);
			/// Move the turtle back to its position.
			_turtleContext.translate(-x, -y);
			/// draw the turtle icon (a green triangle).
			_turtleContext.beginPath();
			_turtleContext.moveTo(x - w / 2, y);
			_turtleContext.lineTo(x + w / 2, y);
			_turtleContext.lineTo(x, y + h);
			_turtleContext.closePath();
			_turtleContext.fillStyle = _turtleColor;
			_turtleContext.fill();
			_turtleContext.restore();
		}
		/// Make a composite of the turtle canvas and the image canvas.
		_turtleContext.drawImageScaledFromSource(
				_imageCanvas,
				0,
				0,
				_imageCanvas.width,
				_imageCanvas.height,
				0,
				0,
				_imageCanvas.width,
				_imageCanvas.height);
	}

	/**
	 * Clear the display, don't move the turtle.
	 */
	void _clear() {
		_clearContext(_imageContext);
		_drawIf();
	}

	void _clearContext(CanvasRenderingContext2D context) {
		context.save();
		context.setTransform(1, 0, 0, 1, 0, 0);
		context.clearRect(0, 0, context.canvas.width, context.canvas.height);
		context.restore();
	}

	/**
	 * Reset the whole system. Clear the display and move turtle back to
	 * origin, facing the Y axis.
	 */
	void reset() {
		_initialise();
		_clear();
		_draw();
	}

	/**
	 * Trace the forward motion of the turtle, allowing for possible
	 * wrap-around at the boundaries of the canvas.
	 */
	void forward(int distance) {
		_imageContext.save();
		_centerCoords(_imageContext);
		_imageContext.beginPath();
		/// Get the boundaries of the canvas.
		num maxX = _imageContext.canvas.width ~/ 2;
		num minX = -_imageContext.canvas.width ~/ 2;
		num maxY = _imageContext.canvas.height ~/ 2;
		num minY = -_imageContext.canvas.height ~/ 2;
		num x = _pos["x"];
		num y = _pos["y"];
		/// Trace out the forward steps.
		while (distance > 0) {
			/// Move the to current location of the turtle.
			_imageContext.moveTo(x, y);
			/// Calculate the new location of the turtle after doing the forward movement.
			num cosAngle = cos(_angle);
			num sinAngle = sin(_angle);
			num newX = x + sinAngle * distance;
			num newY = y + cosAngle * distance;

			/// Wrap on the X boundary.
			void xWrap(num cutBound, num otherBound) {
				num distanceToEdge = ((cutBound - x) / sinAngle).abs();
				num edgeY = cosAngle * distanceToEdge + y;
				_imageContext.lineTo(cutBound, edgeY);
				distance -= distanceToEdge;
				x = otherBound;
				y = edgeY;
			}
			/// Wrap on the Y boundary.
			void yWrap(num cutBound, num otherBound) {
				num distanceToEdge = ((cutBound - y) / cosAngle).abs();
				num edgeX = sinAngle * distanceToEdge + x;
				_imageContext.lineTo(edgeX, cutBound);
				distance -= distanceToEdge;
				x = edgeX;
				y = otherBound;
			}
			/// Don't wrap the turtle on any boundary.
			void noWrap() {
				_imageContext.lineTo(newX, newY);
				_pos["x"] = newX;
				_pos["y"] = newY;
				distance = 0;
			}
			/// If wrap is on, trace a part segment of the path and wrap on boundary if necessary.
			if (_wrap) {
				var point;
				if (_insideCanvas(
						newX,
						newY,
						minX,
						maxX,
						minY,
						maxY))
					noWrap();
				else if ((point = _intersect(
								x,
								y,
								newX,
								newY,
								maxX,
								maxY,
								maxX,
								minY)) !=
								null)
					xWrap(maxX, minX);
				else if ((point = _intersect(x, y, newX, newY, minX, maxY, minX, minY)) !=
												null)
					xWrap(minX, maxX);
				else if ((point = _intersect(x, y, newX, newY, minX, maxY, maxX, maxY)) !=
																null)
					yWrap(maxY, minY);
				else if ((point = _intersect(x, y, newX, newY, minX, minY, maxX, minY)) !=
																				null)
					yWrap(minY, maxY);
				else /// No wrapping to to, new turtle position is within the canvas.
					noWrap();
			} else /// Wrap is not on.
					noWrap();
		} // while end
		/// only draw if the pen is currently down.
		if (_penDown) _imageContext.stroke();
		_imageContext.restore();
		_drawIf();
	}
	/// Trace the backward motion of the turtle via forward
	void backward(int distance) {
		right(180);
		forward(distance);
		right(-180);
	}
	/// Trace the forward or backward motion of the turtle via forward or backword
	void move(int distance) {
		if(distance > 0){
			forward(distance);
    }else if(distance < 0){
			backward(distance.abs());
		}
	}
	bool _insideCanvas(num x, num y, num minX, num maxX, num minY, num maxY) {
		return x >= minX && x <= maxX && y >= minY && y <= maxY;
	}

	_intersect(num x1, num y1, num x2, num y2, num x3, num y3, num x4, num y4) {
		num d = ((y4 - y3) * (x2 - x1)) - ((x4 - x3) * (y2 - y1));
		num ua = (((x4 - x3) * (y1 - y3)) - ((y4 - y3) * (x1 - x3))) ~/ d;
		num ub = (((x2 - x1) * (y1 - y3)) - ((y2 - y1) * (x1 - x3))) ~/ d;

		/// lines are parallel
		if (d == 0)
			return null;
		else if (ua < 0.01 ||
						ua > 0.99 ||
						ub < 0 ||
						ub > 1)
			return null;
		else
			return {
							"x": x1 + ua * (x2 - x1),
							"y": y1 + ua * (y2 - y1)
						};
	}

	/// Turn edge wrapping on/off.
	void wrap(bool boolean) {
		_wrap = boolean;
	}

	/// Hide the turtle.
	void hideTurtle() {
		_visible = false;
		_drawIf();
	}

	/// Show the turtle
	void showTurtle() {
		_visible = true;
		_drawIf();
	}

	/// Turn on/off redrawing when the turtle moves.
	void redrawOnMove(bool boolean) {
		_redraw = boolean;
	}

	/// Lift up the pen (don't draw).
	void up() {
		_penDown = false;
	}

	/// Put the pen down (do draw).
	void down() {
		_penDown = true;
	}

	/// Turn right by an angle in degrees.
	void right([num angle=90]) {
		_angle += _degToRad(angle);
		_drawIf();
	}

	/// Turn left by an angle in degrees.
	void left([num angle=90]) {
		_angle -= _degToRad(angle);
		_drawIf();
	}
	/// Turn right or left by an angle in degrees via right or left.
	void turn(num angle){
		if(angle > 0){
			right(angle);
		}else if(angle < 0){
			left(angle.abs());
		}
	}
	/**
	 * Move the turtle to a particular coordinate (don't draw on the way there).
	 * We should wrap the turtle here
	 */
	void goto(num x, num y) {
		if (_wrap) {
			_pos["x"] = ((x + 150) % 300) - 150;
			_pos["y"] = ((y + 150) % 300) - 150;
		} else {
			_pos["x"] = x;
			_pos["y"] = y;
		}
		_drawIf();
	}

	/// Set the angle of the turtle in degrees.
	void _setAngle(num angle) {
		_angle = _degToRad(angle);
	}

	/// Convert degrees to radians.
	num _degToRad(num deg) {
		return deg / 180 * PI;
	}

	/// Convert radians to degrees.
	num _radToDeg(num deg) {
		return deg * 180 / PI;
	}

	/// Set the width of the line.
	void width(num w) {
		_width = w;
		_imageContext.lineWidth = w;
	}

	/**
	 * Write some text at the turtle position.
	 * Need to counteract the fact that we flip the Y axis on the image context
	 * to draw in turtle coordinates.
	 */
	void write(String msg) {
		_imageContext.save();
		_centerCoords(_imageContext);
		_imageContext.translate(_pos["x"], _pos["y"]);
		_imageContext.transform(1, 0, 0, -1, 0, 0);
		_imageContext.translate(-_pos["x"], -_pos["y"]);
		_imageContext.fillText(msg, _pos["x"], _pos["y"]);
		_imageContext.restore();
		_drawIf();
	}
	/// Set the colour of the line using RGB values in the range [0,255], and
	/// an alpha value in the range [0,1].
	void color([int r = 0, int g = 0, int b = 0, int a = 1]) {
		_imageContext.strokeStyle = "rgba(" +
				r.toString() +
				"," +
				g.toString() +
				"," +
				b.toString() +
				"," +
				a.toString() +
				")";
		_color["r"] = r;
		_color["g"] = g;
		_color["b"] = b;
		_color["a"] = a;
	}
	/// Set the font used in text written in the image context.
	void setFont(String font) {
		_imageContext.font = font;
	}
	/// Set the border of canvas.
	void setBorder(String border) {
		_turtleCanvas.style.border = border;
	}

	bool test(){
		return true;
	}
}