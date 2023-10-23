#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>

#define BUFSIZE 1048576

#pragma pack(1)

struct bmpheader {
        struct {
                uint16_t signature;
                uint32_t size;
                uint32_t reserved;
                uint32_t offset;
        } header;
        struct {
                uint32_t size;
                uint32_t width;
                uint32_t height;
                uint16_t planes;
                uint16_t bpp;
                uint32_t compression;
                uint32_t imgsize;
                uint32_t xpixpermeter;
                uint32_t ypixpermeter;
                uint32_t colorcount;
                uint32_t importantco;
        } infoheader;
        struct {
                uint8_t red;
                uint8_t green;
                uint8_t blue;
                uint8_t reserved;
        } colortable[16];
};

struct tilerow {
        struct {
                uint8_t p0;
                uint8_t p1;
        } tile[16][8];
};

int main(int argc, char **argv)
{
        if (argc < 2) {
                printf("Usage: %s INFILE.gbm OUTFILE.bmp\n", argv[0]);
                return 1;
        }
        //get pixel data
        //No header; that's the primary problem
        FILE *infile = fopen(argv[1], "rb");
        size_t readin = 0;
        struct tilerow *indata = NULL;
        while (!feof(infile)) {
                indata = realloc(indata, readin + BUFSIZE);
                readin += fread(indata + readin, 1, BUFSIZE, infile);
        }
        fclose(infile);
        //Fill in a header
        struct bmpheader header         = {0};
        header.header.signature         = 0x4D42;       //Constant
        header.header.offset            = 14+40+4*16;   //Known due to no. of colors
        header.infoheader.size          = 40;           //Constant
        header.infoheader.width         = 128;          //Basically constant
        header.infoheader.planes        = 1;            //Forced
        header.infoheader.bpp           = 4;            //The best we can do
        header.infoheader.compression   = 0;            //Let's not
        header.infoheader.imgsize       = 0;            //Ignored
        header.infoheader.xpixpermeter  = 0;            //Dunno
        header.infoheader.ypixpermeter  = 0;            //Dunno
        header.infoheader.colorcount    = 16;           //Don't know what it's for
        header.infoheader.importantco   = 4;            //Nature of 8 bit
        header.colortable[1].red        = 0x3F;
        header.colortable[1].green      = 0x3F;
        header.colortable[1].blue       = 0x3F;
        header.colortable[2].red        = 0x7F;
        header.colortable[2].green      = 0x7F;
        header.colortable[2].blue       = 0x7F;
        header.colortable[3].red        = 0xFF;
        header.colortable[3].green      = 0xFF;
        header.colortable[3].blue       = 0xFF;
        //Figure out the size of our data array
        int rowcount = readin / 256;
        //Compute the rest
        header.infoheader.height        = rowcount * 8;
        header.header.size              = header.header.offset + header.infoheader.width / 2 * header.infoheader.height;
        //Submit the output file
        FILE *outfile = fopen(argv[2], "wb");
        fwrite(&header, 1, sizeof(header), outfile);
        //for (int i = 0; i < sizeof(header); i++) {
        //        fputc(((uint8_t*)&header)[i], outfile);
        //}
        //.bmp stores data bottom-up
        for (int row = rowcount-1; row>=0; row--) {
                for (int line = 7; line>=0; line--) {
                for (int column = 0; column<=15; column++) {
                        for (int pixel = 7; pixel>=0; pixel--) {
                                uint8_t pair = 0;
                                pair += indata[row].tile[column][line].p0 & (1<<(pixel)) ? 0x10 : 0;
                                pair += indata[row].tile[column][line].p1 & (1<<(pixel--)) ? 0x20 : 0;
                                pair += indata[row].tile[column][line].p0 & (1<<(pixel)) ? 0x01 : 0;
                                pair += indata[row].tile[column][line].p1 & (1<<(pixel)) ? 0x02 : 0;
                                fputc(pair, outfile);
                        }
                }
                }
        }
}
