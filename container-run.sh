#!/bin/bash

## this script is to run on the container loaded using the following commands:
#$ salloc --nodes 1 --qos interactive --time 01:00:00 --constraint gpu --gpus 4 --account=nstaff
#$ podman-hpc run --rm -it --gpu -v $(pwd):/host_pwd nvcr.io/nvidia/nvhpc:23.5-devel-cuda_multi-ubuntu22.04 /bin/bash

cd host_pwd

echo "Fortran allreduce test"
mpifort -acc=gpu -Minfo=accel -o test_gpu_allreduce_ftn.x test_gpu_allreduce.f90
./test_gpu_allreduce_ftn.x

#echo "Fortran allgather test" >> mpi.log
#srun -N 1 -n 2 bash -c "export CUDA_VISIBLE_DEVICES=\$((3-SLURM_LOCALID)); ./test_gpu_allgather_ftn.x" >> mpi.log

#echo "C allreduce test" >> mpi.log
#cc -acc=gpu -Minfo=accel -o test_gpu_allreduce_c.x test_gpu_allreduce.c
#srun -N 1 -n 2 bash -c "export CUDA_VISIBLE_DEVICES=\$((3-SLURM_LOCALID)); ./test_gpu_allreduce_c.x" >> mpi.log
