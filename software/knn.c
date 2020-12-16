#include "system.h"
#include "periphs.h"
#include <iob-uart.h>
#include "iob_timer.h"
#include "iob_knn.h"
#include "random.h" //random generator for bare metal


#ifdef DEBUG
unsigned long long t_distance[N];
unsigned long long t_insert[N];
unsigned long long t_distance_total;
unsigned long long t_insert_total;
unsigned long long t_vote;
#endif


//
//Functions
//

///////////////////////////////////////////////////////////////////
int main() {

  unsigned long long elapsed;
  uint32_t elapsedu;

  //int32_t vote accumulator
  int32_t votes_acc[C] = {0};

  //labeled dataset
  datum data[N], x[M];

  //neighbor info
  neighbor v_neighbor[K];

  init(data, x);

  //
  // PROCESS DATA
  //

  //start knn here

  //init timer and knn periph
  timer_init(TIMER_BASE);
  knn_init(KNN_BASE);

  #ifdef DEBUG
    t_distance_total=0;
    t_insert_total=0;
  #endif

  for (int32_t k=0; k<M; k++) { //for all test points
    //compute distances to dataset points
    #ifdef DEBUG
        uart_printf("\n\nProcessing x[%d]:\n", k);
    #endif

    uint32_t a = *(uint32_t*)(&x[k]);
    //knn_set_test_point(a);
    //knn_calculate_distances(N, &x[k], data, d);
    //init all k neighbors infinite distance

    #ifdef DEBUG
        uart_printf("Datum \tX \tY \tLabel \tDistanceClks \tInsertClks\n");
    #endif

    for (uint8_t i=0; i<N; i++) { //for all dataset points
      //compute distance to x[k]
      #ifdef DEBUG
        timer_reset();
      #endif
      uint32_t b = *(uint32_t*)(&data[i]);
      knn_send_points(a, b);
      //knn_send_dataset_point(b);
      #ifdef DEBUG
          uart_printf("Datum \t%d \t%d \t%d \t%d \t%d\n", (uint32_t)data[i].x, (uint32_t)data[i].y, (uint32_t)data[i].label, (uint32_t)t_distance[i], (uint32_t)t_insert[i]);
      #endif
    }

    knn_get_neighbours(v_neighbor);
    //classify test point
    get_teste_point_class(data, x, v_neighbor, votes_acc, k);
  } //all test points classified

  //stop knn here
  //read current timer count, compute elapsed time
  #ifdef DEBUG
    elapsed = timer_get_count();
    elapsedu = timer_time_us();
    uart_printf("\nExecution time: %dus (%d cycles @%dMHz)\n", elapsedu, (uint32_t)elapsed, FREQ/1000000);
    uart_printf("\nDistance cycles: %d\nInsert cycles: %d\n\n", (uint32_t)t_distance_total, (uint32_t)t_insert_total);
  #endif


  //print classification distribution to check for statistical bias
  for (int32_t l=0; l<C; l++)
    uart_printf("%d ", votes_acc[l]);

  uart_printf("\n");

  for(int32_t i = 0; i < M; i++){
    uart_printf("X:%d\t\tY:%d\t\tLabel:%d\n", x[i].x, x[i].y, x[i].label);

  }
}


void init(datum data[], datum x[]){
    //init uart
    uart_init(UART_BASE, FREQ/BAUD);

    //generate random seed
    random_init(S);

    //init dataset
    for (int32_t i=0; i<N; i++) {
      //init coordinates
      data[i].x = (int16_t) cmwc_rand();
      data[i].y = (int16_t) cmwc_rand();
      //init label
      data[i].label = (unsigned char) (cmwc_rand()%C);
    }

    //init test points
    for (int32_t k=0; k<M; k++) {
      x[k].x  = (int16_t) cmwc_rand();
      x[k].y  = (int16_t) cmwc_rand();
      //x[k].label will be calculated by the algorithm
    }
    #ifdef DEBUG
      uart_printf("\n\nTEST POINTS\n");
      uart_printf("Idx \tX \tY\n");
      for (int32_t k=0; k<M; k++)
        uart_printf("%d \t%d \t%d\n", k, x[k].x, x[k].y);
    #endif

}

void get_teste_point_class(datum data[], datum x[], neighbor v_neighbor[], int32_t *votes_acc, int32_t k){
  //clear all votes
  int32_t votes[C] = {0};
  int32_t best_votation = 0;
  int32_t best_voted = 0;

  #ifdef DEBUG
      timer_reset();
  #endif
  //make neighbours vote
  for (int32_t j=0; j<K; j++) { //for all neighbors
    if ( (++votes[data[v_neighbor[j].idx].label]) > best_votation ) {
      best_voted = data[v_neighbor[j].idx].label;
      best_votation = votes[best_voted];
    }
  }

  x[k].label = best_voted;

  votes_acc[best_voted]++;

  #ifdef DEBUG
    t_vote = timer_get_count();
    uart_printf("\n\nNEIGHBORS of x[%d]=(%d, %d):\n", k, x[k].x, x[k].y);
    uart_printf("K \tIdx \tX \tY \tDist \t\tLabel\n");
    for (int32_t j=0; j<K; j++)
      uart_printf("%d \t%d \t%d \t%d \t%d \t%d\n", j+1, v_neighbor[j].idx, data[v_neighbor[j].idx].x,  data[v_neighbor[j].idx].y, v_neighbor[j].dist,  data[v_neighbor[j].idx].label);

    uart_printf("\n\nCLASSIFICATION of x[%d]:\n", k);
    uart_printf("X \tY \tLabel\n");
    uart_printf("%d \t%d \t%d\n", x[k].x, x[k].y, x[k].label);

    uart_printf("\nVotes took %d cycles\n", (uint32_t)t_vote);
  #endif
}
