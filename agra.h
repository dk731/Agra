
// Pixel representative struct, each channel consits of 10 bits,
// op - field is used for storing alpha channel
typedef struct {
    unsigned int r  : 10;
    unsigned int g  : 10;
    unsigned int b  : 10;
    unsigned int op : 2;
} pixcolor_t;

// Struct for brush drawing modes
typedef enum {
    PIXEL_COPY = 0,
    PIXEL_AND  = 1,
    PIXEL_OR   = 2,
    PIXEL_XOR  = 3,
    PIXEL_ADD  = 4
} pixop_t;

typedef enum {
    OUT_CHAR = 0,
    OUT_RGB  = 1
} out_t;


// Buffer parametrs struct, used for storing for drawing
typedef struct {
    pixcolor_t * buffer_p;
    unsigned int width;
    unsigned int height;
    pixcolor_t cur_color;
    pixop_t cur_mode;
} buffer_t;

// Brush color setter
void setPixColor(pixcolor_t * color_op);

// Brush drawing mode setter
void setDrawMode(int drawMode);

// Draw pixels at specific position with specific color
int pixel(int x, int y, pixcolor_t * colorop);

// Draw line with brush color
void line(int x1, int y1, int x2, int y2);

// Draw filled trinagle with brush color
void triangleFill(int x1, int y1, int x2, int y2, int x3, int y3);

// Draw circle with brush color
void circle(int x1, int y1, int radius);

/////////////////////////////////////////////////////////////////////////////
//      framebuffer.h
/////////////////////////////////////////////////////////////////////////////


int InitBuffer(int width, int height, int o_mode);

buffer_t * getBuffer();

pixcolor_t * FrameBufferGetAddress();

int FrameBufferGetWidth();

int FrameBufferGetHeight();

int FrameShow();

void ClearScreen();

void FreeBuffer();
