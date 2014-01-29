//
//  main.c
//  hevc_parser
//
//  Created by wassim Hamidouche on 1/28/14.
//  Copyright (c) 2014 wassim Hamidouche. All rights reserved.
//

#include <stdio.h>

#define START_CODE 0x000001 ///< start_code_prefix_one_3bytes
#define END_NOT_FOUND (-100)
#define MAX_BUFFER_SIZE 2000000
#define MAX_FILE_NAME_SIZE 1024
#define MAX_LAYERS            2


enum NALUnitType {
    NAL_TRAIL_N    = 0,
    NAL_TRAIL_R    = 1,
    NAL_TSA_N      = 2,
    NAL_TSA_R      = 3,
    NAL_STSA_N     = 4,
    NAL_STSA_R     = 5,
    NAL_RADL_N     = 6,
    NAL_RADL_R     = 7,
    NAL_RASL_N     = 8,
    NAL_RASL_R     = 9,
    NAL_BLA_W_LP   = 16,
    NAL_BLA_W_RADL = 17,
    NAL_BLA_N_LP   = 18,
    NAL_IDR_W_RADL = 19,
    NAL_IDR_N_LP   = 20,
    NAL_CRA_NUT    = 21,
    NAL_VPS        = 32,
    NAL_SPS        = 33,
    NAL_PPS        = 34,
    NAL_AUD        = 35,
    NAL_EOS_NUT    = 36,
    NAL_EOB_NUT    = 37,
    NAL_FD_NUT     = 38,
    NAL_SEI_PREFIX = 39,
    NAL_SEI_SUFFIX = 40,
};



typedef struct nal_info {
    int Tid;
    int Qid;
    enum NALUnitType type;
    int size;
    unsigned long long   state64;
    int frame_start_found;
} nal_info; 





/**
 * Find the end of the current frame in the bitstream.
 * @return the position of the first byte of the next frame, or END_NOT_FOUND
 */
static int hevc_find_frame_end(nal_info *s, const unsigned char  *buf,
                               unsigned long buf_size)
{
    int i;

    
    for (i = 0; i < buf_size; i++) {
        int nut, layer_id;
        
        s->state64 = (s->state64 << 8) | buf[i];
        
        if (((s->state64 >> 3 * 8) & 0xFFFFFF) != START_CODE)
            continue;
        
        s->type = nut      = (s->state64 >> 2 * 8 + 1) & 0x3F;
        s->Qid  = layer_id = ((((s->state64 >> 2 * 8) &0x01)<<5) + (((s->state64 >> 1 * 8)&0xF8)>>3)) & 0x3F;
        s->Tid = ((s->state64 >> 1 * 8)& 0x07) - 1;
       
        // Beginning of access unit
        if ((nut >= NAL_VPS && nut <= NAL_AUD) || nut == NAL_SEI_PREFIX ||
            (nut >= 41 && nut <= 44) || (nut >= 48 && nut <= 55)) {
            if (s->frame_start_found /*&& !layer_id*/) {
                s->frame_start_found = 0;
                return i - 5;
            }
        } else if (nut <= NAL_RASL_R ||
                   (nut >= NAL_BLA_W_LP && nut <= NAL_CRA_NUT)) {
            int first_slice_segment_in_pic_flag = buf[i] >> 7;
            if (first_slice_segment_in_pic_flag /*&& !layer_id*/) {
                if (!s->frame_start_found) {
                    s->frame_start_found = 1;
                } else { // First slice of next frame found
                    s->frame_start_found = 0;
                    return i - 5;
                }
            }
        }
    }
    return END_NOT_FOUND;
}


static int hevc_parser(FILE * in, FILE * out, unsigned char *buffer , unsigned long long  * layers_size, int print) {
    nal_info nal_unit;
    unsigned long buffer_size = 0, size;
    int nbframes = 0,  prevQ=0, index = 0;
    
    while(1) {
        nal_unit.size = hevc_find_frame_end(&nal_unit, buffer+index, buffer_size);
        if(nal_unit.size > 0) {
            buffer_size -= nal_unit.size;
            
            if( nbframes) {
                if(print)
                    fprintf(out, "%d \n", nal_unit.size);
                layers_size[prevQ] += nal_unit.size;
            }
            if(print)
                fprintf(out, "%d  %d  %d  ", nal_unit.Tid, nal_unit.Qid, nal_unit.type);
            prevQ = nal_unit.Qid;
            nbframes++;
            index +=nal_unit.size;
        } else {
            size = fread (buffer, 1, MAX_BUFFER_SIZE, in);
            index = 0; 
            if(size){
                layers_size[prevQ] += buffer_size;
                buffer_size = size;
            } else  {
                if(print)
                    fprintf(out, "%lu ", (buffer_size+1));
                layers_size[prevQ] += (buffer_size+1);
                break;
            }
        }
    }
    return 0; 
}

unsigned char buffer[MAX_BUFFER_SIZE];
int main(int argc, const char * argv[])
{
    // insert code here...
    FILE *in_f, *out_f;
    int i, print=0;
    char filename[MAX_FILE_NAME_SIZE];
    sprintf(filename, "%s", argv[1]);
    //printf("input file name : %s \n", filename);
    in_f = fopen(filename, "rb");
    unsigned long long Layers_Size[MAX_LAYERS], somme = 0;
    if( in_f == NULL ) {
        printf("ERROR: input file %s not found \n", filename);
        goto err;
    }
    if(argc > 2)
        print = 1;
    if(print) {
        sprintf(filename, "%s", argv[2]);
        //printf("output file name : %s %d \n", filename, argc);
        out_f = fopen(filename, "wb");
        if( out_f == NULL ) {
            printf("ERROR: output file %s could not be created \n", filename);
            goto err;
        }
    }
    
        hevc_parser(in_f, out_f, buffer, Layers_Size, print);
    if(print)
        fclose(out_f);
    fclose(in_f);
    printf("Layers size:  ");
    for(i=0; i < MAX_LAYERS; i++) {
        printf(" l%d = %llu ", i,  Layers_Size[i] );
        somme += Layers_Size[i]; 
    }
    printf(" total size");

    printf(" = %llu Bytes\n", somme);
err: 
    return 0;
}

