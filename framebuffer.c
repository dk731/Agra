#include <string.h> // memset 
#include "agra.h"

// Variable to store buffer parametrs
buffer_t buffer;

// Additional bufer for storing output image, 
// used to print everything in one piece
// makes frames apear fast even via ssh
char *print_buf; 

int print_buf_size = 0;

out_t output_mode;


// Main buffer initializer
// o_mode represents output mode (default char or escape char rgb mode)
int InitBuffer(int width, int height, int o_mode)
{
    output_mode = o_mode;
    buffer.buffer_p = malloc(sizeof(pixcolor_t) * width * height);

    if (buffer.buffer_p == NULL)
        return 1;

    memset(buffer.buffer_p, 0, sizeof(pixcolor_t) * width * height);

    buffer.cur_mode = PIXEL_COPY;

    buffer.cur_color = (pixcolor_t){0, 0, 0, 0};

    buffer.width = width;
    buffer.height = height;
    print_buf_size = width * height * 48 + 13 + 1;
    print_buf = malloc(print_buf_size);

    return 0;
}

buffer_t * getBuffer()
{
    return &buffer;
}


pixcolor_t * FrameBufferGetAddress()
{
    return buffer.buffer_p;
}

int FrameBufferGetWidth()
{
    return buffer.width;
}

int FrameBufferGetHeight()
{
    return buffer.height;
}

int FrameShow()
{
    memset(print_buf, 0, print_buf_size);

    int j;
    j = sprintf(print_buf, "\033[2J\033[H");

    if (output_mode == OUT_CHAR)
    {
        for (int y = 0; y < buffer.height; y++)
        {
            for (int x = 0; x < buffer.width; x++)
            {
                pixcolor_t cur_pixel = buffer.buffer_p[x + y * buffer.width];
                cur_pixel.r = (cur_pixel.r >> ((3 - cur_pixel.op) << 1));
                cur_pixel.g = (cur_pixel.g >> ((3 - cur_pixel.op) << 1));
                cur_pixel.b = (cur_pixel.b >> ((3 - cur_pixel.op) << 1));

                char out_put_char;

                if ( cur_pixel.r < 512)
                    if (cur_pixel.g < 512)
                        if (cur_pixel.b < 512)
                            out_put_char = ' ';
                        else
                            out_put_char = 'B';
                    else
                        if (cur_pixel.b < 512)
                            out_put_char = 'G';
                        else
                            out_put_char = 'C';
                else
                    if (cur_pixel.g < 512)
                        if (cur_pixel.b < 512)
                            out_put_char = 'R';
                        else
                            out_put_char = 'M';
                    else
                        if (cur_pixel.b < 512)
                            out_put_char = 'Y';
                        else
                            out_put_char = '*';
                j += sprintf(print_buf + j, "%c", out_put_char);
            }

            j += sprintf(print_buf + j, "\n");
        }
    } 
    else if (output_mode == OUT_RGB)
    {
        for (int y = 0; y < buffer.height; y++)
        {
            for (int x = 0; x < buffer.width; x++)
            {
                pixcolor_t cur_pixel = buffer.buffer_p[x + y * buffer.width];
                cur_pixel.r = (cur_pixel.r >> ((3 - cur_pixel.op) << 1)) >> 2;
                cur_pixel.g = (cur_pixel.g >> ((3 - cur_pixel.op) << 1)) >> 2;
                cur_pixel.b = (cur_pixel.b >> ((3 - cur_pixel.op) << 1)) >> 2;

                j += sprintf(print_buf + j, "\033[38;2;%d;%d;%d;48;2;%d;%d;%dm.\x1b[0m", cur_pixel.r, cur_pixel.g, cur_pixel.b, cur_pixel.r, cur_pixel.g, cur_pixel.b);
            }
            j += sprintf(print_buf + j, "\n");
        }
    }
    printf("%s", print_buf);
    return 0;
}

// Fills entire buffer with zero's
void ClearScreen()
{
    memset(buffer.buffer_p, 0, sizeof(pixcolor_t) * buffer.width * buffer.height);
}

// Because all buffer are allocated dynamicly
// we need to realease them in the end 
void FreeBuffer()
{
    free(buffer.buffer_p);
    free(print_buf);
}

void setPixColor( pixcolor_t * color_op)
{
    buffer.cur_color = *color_op;
}

void setDrawMode(int drawMode)
{
    buffer.cur_mode = drawMode;
}
