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

void knn_get_neighbours(neighbor *v_neighbor) {
  IO_SET(base, DONE, 1);
  for(uint32_t i = 0; i<K; i++){
    IO_SET(base, SEL, i);
    v_neighbor[i].idx=IO_GET(base, DATA_OUT);
  }
  knn_reset();
}
