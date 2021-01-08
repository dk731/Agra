#include "agra.h"

#include <stdlib.h> // rand()
#include <unistd.h> // usleep()

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void sierpinskiTriangle(int x1, int y1, int x2, int y2, int x3, int y3, int deph) // Draw sierpinski triangle fractal
{
	if (deph == 0)
		return;

	line(x1, y1, x2, y2);
	line(x2, y2, x3, y3);
	line(x3, y3, x1, y1);

	

	int c1x = (x1 + x2) / 2;
	int c1y = (y1 + y2) / 2;
	
	int c2x = (x2 + x3) / 2;
	int c2y = (y2 + y3) / 2;

	int c3x = (x3 + x1) / 2;
	int c3y = (y3 + y1) / 2;

	int new_deph = deph - 1;
	sierpinskiTriangle(x1, y1, c1x, c1y, c3x, c3y, new_deph);
	sierpinskiTriangle(c1x, c1y, x2, y2, c2x, c2y, new_deph);
	sierpinskiTriangle(c3x, c3y, c2x, c2y, x3, y3, new_deph);

}

void extraTest() // Preview function for all graphic library features
{
	int err = InitBuffer(120, 40, OUT_RGB);
	if (err)
		return;

	ClearScreen();


	setPixColor( &((pixcolor_t){1023, 682, 1023, 3}));
	triangleFill(getBuffer()->width / 2, 0, getBuffer()->width - 1, getBuffer()->height - 1, 0, getBuffer()->height - 1);
	FrameShow();
	usleep(500000);

	setPixColor(&((pixcolor_t){1023, 682, 0, 3}));
	setDrawMode(PIXEL_AND);
	line(getBuffer()->width / 2, 0, getBuffer()->width / 2, getBuffer()->height - 1);
	setPixColor(&((pixcolor_t){0, 682, 511, 3}));
	line(0, getBuffer()->height / 2, getBuffer()->width-1, getBuffer()->height / 2);
	FrameShow();
	usleep(500000);

	setPixColor(&((pixcolor_t){1023, 1023, 1023, 2}));
	circle(getBuffer()->width / 2, getBuffer()->height / 2, 10);
	FrameShow();
	usleep(500000);
	setDrawMode(PIXEL_OR);
	setPixColor( &((pixcolor_t){1023, 341, 0, 3}));
	line(0, 0, getBuffer()->width - 1, getBuffer()->height - 1);
	FrameShow();
	usleep(500000);

	setDrawMode(PIXEL_XOR);
	setPixColor( &((pixcolor_t){300, 341, 1023, 3}));
	line(0, getBuffer()->height - 1, getBuffer()->width - 1, 0);
	FrameShow();
	usleep(500000);

	line(0, getBuffer()->height - 1, getBuffer()->width - 1, 0);
	FrameShow();

	setDrawMode(PIXEL_ADD);
	setPixColor( &((pixcolor_t){rand() % 1023, rand() % 1023, rand() % 1023, 2}));
	sierpinskiTriangle(0, 0, getBuffer()->width - 1, 0, getBuffer()->width / 2, getBuffer()->height - 1, 3);
	FrameShow();
	for (int i = 0; i < 31; i++)
	{
		setPixColor( &((pixcolor_t){rand() % 1023, rand() % 1023, rand() % 1023, 3}));
		setDrawMode(i % 4);
		circle(getBuffer()->width / 2, getBuffer()->height / 2, i * 2);
		FrameShow();
		usleep(500000);
	}
}
// Functions for peview full functionality of graphic library
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

void defaultTest()
{
	int err = InitBuffer(40, 20, OUT_CHAR);
	if (err)
		return;

	ClearScreen();


	pixel(25, 2, &((pixcolor_t){0x3ff, 0x3ff, 0x3ff, 0x3}));

	setPixColor(&((pixcolor_t){0, 0, 0x3ff, 0x3}));
	line(0, 0, 39, 19);

	setPixColor(&((pixcolor_t){0, 0x3ff, 0, 0x3}));
	triangleFill(20, 13, 28, 19, 38, 6);

	setPixColor(&((pixcolor_t){0x3ff, 0, 0, 0x3}));
	circle(20, 10, 7);

	FrameShow();

	FreeBuffer();
}


int main(int argc, char *argv[])
{

	defaultTest();
	//extraTest();

	return 0;
}
