 BEGIN_PROVIDER [double precision, htilde_matrix_elmt, (N_det,N_det)]
&BEGIN_PROVIDER [double precision, htilde_matrix_elmt_tranp, (N_det,N_det)]
&BEGIN_PROVIDER [double precision, htilde_matrix_elmt_eff, (N_det,N_det)]
&BEGIN_PROVIDER [double precision, htilde_matrix_elmt_deriv, (N_det,N_det)]
&BEGIN_PROVIDER [double precision, htilde_matrix_elmt_hcore, (N_det,N_det)]
&BEGIN_PROVIDER [double precision, htilde_matrix_elmt_hthree, (N_det,N_det)]
 implicit none
 BEGIN_DOC
! htilde_matrix_elmt(j,i) = <J| H^tilde |I> 
!
! WARNING !!!!!!!!! IT IS NOT HERMITIAN !!!!!!!!!
 END_DOC
 integer :: i,j
 double precision :: hmono,heff,hderiv,hthree,htot
 do i = 1, N_det
  do j = 1, N_det
  ! < J | Htilde | I >
   call htilde_mu_mat(psi_det(1,1,j),psi_det(1,1,i),hmono,heff,hderiv,hthree,htot)
   htilde_matrix_elmt(j,i) = htot
   htilde_matrix_elmt_eff(j,i) = heff
   htilde_matrix_elmt_deriv(j,i) = hderiv
   htilde_matrix_elmt_hcore(j,i) = hmono
   htilde_matrix_elmt_hthree(j,i) = hthree
  enddo
 enddo
 do i = 1, N_det
  do j = 1, N_det
   htilde_matrix_elmt_tranp(j,i) = htilde_matrix_elmt(i,j)
  enddo
 enddo
END_PROVIDER 


BEGIN_PROVIDER [ double precision, diag_htilde, (N_det)]
 implicit none
 integer :: i
 double precision :: hmono,heff,hderiv,hthree,htot
 do i = 1, N_det
  call htilde_mu_mat(psi_det(1,1,i),psi_det(1,1,i),hmono,heff,hderiv,hthree,htot)
  diag_htilde(i) = htot
 enddo
END_PROVIDER 

