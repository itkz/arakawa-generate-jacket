

import std.math;
import std.cstream;


class Moving
{
	int x;
	int y;
	int angle;
	double zoom;
	int width;
	int height;
	bool is_end;


	this(int width, int height)
	{
		this.x = 0;
		this.y = 0;
		this.angle = 0;
		this.zoom = 1.0;
		this.width = width;
		this.height = height;
		this.is_end = false;
	}


	void move()
	{
	}
}


class Cascade : Moving
{
	bool up = false;


	this(int width, int height)
	{
		super(width, height);
	}


	void move()
	{
		y += height / 10;
		if (y > height) {
			y = 0;
			x += width / 10;
			if (x > width) {
				is_end = true;
			}
		}
		angle += 7;
		if (up) {
			zoom += 0.05;
			if (zoom > 1.6) {
				up = false;
			}
		} else {
			zoom -= 0.05;
			if (zoom < 0.4) {
				up = true;
			}
		}
	}
}


class Wave : Moving
{
	bool up = false;


	this(int width, int height)
	{
		super(width, height);
	}


	void move()
	{
		x += 3;
		y = cast(int)(sin(x * PI / width * 3) * height / 2 + (height / 2));
		if (x > width) {
			is_end = true;
		}
		if (up) {
			zoom += 0.05;
			if (zoom > 1.6) {
				up = false;
			}
		} else {
			zoom -= 0.05;
			if (zoom < 0.4) {
				up = true;
			}
		}
		angle += 4;
	}
}




