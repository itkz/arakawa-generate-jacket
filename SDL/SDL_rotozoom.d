
/*

SDL_rotozoom - rotozoomer

LGPL (c) A. Schiffler

*/

// convert to D by shinichiro.h

import SDL;
import SDL_video;
import SDL_types;

/* Set up for C function definitions, even when using C++ */
extern (C) {

/* ---- Defines */

	const int SMOOTHING_OFF = 0;
	const int SMOOTHING_ON = 1;

/* ---- Structures */

    struct tColorRGBA {
		Uint8 r;
		Uint8 g;
		Uint8 b;
		Uint8 a;
    }

    struct tColorY {
		Uint8 y;
    }


/* 
 
rotozoomSurface()

Rotates and zoomes a 32bit or 8bit 'src' surface to newly created 'dst' surface.
'angle' is the rotation in degrees. 'zoom' a scaling factor. If 'smooth' is 1
then the destination 32bit surface is anti-aliased. If the surface is not 8bit
or 32bit RGBA/ABGR it will be converted into a 32bit RGBA format on the fly.

*/

    SDL_Surface *rotozoomSurface(SDL_Surface * src, double angle, double zoom, int smooth);


/* Returns the size of the target surface for a rotozoomSurface() call */

    void rotozoomSurfaceSize(int width, int height, double angle, double zoom, int *dstwidth,
										  int *dstheight);

/* 
 
zoomSurface()

Zoomes a 32bit or 8bit 'src' surface to newly created 'dst' surface.
'zoomx' and 'zoomy' are scaling factors for width and height. If 'smooth' is 1
then the destination 32bit surface is anti-aliased. If the surface is not 8bit
or 32bit RGBA/ABGR it will be converted into a 32bit RGBA format on the fly.

*/

    SDL_Surface *zoomSurface(SDL_Surface * src, double zoomx, double zoomy, int smooth);

/* Returns the size of the target surface for a zoomSurface() call */

    void zoomSurfaceSize(int width, int height, double zoomx, double zoomy, int *dstwidth, int *dstheight);


/* Ends C function definitions when using C++ */
}

