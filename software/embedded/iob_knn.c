#include "interconnect.h"
#include "iob_knn.h"
#include "KNNsw_reg.h"
#include <iob-uart.h>

static int base;

void knn_reset(){
  IO_SET(base, KNN_RESET, 1);
  IO_SET(base, KNN_RESET, 0);
}

void knn_init(int base_address){
  base = base_address;
  knn_reset();
}

void knn_send_distance(unsigned int d){
  IO_SET(base, DATA_IN, d);
}

void knn_get_neighbors(neighbor* v_neighbor){
  IO_SET(base, DONE, 1);
  v_neighbor[0].idx=IO_GET(base, DATA0_OUT);
  v_neighbor[1].idx=IO_GET(base, DATA1_OUT);
  v_neighbor[2].idx=IO_GET(base, DATA2_OUT);
  v_neighbor[3].idx=IO_GET(base, DATA3_OUT);
}

/*void knn_set_point(short x1, short y1){
  IO_SET(base, DATA_X1, x1);
  IO_SET(base, DATA_Y1, y1);
}

unsigned int knn_get_distance(short x2, short y2){
  IO_SET(base, DATA_X2, x2);
  IO_SET(base, DATA_Y2, y2);
  return IO_GET(base, DATA_OUT);
}*/

/*void knn_calculate_distances(int n, datum* x, datum* data, unsigned int* d){
  int *b;
  IO_SET(base, DATA_1, (*(int*)x));
  for(int i = 0; i < n; i++){
    b=(unsigned int*)(data+(i*sizeof(datum)));
    for(int j = 0; j < 20; j++)
      uart_printf("%d\n", *(unsigned int*)(data+j));
    
    IO_SET(base, DATA_2, *b);
    d[i]=IO_GET(base, DATA_OUT);
  }
}*/
