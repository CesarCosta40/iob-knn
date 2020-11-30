#pragma once
#include <stdint.h>

//uncomment to use rand from C lib
//#define cmwc_rand rand

#ifdef DEBUG //type make DEBUG=1 to print debug info
#define S 12  //random seed
#define N 8  //data set size
#define K 4   //number of neighbours (K)
#define C 4   //number data classes
#define M 2   //number samples to be classified
#else
#define S 1
#define N 60
#define K 10
#define C 4
#define M 20
#endif

#define INFINITE ~0

//Data structures
typedef struct datum{
  int16_t x;
  int16_t y;
  uint8_t label;
}datum;

typedef struct neighbor {
  uint32_t idx; //index in dataset array
  uint32_t dist; //distance to test point
} neighbor;

//Functions in main file
void init(void);
void get_teste_point_class(int32_t *, int32_t);
//Functions that comunicate with perifral
void knn_reset(void);
void knn_init(int32_t);
void knn_set_test_point(int16_t, int16_t);
void knn_send_dataset_point(int16_t, int16_t);
void knn_get_neighbours(neighbor *);
