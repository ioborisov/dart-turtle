// Copyright (c) 2014, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library turtle.example;

import 'package:turtle/turtle.dart';

void drawSpiral(Turtle myTurtle, int lineLen){
	if (lineLen > 0){
		myTurtle.forward(lineLen);
		myTurtle.left(90);
		drawSpiral(myTurtle, lineLen-5);
	}
}

void main() {
	Turtle t = new Turtle(300, 300);
	t.setBorder("1px solid green");
	t.right(90);
	drawSpiral(t, 100);
}