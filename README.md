# ctest_gpu_mpi
To reproduce the GPU-aware Allreduce issue with an OpenACC (and CUDA) Fortran code on Perlmutter. The Fortran code does not use GPU-GPU communication whereas the equivalent C program does it successfully.

The SLURM job script `run.sh` includes the compilation and run commands for the openacc tests.
The SLURM job script `ompi_run.sh` includes the compilation and run commands for the openacc tests with openmpi.
The SLURM job script `exp.sh` includes the compilation and run commands for the cuda test.

The `mpi.log` will show the toy benchmark performance compared between C and Fortran.

The `profile.sh` script has commands to run the nsys profiles, the reports comfirm that while the C code does direct GPU-GPU transfers, the Fortran code does it through the host.
