program test_gpu_allreduce

   !use MPI

   implicit none
   include 'mpif.h'

   !implicit none (type,external)

   integer, parameter :: dp = selected_real_kind(15,300)
   !integer, parameter :: ll = 20480000
   integer, parameter :: ll = 2048
   integer, parameter :: nn = 10

   integer :: comm
   integer :: irank
   integer :: nrank
   integer :: ierr
   integer :: ii

   real(dp) :: t1
   real(dp) :: t2

   integer, allocatable :: buf(:)
   !integer, allocatable :: buf2(:)

   call MPI_Init(ierr)

   comm = MPI_COMM_WORLD

   call MPI_Comm_rank(comm,irank,ierr)
   call MPI_Comm_size(comm,nrank,ierr)

   allocate(buf(ll))
   !allocate(buf2(ll))

   buf(:) = 1

   if(irank == 0) then
      write(6,"(2X,A,I10)") "Number of ranks:",nrank
      write(6,"(2X,A,I10)") "Number of bytes:",ll*4
      flush(6)
   end if

   !!!!!!!!!!!!!!!!!!!!! CPU MPI !!!!!!!!!!!!!!!!!!!!!

   ! warm up

   do ii = 1,nn
      call MPI_Allreduce(MPI_IN_PLACE,buf,ll,MPI_INTEGER,MPI_SUM,comm,ierr)
      !call MPI_Allreduce(buf,buf2,ll,MPI_INTEGER,MPI_SUM,comm,ierr)
   end do

   ! time

   t1 = MPI_Wtime()

   do ii = 1,nn
      call MPI_Allreduce(MPI_IN_PLACE,buf,ll,MPI_INTEGER,MPI_SUM,comm,ierr)
      !call MPI_Allreduce(buf,buf2,ll,MPI_INTEGER,MPI_SUM,comm,ierr)
   end do

   t2 = MPI_Wtime()

   if(irank == 0) then
      write(6,"(2X,A,F10.3,A)") "CPU MPI:",(t2-t1)/nn,"s"
      flush(6)
   end if

   !!!!!!!!!!!!!!!!!!!!! GPU MPI !!!!!!!!!!!!!!!!!!!!!

   buf(:) = 1

   !$acc data copy(buf)

   ! warm up

   print *, loc(buf)
   !$acc host_data use_device(buf)
   print *, loc(buf)
   do ii = 1,nn
      call MPI_Allreduce(MPI_IN_PLACE,buf,ll,MPI_INTEGER,MPI_SUM,comm,ierr)
      !call MPI_Allreduce(buf,buf2,ll,MPI_INTEGER,MPI_SUM,comm,ierr)
   end do
   !$acc end host_data

   ! time

   t1 = MPI_Wtime()

   !$acc host_data use_device(buf)
   do ii = 1,nn
      call MPI_Allreduce(MPI_IN_PLACE,buf,ll,MPI_INTEGER,MPI_SUM,comm,ierr)
      !call MPI_Allreduce(buf,buf2,ll,MPI_INTEGER,MPI_SUM,comm,ierr)
   end do
   !$acc end host_data

   t2 = MPI_Wtime()

   if(irank == 0) then
      write(6,"(2X,A,F10.3,A)") "GPU MPI:",(t2-t1)/nn,"s"
      flush(6)
   end if

   !$acc end data

   deallocate(buf)
   !deallocate(buf2)

   call MPI_Finalize(ierr)

end program
