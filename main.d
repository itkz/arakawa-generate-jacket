

import std.string;
import std.stdio;
import std.random;

import SDL;
import SDL_video;
import SDL_types;
import SDL_error;
import SDL_image;
import SDL_rotozoom;

import moving;


version (Darwin) {
	extern (C) int _d_run_Dmain(int argc, char* argv[]);
	extern (C) int SDL_main(int argc, char* argv[]) {
		return _d_run_Dmain(argc, argv);
	}
} else {
	extern (C) int _d_run_Dmain(int argc, char* argv[]);
	extern (C) int SDL_main(int argc, char* argv[]) {
		return _d_run_Dmain(argc, argv);
	}
}


const int WIDTH = 500;
const int HEIGHT = 500;


void effect(SDL_Surface* jacket, char[] filename, Moving mv)
{
	SDL_Surface* image;
	SDL_Surface* temp;
	SDL_Rect rect;

	image = IMG_Load(toStringz(filename));
	while (!mv.is_end) {
		mv.move();
		temp = rotozoomSurface(image, mv.angle, mv.zoom, 1);
		rect.x = cast(short)mv.x;
		rect.y = cast(short)mv.y;
		SDL_BlitSurface(temp, null, jacket, &rect);;
		SDL_FreeSurface(temp);
	}
	SDL_FreeSurface(image);
}


void effect_all(SDL_Surface* jacket, char[][] filenames)
{
	foreach (char[] filename; filenames) {
		Moving mv;
		switch (rand() % 2) {
		case 0:
			mv = new Cascade(WIDTH, HEIGHT);
			break;
		case 1:
		default:
			mv = new Wave(WIDTH, HEIGHT);
			break;
		}
		effect(jacket, filename, mv);
	}
}


int main(char[][] args)
{
	SDL_Surface* jacket;
	uint seed;

	if (args.length < 4) {
		return -1;
	}

	if (SDL_Init(0) < 0) {
		return -2;
	}
	scope(exit) SDL_Quit();

	writefln(args[1]);
	seed = 0;
	foreach (char c; args[1]) {
		seed += c;
	}
	rand_seed(seed, 0);

	jacket = SDL_CreateRGBSurface(
		SDL_SWSURFACE, WIDTH, HEIGHT,
		32, 0xFF000000, 0x00FF0000, 0x0000FF00, 0x000000FF);
	SDL_FillRect(jacket, null, SDL_MapRGB(jacket.format, 0xFF, 0xFF, 0xFF));

	effect_all(jacket, args[3 .. $]);

	SDL_SaveBMP(jacket, toStringz(args[2]));

	SDL_FreeSurface(jacket);

	return 0;
}





