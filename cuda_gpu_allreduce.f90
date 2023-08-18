program GPUdirect
    use cudafor
    implicit none
    include 'mpif.h'

    integer :: rank, size, ierror
    integer,dimension(:),allocatable :: h_buff
    integer,device :: d_rank
    integer,dimension(:),allocatable,device :: d_buff
    integer :: i

   integer, parameter :: dp = selected_real_kind(15,300)
   integer, parameter :: ll = 20480000
   integer, parameter :: nn = 10
   integer :: ii
   real(dp) :: t1
   real(dp) :: t2

    call MPI_INIT(ierror)

    ! Get MPI rank and size
    call MPI_COMM_RANK (MPI_COMM_WORLD, rank, ierror)
    call MPI_COMM_SIZE (MPI_COMM_WORLD, size, ierror)

    ! Initialize host and device buffers
    allocate(h_buff(ll))
    allocate(d_buff(ll))

    h_buff(:) = 1

   if(rank == 0) then
      write(6,"(2X,A,I10)") "Number of ranks:",size
      write(6,"(2X,A,I10)") "Number of bytes:",ll*4
      flush(6)
   end if

   !!!!!!!!!!!!!!!!!!!!! CPU MPI !!!!!!!!!!!!!!!!!!!!!

   ! warm up

   do ii = 1,nn
      call MPI_Allreduce(MPI_IN_PLACE,h_buff,ll,MPI_INTEGER,MPI_SUM,MPI_COMM_WORLD,ierror)
   end do

   ! time

   t1 = MPI_Wtime()

   do ii = 1,nn
        call MPI_Allreduce(MPI_IN_PLACE,h_buff,ll,MPI_INTEGER,MPI_SUM,MPI_COMM_WORLD,ierror)
   end do

   t2 = MPI_Wtime()

   if(rank == 0) then
      write(6,"(2X,A,F10.3,A)") "CPU MPI:",(t2-t1)/nn,"s"
      flush(6)
   end if

   !!!!!!!!!!!!!!!!!!!!! GPU MPI !!!!!!!!!!!!!!!!!!!!!

    ! Implicity copy rank to device
    d_rank = rank
    h_buff(:) = 1
   d_buff = h_buff

    ! Preform allgather using device buffers
   do ii = 1,nn
    call MPI_Allreduce(MPI_IN_PLACE,d_buff,ll,MPI_INTEGER,MPI_SUM,MPI_COMM_WORLD,ierror)
   end do

    ! time

    t1 = MPI_Wtime()

    do ii = 1,nn
        call MPI_Allreduce(MPI_IN_PLACE,d_buff,ll,MPI_INTEGER,MPI_SUM,MPI_COMM_WORLD,ierror)
    end do

    t2 = MPI_Wtime()

    if(rank == 0) then
       write(6,"(2X,A,F10.3,A)") "GPU MPI:",(t2-t1)/nn,"s"
       flush(6)
    end if

    ! Clean up
    deallocate(h_buff)
    deallocate(d_buff)
    call MPI_FINALIZE(ierror)

end program GPUdirect