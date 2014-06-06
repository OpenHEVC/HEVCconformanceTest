#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>

char *input_file;
char *output_file;
int width;
int height;
int crop_up;
int crop_down;

static void print_usage() {
    fprintf (stderr, "usage: yuvcrop -i input_file -o output_file -w width -h height -u crop_up -d crop_down\n");
    exit(-1);
}

static void print_cmd() {
    fprintf (stderr, "yuvcrop -i %s -o %s -w %d -h %d -u %d -d %d\n", 
	     input_file, output_file, width, height, crop_up, crop_down);
}

static void getArgs (int argc, char *argv[]) {
    const static char *legal_flags = "i:o:w:h:u:d:";
    int c;
	
    // default value
    input_file  = NULL;
    output_file = NULL;
    width       = 0;
    height      = 0;
    crop_up     = 0;
    crop_down   = 0;

    if (argc != 13)
	print_usage();
    while ((c = getopt (argc, argv, legal_flags)) != -1) {
	switch (c) {
	case 'i': input_file  = strdup(optarg); break;
	case 'o': output_file = strdup(optarg); break;
	case 'w': width       = atoi(optarg)  ; break;
	case 'h': height      = atoi(optarg)  ; break;
	case 'u': crop_up     = atoi(optarg)  ; break;
	case 'd': crop_down   = atoi(optarg)  ; break;
	default : print_usage (); break;
	}
    }
    if (input_file == NULL) {
        printf("No input file specified.\nSpecify it with: -i <filename>\n");
	print_usage ();
    }
    if (output_file == NULL) {
        printf("No output file specified.\nSpecify it with: -o <filename>\n");
	print_usage ();
    }
    if (width == 0 || height == 0) {
        printf("size is not valid\nSpecify it with: -w <width> -h <height>\n");
	print_usage ();
    }
    if (crop_up+crop_down == 0) {
        printf("crop is not valid\nSpecify it with: -u <crop_up> -d <crop_down>\n");
	print_usage ();
    }
}

static void cropYUV() {
    FILE *fin             = NULL;
    FILE *fout            = NULL;
    int cptFrame          = 0;
    int frame_height      = height - (crop_up + crop_down);
    int frame_size        = width * frame_height;
    int crop_up_size      = width * crop_up;
    int crop_down_size    = width * crop_down;
    unsigned char *buffer = malloc(frame_size * sizeof(unsigned char));
    fin = fopen(input_file,"rb");
    if (!fin) {
	printf("Unable to open input file! : %s\n", input_file);
	print_usage ();
    }
    fout = fopen(output_file,"wb");
    if (!fout) {
	printf("Unable to open output file! : %s\n", output_file);
	print_usage ();
    }
    while ( feof(fin) == 0 ) {
	printf("crop Frame %d\r", cptFrame);
	fread( buffer, sizeof(unsigned char), crop_up_size, fin);
	fread( buffer, sizeof(unsigned char), frame_size, fin);
	fwrite(buffer, sizeof(unsigned char), frame_size, fout);
	fread( buffer, sizeof(unsigned char), crop_down_size, fin);

	fread( buffer, sizeof(unsigned char), crop_up_size>>2, fin);
	fread( buffer, sizeof(unsigned char), frame_size>>2, fin);
	fwrite(buffer, sizeof(unsigned char), frame_size>>2, fout);
	fread( buffer, sizeof(unsigned char), crop_down_size>>2, fin);

	fread( buffer, sizeof(unsigned char), crop_up_size>>2, fin);
	fread( buffer, sizeof(unsigned char), frame_size>>2, fin);
	fwrite(buffer, sizeof(unsigned char), frame_size>>2, fout);
	fread( buffer, sizeof(unsigned char), crop_down_size>>2, fin);
	cptFrame++;
    }
    printf("\n");
}

int main (int argc, char *argv[]) {
    getArgs (argc, argv);
    print_cmd();
    cropYUV();
    return 0;
}
