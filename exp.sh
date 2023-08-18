#!/bin/bash

## job submission script for different experiments

#SBATCH --job-name=test
#SBATCH --time=00:10:00
#SBATCH --account=nstaff
#SBATCH --constraint=gpu
#SBATCH --qos=debug
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=4
#SBATCH --gpus-per-node=4
#SBATCH --gpu-bind=none
#SBATCH --cpus-per-task=32

export MPICH_OFI_NIC_POLICY=GPU
export SLURM_CPU_BIND=cores

echo "Fortran allreduce test" > mpi.log

### for cuda test ###
#module load PrgEnv-nvidia
#ftn -o cuda_gpu_allreduce.x -Mcuda cuda_gpu_allreduce.f90
#srun -N 1 -n 2 bash -c "export CUDA_VISIBLE_DEVICES=\$((3-SLURM_LOCALID)); ./cuda_gpu_allreduce.x" >> mpi.log

### for cuda test with openmpi ###
module load PrgEnv-nvidia  nvidia/23.1  openmpi
mpifort -acc=gpu -Minfo=accel -o cuda_gpu_allreduce.x cuda_gpu_allreduce.f90
srun --mpi=pmix -N 1 -n 2 bash -c "export CUDA_VISIBLE_DEVICES=\$((3-SLURM_LOCALID)); ./cuda_gpu_allreduce.x" >> mpi.log
