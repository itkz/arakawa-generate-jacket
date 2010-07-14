

import std.string;
import std.stdio;
import std.random;
import std.stream;

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


void effect_all(SDL_Surface* jacket, char[][] image_filenames)
{
	char[][] use_filenames;
	int use_num;

	use_num = (rand() % image_filenames.length) + 1;

	use_filenames.length = use_num;
	for (int i = 0; i < use_num; ++i) {
		use_filenames[i] = image_filenames[rand() % length];
	}

	foreach (char[] filename; use_filenames) {
		Moving mv;
		switch (rand() % 3) {
		case 0:
			mv = new Cascade(WIDTH, HEIGHT);
			break;
		case 1:
			mv = new SinWave(WIDTH, HEIGHT);
			break;
		case 2:
		default:
			mv = new CosWave(WIDTH, HEIGHT);
			break;
		}
		effect(jacket, filename, mv);
	}
}


char[][] get_iamges_filename()
{
	char[][] filenames;
	File fp;
	int i;

	fp = new File("images.txt", FileMode.In);
	scope(exit) fp.close();

	i = 0;
	foreach (char[] line; fp) {
		filenames.length = filenames.length + 1;
		filenames[i] = line.dup;
		i++;
	}

	return filenames;
}


int main(char[][] args)
{
	SDL_Surface* jacket;
	uint seed;

	if (args.length < 3) {
		return -1;
	}

	if (SDL_Init(0) < 0) {
		return -2;
	}
	scope(exit) SDL_Quit();

	seed = 0;
	foreach (char c; args[1]) {
		seed += c;
	}
	rand_seed(seed, 0);

	jacket = SDL_CreateRGBSurface(
		SDL_SWSURFACE, WIDTH, HEIGHT,
		32, 0xFF000000, 0x00FF0000, 0x0000FF00, 0x000000FF);
	SDL_FillRect(jacket, null, SDL_MapRGB(jacket.format, 0xFF, 0xFF, 0xFF));

	effect_all(jacket, get_iamges_filename());

	SDL_SaveBMP(jacket, toStringz(args[2]));

	SDL_FreeSurface(jacket);

	return 0;
}





