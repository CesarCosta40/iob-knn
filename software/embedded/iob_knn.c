#include "interconnect.h"
#include "iob_knn.h"
#include "KNNsw_reg.h"
#include <iob-uart.h>

static int32_t base;

void knn_reset(){
  IO_SET(base, KNN_RESET, 1);
  IO_SET(base, KNN_RESET, 0);
}

void knn_init(int32_t base_address, int32_t n_solvers, int32_t n_series){
  base = base_address;
  knn_reset();
  for(int i = 0; i < n_solvers; i++){
    IO_SET(base, SOLVER_SEL, i);
    if(i%n_series!=0)
      IO_SET(base, SERIES_ENABLE, 0x3);
    else
      IO_SET(base, SERIES_ENABLE, 0x2);
  }
  IO_SET(base, SERIES_ENABLE, 0);
}

void knn_set_test_points(int16_t x[M][2], int32_t n_solvers, int32_t n_series){
  int* a;
  for(int i = 0; i < n_solvers; i++){
    a=(int*)x[i/n_series];
    IO_SET(base, SOLVER_SEL, i);
    IO_SET(base, DATA_1, *a);
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

void knn_get_neighbours(uint32_t v_neighbor[N_SOLVERS][K], int16_t data[N][2], int16_t x[M][2], uint32_t hw_k, int32_t n_solvers, int32_t n_series) {

  if(HW_K*N_SOLVERS<K){//Used only when even chaining all solvers toghether is not enough to solve a problem. Is very slow
    IO_SET(base, SOLVER_SEL, 0);
    for(int32_t m=0; m < 1; m++){ 

      char checked[N]; //Saves if point n of problem m is already a nearest neighbor
      int32_t i=0;
      for(int32_t n=0; n < N; n++){
        checked[n]=0;
      }

      for(int32_t j=0; j<K; j+=hw_k){//Repeat process ceil(K/hw_k) times
        knn_set_test_points(x, 1, 1);//Send test points

        for(int32_t n=0; n<N; n++){
          if(checked[n]==0){
            knn_send_dataset_point(data[n]);
          }else{
            knn_send_infinite(x[0]);
          }
        }
        IO_SET(base, DONE, 1);
        for(;i<K&&i<j+hw_k;i++){
          IO_SET(base, SEL, i%hw_k);
          v_neighbor[m][i]=IO_GET(base, DATA_OUT);
          checked[v_neighbor[m][i]]=1;
        }

        knn_reset();
      }
    }
  }else{
    knn_set_test_points(x, n_solvers, n_series);

    for(int j = 0; j < N; j++){
      knn_send_dataset_point(data[j]);
    }
    IO_SET(base, DONE, 1);

    for(int j = 0; j < n_solvers;  j++){
      IO_SET(base, SOLVER_SEL, j);
      for(int i = 0 ; i < hw_k && i+(j%n_series)*hw_k < K; i++){
        IO_SET(base, SEL, i);
        v_neighbor[j/n_series][i+(j%n_series)*hw_k]=IO_GET(base, DATA_OUT);
      }
    }

    knn_reset();
  }
}
