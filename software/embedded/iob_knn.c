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

void knn_set_test_point(int16_t* test_point){
  int* a;
  a=(int*)test_point;
  IO_SET(base, DATA_1, *a);
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

void knn_get_neighbours(uint32_t *v_neighbor, int16_t data[N][2], int16_t x[M][2], uint32_t p, uint32_t hw_k) {

  if(hw_k<K){ 
    char checked[N];
    int32_t i=0;
    for(int32_t n=0; n < N; n++)
      checked[n]=0;

    for(int32_t j=0; j<K; j+=hw_k){

      knn_set_test_point(x[p]);

      for (int32_t n=0; n<N; n++) { //for all dataset points
        //compute distance to x[k]
        if(checked[n]==0)
          knn_send_dataset_point(data[n]);
        else{
          knn_send_infinite(x[p]);
        }
      }
      IO_SET(base, DONE, 1);
      for(; i<K&&i<j+hw_k; i++){
        IO_SET(base, SEL, i%hw_k);
        v_neighbor[i]=IO_GET(base, DATA_OUT);
        checked[v_neighbor[i]]=1;
      }

      knn_reset();

    }
  }
  else{
    knn_set_test_point(x[p]);

    for(int j = 0; j < N; j++){
      knn_send_dataset_point(data[j]);
    }

    IO_SET(base, DONE, 1);
    for(int i = 0; i < K; i++){
      IO_SET(base, SEL, i);
      v_neighbor[i]=IO_GET(base, DATA_OUT);
    }

    knn_reset();
  }
}


