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
Parameters can be passed in the command line overriding those in the core.mk file. For example:
```
make [sim] N_SOLVERS=30 HW_K=10
```
N_SOLVERS chooses the number of modules to solve many problems in parallel. 
HW_K chooses the number of registers and comparators (should be equal to the number of neighbors for best performance
but is not required).
Default values were chosen for problems with K=10 and maximum FPGA resource usage, suitable for very large problems.
However for smaller problems a lower number of solver modules leads to better energy efficiency since the process of
solving a problem is not completly parallelized (an increase in number of modules doesn't lead to a linear increase in performance).

These parameters can also be overriden from the parent repository.


To clean the simulation directory:
```
make sim-clean
```

To visualise simulation waveforms:
```
make sim-waves
```
## FPGA

To compile the FPGA:
```
make fpga
```

To clean FPGA files:
```
make fpga-clean
```
## Documentation

To compile the user guide:
```
make doc 
```

To clean document files:
```
make doc-clean
```

To clean document files including pdf files:
```
make doc-pdfclean
```

