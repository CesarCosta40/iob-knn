#pragma once
#include <stdint.h>

//uncomment to use rand from C lib
//#define cmwc_rand rand

#ifdef DEBUG //type make DEBUG=1 to print debug info
#define S 12  //random seed
#define N 12  //data set size
#define K 12   //number of neighbours (K)
#define C 4   //number data classes
#define M 2   //number samples to be classified
#else
#define S 12
#define N 200
#define K 10
#define C 4
#define M 50
#endif

#define INFINITE ~0
#define MAX_SHORT 16384
#define MIN_SHORT -16384


//Functions in main file
void init(void);
void get_teste_point_class(int32_t *, int32_t);
//Functions that comunicate with perifral
void knn_reset(void);
void knn_init(int32_t);
void knn_set_test_point(int16_t* test_point);
void knn_send_dataset_point(int16_t*);
void knn_send_infinite(int16_t* x);
void knn_get_neighbours(uint32_t *, int16_t data[N][2], int16_t x[M][2], uint32_t p, uint32_t hw_k);
