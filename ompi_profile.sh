#!/bin/bash

## for profiling the OpenMPI run

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
module load nvidia/23.1
module load openmpi;

echo "Fortran allreduce test" > mpi.log
srun -N 1 -n 2 bash -c "
    export CUDA_VISIBLE_DEVICES=\$((3-SLURM_LOCALID));
    /opt/nvidia/hpc_sdk/Linux_x86_64/23.1/profilers/Nsight_Systems/bin/nsys profile -t openacc,mpi --stats=true --mpi-impl=openmpi -o ftn_report_%q{SLURM_PROCID} ./test_gpu_allreduce_ftn.x"
    >> mpi.log

echo "C allreduce test" >> mpi.log
srun -N 1 -n 2 bash -c "
    export CUDA_VISIBLE_DEVICES=\$((3-SLURM_LOCALID));
    /opt/nvidia/hpc_sdk/Linux_x86_64/23.1/profilers/Nsight_Systems/bin/nsys profile -t openacc,mpi --stats=true --mpi-impl=openmpi -o c_report_%q{SLURM_PROCID} ./test_gpu_allreduce_c.x"
    >> mpi.log
