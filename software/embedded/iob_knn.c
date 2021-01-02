#include "interconnect.h"
#include "iob_knn.h"
#include "KNNsw_reg.h"
#include <iob-uart.h>

static int32_t base;

void knn_reset(){
  IO_SET(base, DONE, 1);
  IO_SET(base, KNN_RESET, 1);
  IO_SET(base, KNN_RESET, 0);
}

void knn_init(int32_t base_address){
  base = base_address;
  knn_reset();
}

void knn_set_test_points(int16_t x[M][2], int32_t n_solvers, int32_t n_series){
  int* a;
  for(int i = 0; i < n_solvers; i++){
    a=(int*)x[i];
    IO_SET(base, SOLVER_SEL, i);
    IO_SET(base, DATA_1, *a);
    if(i%n_series!=0)
      IO_SET(base, SERIES_ENABLE, 1);
    else
      IO_SET(base, SERIES_ENABLE, 0);
  }
  IO_SET(base, DONE, 0);
}

void knn_send_dataset_point(int16_t* dataset_point){
  int* a;
  a=(int*)dataset_point;
  IO_SET(base, DATA_2, *a);
}

void knn_send_infinite(int16_t* x){
  int32_t point;
  point=(x[0]<0?32767:-32768)<<16;
  point|=x[1]<0?32767:-32768;

  IO_SET(base, DATA_2, point);
}

void knn_get_neighbours(uint32_t v_neighbor[N_SOLVERS][K], int16_t data[N][2], int16_t x[M][2], uint32_t hw_k, int32_t n_parallel, int32_t n_series) {
  int32_t select = 0;

  knn_set_test_points(x, n_parallel*n_series, n_series);

  for(int j = 0; j < N; j++){
    knn_send_dataset_point(data[j]);
  }
  IO_SET(base, DONE, 1);

  for(int j = 0; j < n_parallel*n_series; j++){
    IO_SET(base, SOLVER_SEL, j);
    for(int i = 0 ; i < hw_k; i++){
      IO_SET(base, SEL, i);
      v_neighbor[j/n_series][i+(j%n_series)*hw_k]=IO_GET(base, DATA_OUT);
    }
  }
}
