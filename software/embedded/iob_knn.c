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

/*void knn_set_point(short x1, short y1){
  IO_SET(base, DATA_X1, x1);
  IO_SET(base, DATA_Y1, y1);
}

unsigned int knn_get_distance(short x2, short y2){
  IO_SET(base, DATA_X2, x2);
  IO_SET(base, DATA_Y2, y2);
  return IO_GET(base, DATA_OUT);
}*/

void knn_calculate_distances(int n, datum* x, datum* data, unsigned int* d){
  /*datum *b;
  unsigned short *c;
  short* e;
  unsigned int* a;*/

  short* a;
  int* b;
  //IO_SET(base, DATA_1, (*(int*)(x->p)));
  for(int i = 0; i < n; i++){
    
    a=&(data[i].p);
    b=(int*)a;

    uart_printf("%X %X --- %d %d - %d - %d\n", a, b, a[0], a[1], *a, *b);
    
    /*b=(datum *)&(data[i]);
    c=(unsigned short*)(data+(i*1));
    e=((short*)(&(data[i])))+1;
    a=(unsigned int*)c;*/

    //uart_printf("%d %d %d --- %d %d %d --- %d %d ---------- %X %X %X --- %X %X %X --- %X %X --- %X\n", b->x, b->y, b->label, data[i].x, data[i].y, data[i].label, *c, *e, &b->x, &b->y, &b->label, &(data[i].x), &(data[i].y), &(data[i].label), c, e, a);
    /*uart_printf("%d ", b->x);
    uart_printf("%d ", b->y); 
    uart_printf("%d --- ", b->label);
    uart_printf("%d ", data[i].x);
    uart_printf("%d ", data[i].y);
    uart_printf("%d --- ", data[i].label); 
    uart_printf("%d ", *c);
    uart_printf("%d  --------", *e);
    uart_printf("%X ", &b->x);
    uart_printf("%X ", &b->y); 
    uart_printf("%X --- ", &b->label); 
    uart_printf("%X ", &data[i].x);
    uart_printf("%X ", &data[i].y); 
    uart_printf("%X --- ", &data[i].label); 
    uart_printf("%X ", c); 
    uart_printf("%X ---", e);
    uart_printf("%X ", a);
    uart_printf("%X\n", *a);*/
     //uart_printf("%X %X %X --- %X %X %X --- %X %X ---------- %X %X %X --- %X %X %X --- %X %X --- %X %X\n", b->x, b->y, b->label, data[i].x, data[i].y, data[i].label, *c, *e, &b->x, &b->y, &b->label, &(data[i].x), &(data[i].y), &(data[i].label), c, e, a, *a);
    
    //IO_SET(base, DATA_2, *((int*)(data[i].p)));
    //d[i]=IO_GET(base, DATA_OUT);
  }
}
