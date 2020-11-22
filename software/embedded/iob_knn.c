#include "interconnect.h"
#include "iob_knn.h"
#include "KNNsw_reg.h"

static int base;

void knn_reset(){
  IO_SET(base, KNN_RESET, 1);
  IO_SET(base, KNN_RESET, 0);
}

void knn_init(int base_address){
  base = base_address;
  knn_reset();
}

void knn_set_point(short x1, short y1){
  IO_SET(base, DATA_X1, x1);
  IO_SET(base, DATA_Y1, y1);
}

int knn_get_distance(short x2, short y2){
  IO_SET(base, DATA_X2, x2);
  IO_SET(base, DATA_Y2, y2);
  return IO_GET(base, DATA_OUT);
}
