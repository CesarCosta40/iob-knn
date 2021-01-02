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

void knn_set_test_points(int16_t x[M][2], int32_t idx, int32_t n_solvers, int32_t n_series){
  int* a;
  for(int i = idx; i < idx+n_solvers && i<M; i++){ 
    a=(int*)x[i];
    IO_SET(base, SOLVER_SEL, i-idx);
    IO_SET(base, DATA_1, *a);
    if(SOLVER_SEL%n_series!=0)
      IO_SET(base, SERIES_ENABLE, 1);
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

void knn_get_neighbours(uint32_t v_neighbor[N_SOLVERS][K], int16_t data[N][2], int16_t x[M][2], uint32_t p, uint32_t hw_k, int32_t n_solvers, int32_t n_series) {
  /*if(hw_k<K){
    IO_SET(base, SOLVER_SEL, 0);
    for(int32_t m=0; m < n_solvers && m+p<M; m++){//Use only 1 solver when hw_k<K. To use all solvers 
  //it would be necessary to send individual points to
  //individual solvers, so it would be as fast as using a
  //single solver

  char checked[N]; //Saves if point n of problem m is already a nearest neighbor
  int32_t i=0;
  for(int32_t n=0; n < N; n++){
  checked[n]=0;
  }

  for(int32_t j=0; j<K; j+=hw_k){//Repeat process ceil(K/hw_k) times
  knn_set_test_points(x, p+m, 1);//Send test points

  for(int32_t n=0; n<N; n++){
  if(checked[n]==0){
  knn_send_dataset_point(data[n]);
  }else{
  knn_send_infinite(x[p+m]);
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
  }*/

  //if(hw_k<K){
    int32_t select = 0;
    int32_t n_parallel_prob = n_solvers/n_series;
    knn_set_test_points(x, p, n_solvers, n_series);

    for(int j = 0; j < N; j++){
      knn_send_dataset_point(data[j]);
    }
    IO_SET(base, DONE, 1);

    for(int j = 0; j < n_parallel_prob && j+p < M; j++){
      IO_SET(base, SOLVER_SEL, j);
      for(int i = 0 ; i < hw_k; i++){
        IO_SET(base, SEL, i);
        v_neighbor[j/n_series][i+(j%n_series)*hw_k]=IO_GET(base, DATA_OUT);
      }
    }

  
  /*else{
    knn_set_test_points(x, p, n_solvers, 1);

    for(int j = 0; j < N; j++){
      knn_send_dataset_point(data[j]);
    }
    IO_SET(base, DONE, 1);

    for(int j = 0;j < n_solvers && j+p < M; j++){  
      IO_SET(base, SOLVER_SEL, j);
      for(int i = 0; i < K; i++){
        IO_SET(base, SEL, i);
        v_neighbor[j][i]=IO_GET(base, DATA_OUT);
      }
    }
    knn_reset();
  }*/
}


