#include "SDL/SDL.h"
#include "SDL/SDL_image.h"
#include <string>

//The attributes of the screen
const int SCREEN_WIDTH = 640;
const int SCREEN_HEIGHT = 480;
const int SCREEN_BPP = 32;

//Movement interval
const int MOVE_INTERVAL = 2;

//The surface that will be used
SDL_Surface * man = NULL;
SDL_Surface * background= NULL;
SDL_Surface * screen = NULL;

//The event structure that will be used
SDL_Event event;

//Sub functions
SDL_Surface * load_image(std::string filename);
void apply_surface(int x, int y, SDL_Surface * source, SDL_Surface * destination);
bool moveto(int x, int y);

int main(int argc, char * argv[]) 
{
	bool quit = false;
	bool left_direction = false, right_direction = false, up_direction = false, down_direction = false;
	int x = 180, y = 149;

	//Init SDL
	if(SDL_Init(SDL_INIT_EVERYTHING) == -1)
	{
	    return 1;
	}

	//Set up the screen
	screen = SDL_SetVideoMode(SCREEN_WIDTH, SCREEN_HEIGHT, SCREEN_BPP, SDL_SWSURFACE);
	if(screen == NULL)
	{
	    return 1;
	}

	//Set the window caption
	SDL_WM_SetCaption("Walking", NULL);

	//Load the images
	man = load_image("man.png");
	background = load_image("background.png");
	if(man == NULL || background == NULL)
	{
	    return 1;
	}

	moveto(x, y);

	//While the user hasn't quit
	while(!quit)
	{
		//While there is an event to handle
		while(SDL_PollEvent(&event))
		{
			switch(event.type)
			{
				case SDL_QUIT:
					quit = true;
					break;
				case SDL_KEYDOWN:
					switch(event.key.keysym.sym)
					{
						case SDLK_UP:
							y -= MOVE_INTERVAL;
							moveto(x, y);
							up_direction = true;
							break;
						case SDLK_DOWN:
							y += MOVE_INTERVAL;
							moveto(x, y);
							down_direction = true;
							break;
						case SDLK_LEFT:
							x -= MOVE_INTERVAL;
							moveto(x, y);
							left_direction = true;
							break;
						case SDLK_RIGHT:
							x += MOVE_INTERVAL;
							moveto(x, y);
							right_direction = true;
							break;
						default:
							printf("Unhandled key press!\n");
							break;
					}
					break;
				case SDL_KEYUP:
					switch(event.key.keysym.sym)
					{
						case SDLK_UP:
							up_direction = false;
							break;
						case SDLK_DOWN:
							down_direction = false;
							break;
						case SDLK_LEFT:
							left_direction = false;
							break;
						case SDLK_RIGHT:
							right_direction = false;
							break;
						default:
							printf("Unhandled key relese!\n");
							break;
					}
					break;
				default:
					printf("Unhandled event!\n");
					break;
			}
		}
		if(up_direction)
		{
			y -= MOVE_INTERVAL;
			moveto(x, y);
		}
		else if(down_direction)
		{
			y += MOVE_INTERVAL;
			moveto(x, y);
		}
		else if(left_direction)
		{
			x -= MOVE_INTERVAL;
			moveto(x, y);
		}
		else if(right_direction)
		{
			x += MOVE_INTERVAL;
			moveto(x, y);
		}
	}
    
	//Free the surface
	SDL_FreeSurface(man);
	SDL_FreeSurface(background);

	//Quit SDL
	SDL_Quit();

	return 0;
}

SDL_Surface * load_image(std::string filename)
{
	SDL_Surface * loadimage = NULL;
	SDL_Surface * optimizeimage = NULL;

	//Load the image
	loadimage = IMG_Load(filename.c_str());

	if(loadimage != NULL)
	{
		//Create the optimize image
		optimizeimage = SDL_DisplayFormat(loadimage);

		//Release the old image
		SDL_FreeSurface(loadimage);
	}

	if(optimizeimage != NULL)
	{
		//Map the color key
		Uint32 colorkey = SDL_MapRGB(optimizeimage->format, 0, 0xFF, 0xFF);

		//Set all pixels of color RGB(0, 0xFF, 0xFF) to be transparent
		SDL_SetColorKey(optimizeimage, SDL_SRCCOLORKEY, colorkey);
	}

	return optimizeimage;
}

void apply_surface(int x, int y, SDL_Surface * source, SDL_Surface * destination)
{
	//Make the temporary rectangle to hold the offsets
	SDL_Rect offset;

	offset.x = x;
	offset.y = y;

	SDL_BlitSurface(source, NULL, destination, &offset);
}

bool moveto(int x, int y)
{
	//Apply the image to the screen
	apply_surface(0, 0, background, screen);
	apply_surface(x, y, man, screen);

	//Update the screen
	if(SDL_Flip(screen) == -1)
	{
	    return false;
	}

	return true;
}

