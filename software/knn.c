#include "system.h"
#include "periphs.h"
#include <iob-uart.h>
#include "iob_timer.h"
#include "iob_knn.h"
#include "random.h" //random generator for bare metal


//neighbor info
uint32_t v_neighbor[N_SOLVERS/((K/HW_K)+(K%HW_K!=0))+(N_SOLVERS/((K/HW_K)+(K%HW_K!=0))==0)][K];

//labeled dataset
int16_t data[N][2];
uint16_t data_label[N];

int16_t x[M][2];
uint16_t x_label[M];
#ifdef DEBUG
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
 
  //init uart
  uart_init(UART_BASE, FREQ/BAUD);

  if(HW_K*N_SOLVERS<K){
    uart_printf("Hardware not big enough to solve this problem efficiently. Consider increasing HW_K or N_SOLVERS.\n");
  }

  init();

  //int32_t vote accumulator
  int32_t votes_acc[C] = {0};
  int32_t n_series = (K/HW_K)+(K%HW_K!=0);
  int32_t n_parallel = N_SOLVERS/n_series+(N_SOLVERS/n_series==0);
  
  //
  // PROCESS DATA
  //

  //start knn here

  //init timer and knn periph
  timer_init(TIMER_BASE);
  knn_init(KNN_BASE, n_parallel*n_series, n_series);

#ifdef DEBUG
  t_distance_total=0;
  t_insert_total=0;
#endif
  
   for (int32_t k=0; k<M; k+=n_parallel){ //for all test points
    if(k+n_parallel>M)
      n_parallel = M-k;

#ifdef DEBUG
    uart_printf("\n\nProcessing x[%d:%d]:\n", k, k+n_parallel-1);
 //   uart_printf("Datum \tX \tY \tLabel \n");
#endif

    //compute distances to dataset points
    knn_get_neighbours(v_neighbor, data, &x[k], HW_K, n_parallel*n_series, n_series);
#ifdef DEBUG
    for(int32_t i=0; i < N; i++){
   //   uart_printf("Datum \t%d \t%d \t%d \n", (uint32_t)data[i][0], (uint32_t)data[i][1], (uint32_t)data_label[i]);
    }
#endif
    //classify test point
    get_teste_point_class(votes_acc, k, n_parallel);
  } //all test points classified

  //stop knn here
  //read current timer count, compute elapsed time
#ifndef DEBUG
  elapsed = timer_get_count();
  elapsedu = timer_time_us();
  uart_printf("\nExecution time: %dus (%d cycles @%dMHz)\n", elapsedu, (uint32_t)elapsed, FREQ/1000000);
  uart_printf("\n");
#endif
  //print classification distribution to check for statistical bias
  for (int32_t l=0; l<C; l++)
    uart_printf("%d ", votes_acc[l]);

  uart_printf("\n");

  for(int32_t i = 0; i < M; i++){
    uart_printf("X:%d\t\tY:%d\t\tLabel:%d\n", x[i][0], x[i][1], x_label[i]);
  }
}


void init(void){
   //generate random seed
  random_init(S);

  //init dataset
  for (int i=0; i<N; i++) {

    //init coordinates
    data[i][0] = (short) cmwc_rand();
    while(data[i][0]<MIN_SHORT || data[i][0]>MAX_SHORT)
      data[i][0] = (short) cmwc_rand();

    data[i][1]=(short) cmwc_rand();
    while(data[i][1]<MIN_SHORT || data[i][1]>MAX_SHORT)
      data[i][1] = (short) cmwc_rand();

    //init label
    data_label[i] = (unsigned char) (cmwc_rand()%C);
  }
  for (int k=0; k<M; k++) {
    x[k][0] = (short) cmwc_rand();
    while(x[k][0]<MIN_SHORT || x[k][0]>MAX_SHORT)
      x[k][0] = (short) cmwc_rand();

    x[k][1]=(short) cmwc_rand();
    while(x[k][1]<MIN_SHORT || x[k][1]>MAX_SHORT)
      x[k][1] = (short) cmwc_rand();

    //x[k].label will be calculated by the algorithm
  }/*
#ifdef DEBUG
  uart_printf("\n\nTEST POINTS\n");
  uart_printf("Idx \tX \tY\n");
  for (int32_t k=0; k<M; k++)
    uart_printf("%d \t%d \t%d\n", k, x[k][0], x[k][1]);
#endif
*/
}


void get_teste_point_class(int32_t *votes_acc, int32_t k, int32_t n_parallel){

  for(int i = 0; i < n_parallel && i+k<M; i++){

#ifdef DEBUG
    timer_reset();
#endif

    //clear all votes
    int32_t votes[C] = {0};
    int32_t best_votation = 0;
    int32_t best_voted = 0;


    //make neighbours vote
    for (int32_t j=0; j<K; j++) { //for all neighbors
      if ( (++votes[data_label[v_neighbor[i][j]]]) > best_votation ) {
        best_voted = data_label[v_neighbor[i][j]];
        best_votation = votes[best_voted];
      }
    }

    x_label[k+i] = best_voted;

    votes_acc[best_voted]++;

#ifdef DEBUG
    t_vote = timer_get_count();
    uart_printf("\n\nNEIGHBORS of x[%d]=(%d, %d):\n", k+i, x[k+i][0], x[k+i][1]);
    uart_printf("K \tIdx \tX \tY \tLabel\n");
    for (int32_t j=0; j<K; j++)
      uart_printf("%d \t%d \t%d \t%d \t%d \n", j+1, v_neighbor[i][j], data[v_neighbor[i][j]][0],  data[v_neighbor[i][j]][1],  data_label[v_neighbor[i][j]]);

    uart_printf("\n\nCLASSIFICATION of x[%d]:\n", k+i);
    uart_printf("X \tY \tLabel\n");
    uart_printf("%d \t%d \t%d\n", x[k+i][0], x[k+i][1], x_label[k+i]);

    uart_printf("\nVotes took %d cycles\n", (uint32_t)t_vote);
#endif
  }

}
