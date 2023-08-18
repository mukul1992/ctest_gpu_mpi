#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>

int main( int argc, char** argv )
{
    MPI_Init (&argc, &argv);

    int rank, size;
    int ll=20480000;
    //int ll=2048;
    int nn=10;
    int* buff = NULL;
    size_t bytes;
    int i;
    double t1, t2;

    // Get MPI rank and size
    MPI_Comm_rank (MPI_COMM_WORLD, &rank);
    MPI_Comm_size (MPI_COMM_WORLD, &size);

    // Initialize buffer
    bytes = ll*sizeof(int);
    buff = (int*)malloc(bytes);

    for(i=0; i<ll; i++) {
        buff[i] = 1;
    }
/*
    if(rank==0)
        printf("buff = %d \n", buff[5]);
*/
    if (rank==0) {
        printf("No. of ranks: %d \n", size);
        printf("No. of bytes: %d \n", bytes);
    }

    /////////////////////////////////////////////////// CPU MPI
    // warm up
    for(i=0; i<nn; i++) {
        MPI_Allreduce(MPI_IN_PLACE, buff, ll, MPI_INT, MPI_SUM, MPI_COMM_WORLD);
    }

    t1 = MPI_Wtime();

    for(i=0; i<nn; i++) {
        MPI_Allreduce(MPI_IN_PLACE, buff, ll, MPI_INT, MPI_SUM, MPI_COMM_WORLD);
    }

    t2 = MPI_Wtime();

    if (rank==0) {
        printf("CPU MPI: %f \n", (t2-t1)/nn);
    }

    ////////////////////////////////////////////// GPU MPI
    for(i=0; i<ll; i++) {
        buff[i] = 1;
    }
    // Copy buff to device at start of region and back to host and end of region
    #pragma acc data copy(buff[0:ll])
    {
        // warm up
        //printf("%p\n",buff);
        // Inside this region the device data pointer will be used
        #pragma acc host_data use_device(buff)
        {
            //printf("%p\n",buff);

            for(i=0; i<nn; i++) {
                MPI_Allreduce(MPI_IN_PLACE, buff, ll, MPI_INT, MPI_SUM, MPI_COMM_WORLD);
            }
        }

        t1 = MPI_Wtime();

        #pragma acc host_data use_device(buff)
        {
            for(i=0; i<nn; i++) {
                MPI_Allreduce(MPI_IN_PLACE, buff, ll, MPI_INT, MPI_SUM, MPI_COMM_WORLD);
            }
        }

        t2 = MPI_Wtime();
    }

    if (rank==0) {
        printf("GPU MPI: %f \n", (t2-t1)/nn);
    }


    // Check that buffer is correct
/*
    if(rank==0)
        printf("buff = %d \n", buff[5]);
*/

    // Clean up
    free(buff);

    MPI_Finalize();

    return 0;
}
