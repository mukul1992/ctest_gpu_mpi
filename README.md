# ctest_gpu_mpi
To reproduce the GPU-aware Allreduce issue with an OpenACC Fortran code on Perlmutter. The Fortran code does not use GPU-GPU communication whereas the equivalent C program does it successfully.

The SLURM job script `run.sh` includes the compilation and run commands.
