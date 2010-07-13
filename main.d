

import std.string;

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


void effect(SDL_Surface* jacket, char* filename, Moving mv)
{
	SDL_Surface* image;
	SDL_Surface* temp;
	SDL_Rect rect;

	image = IMG_Load(filename);
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


int main(char[][] args)
{
	SDL_Surface* jacket;

	if (SDL_Init(0) < 0) {
		return -1;
	}
	scope(exit) SDL_Quit();

	jacket = SDL_CreateRGBSurface(SDL_SWSURFACE, WIDTH, HEIGHT, 32, 0xFF000000, 0x00FF0000, 0x0000FF00, 0x000000FF);
	SDL_FillRect(jacket, null, SDL_MapRGB(jacket.format, 0xFF, 0xFF, 0xFF));

	effect(jacket, "before_arm.gif", new Cascade(WIDTH, HEIGHT));
	effect(jacket, "before_corpus.gif", new Wave(WIDTH, HEIGHT));

	SDL_SaveBMP(jacket, "output.bmp");

	SDL_FreeSurface(jacket);

	return 0;
}


