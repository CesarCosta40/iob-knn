#pragma once

//Structures

typedef struct datum{
  short x;
  short y;
  unsigned char label;
}datum;

typedef struct neighbor {
  unsigned int idx; //index in dataset array
  unsigned int dist; //distance to test point
} neighbor;


//Functions
void knn_reset();
//void knn_set_point(short x1, short y1);
void knn_init( int base_address);	
//unsigned int knn_get_distance(short x2, short y2);
//void knn_calculate_distances(int n, datum* x, datum* data, unsigned int* d); 
void knn_send_distance(unsigned int d);
void knn_get_neighbors(neighbor*);

