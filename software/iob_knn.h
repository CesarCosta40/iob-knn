#pragma once

//Structures

typedef struct datum{
  short p[2];
  unsigned char label;
}datum;


//Functions
void knn_reset();
//void knn_set_point(short x1, short y1);
void knn_init( int base_address);	
//unsigned int knn_get_distance(short x2, short y2);
void knn_calculate_distances(int n, datum* x, datum* data, unsigned int* d); 



