#include "SDL/SDL.h"
#include "SDL/SDL_image.h"
#include <string>

//The attributes of the screen
const int SCREEN_WIDTH = 640;
const int SCREEN_HEIGHT = 480;
const int SCREEN_BPP = 32;

//The surface that will be used
SDL_Surface * image= NULL;
SDL_Surface * screen = NULL;

//The event structure that will be used
SDL_Event event;

//Sub functions
SDL_Surface * load_image(std::string filename);
void apply_surface(int x, int y, SDL_Surface * source, SDL_Surface * destination);

int main(int argc, char * argv[]) 
{
	bool quit = false;

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
	SDL_WM_SetCaption("Event test", NULL);

	//Load the images
	image = load_image("hello_world.png");
	if(image == NULL)
	{
	    return 1;
	}

	//Apply the message to the screen
	apply_surface(180, 140, image, screen);

	//Update the screen
	if(SDL_Flip(screen) == -1)
	{
	    return 1;
	}

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
				default:
					printf("Unhandled event!\n");
					break;
			}
		}
	}

    //Wait 2 seconds
    SDL_Delay(2000);
    
	//Free the surface
	SDL_FreeSurface(image);

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

