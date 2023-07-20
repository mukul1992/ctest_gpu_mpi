#!/bin/bash

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

module load PrgEnv-nvidia

echo "Fortran allreduce test" > mpi.log
ftn -acc=gpu -Minfo=accel -o test_gpu_allreduce_ftn.x test_gpu_allreduce.f90
srun -N 1 -n 2 bash -c "export CUDA_VISIBLE_DEVICES=\$((3-SLURM_LOCALID)); ./test_gpu_allreduce_ftn.x" >> mpi.log

#echo "Fortran allgather test" >> mpi.log
#srun -N 1 -n 2 bash -c "export CUDA_VISIBLE_DEVICES=\$((3-SLURM_LOCALID)); ./test_gpu_allgather_ftn.x" >> mpi.log

echo "C allreduce test" >> mpi.log
cc -acc=gpu -Minfo=accel -o test_gpu_allreduce_c.x test_gpu_allreduce.c
srun -N 1 -n 2 bash -c "export CUDA_VISIBLE_DEVICES=\$((3-SLURM_LOCALID)); ./test_gpu_allreduce_c.x" >> mpi.log
