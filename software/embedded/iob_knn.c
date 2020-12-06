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

void knn_set_test_point(int16_t x_test_point, int16_t y_test_point){
  IO_SET(base, DATA_X1, x_test_point);
  IO_SET(base, DATA_Y1, y_test_point);
  IO_SET(base, DONE, 0);
}

void knn_send_dataset_point(int16_t x_dataset_point, int16_t y_dataset_point){
  IO_SET(base, DATA_X2, x_dataset_point);
  IO_SET(base, DATA_Y2, y_dataset_point);
}

void knn_get_neighbours(uint32_t *v_neighbor, datum* data, datum* x, uint32_t p, uint32_t hw_k) {

  if(hw_k<K){ 
    char checked[N];
    int32_t i=0;
    for(int32_t n=0; n < N; n++)
      checked[n]=0;

    for(int32_t j=0; j<K; j+=hw_k){

      knn_set_test_point(x[p].x, x[p].y);

      for (int32_t n=0; n<N; n++) { //for all dataset points
        //compute distance to x[k]
        if(checked[n]==0)
          knn_send_dataset_point(data[n].x, data[n].y);
        else
          knn_send_dataset_point(x[p].x<0?32767:-32768, x[p].y<0?32767:-32768);
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
    knn_set_test_point(x[p].x, x[p].y);

    for(int j = 0; j < N; j++){
      knn_send_dataset_point(data[j].x, data[j].y);
    }

    IO_SET(base, DONE, 1);
    for(int i = 0; i < K; i++){
      IO_SET(base, SEL, i);
      v_neighbor[i]=IO_GET(base, DATA_OUT);
    }

    knn_reset();
  }
}


