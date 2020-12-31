# iob-soc-knn
Parent repository: git@github.com:CesarCosta40/iob-soc-knn.git

## Simulation

The following commands will run locally if the simulator selected by the
SIMULATOR variable is installed and listed in the LOCAL\_SIM\_LIST
variable. Otherwise they will run by ssh on the server selected by the
SIM_SERVER variable.

To simulate:
```
make [sim]
```
Parameters can be passed in the command line overriding those in the system.mk file. For example:
```
make [sim] N_SOLVERS=32 HW_K=10
```
N_SOLVERS chooses the number of modules to solve many problems in parallel. 
HW_K chooses the number of registers and comparators (should be equal to the number of neighbors for best performance).

To clean the simulation directory:
```
make sim-clean
```

To visualise simulation waveforms:
```
make sim-waves
```
