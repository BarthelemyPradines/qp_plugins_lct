
! ---

 BEGIN_PROVIDER [ double precision, two_e_tc_non_hermit_integral_alpha, (ao_num, ao_num)]
&BEGIN_PROVIDER [ double precision, two_e_tc_non_hermit_integral_beta , (ao_num, ao_num)]

  implicit none
  integer          :: i, j, k, l
  double precision :: density, density_a, density_b

  two_e_tc_non_hermit_integral_alpha = 0.d0
  two_e_tc_non_hermit_integral_beta  = 0.d0
  do i = 1, ao_num
    do k = 1, ao_num
!!$OMP PARALLEL                  &
!!$OMP DEFAULT (NONE)            &
!!$OMP PRIVATE (j,l,density_a,density_b,density) & 
!!$OMP SHARED (i,k,ao_num,SCF_density_matrix_ao_alpha,SCF_density_matrix_ao_beta,ao_non_hermit_term_chemist) & 
!!$OMP SHARED (two_e_tc_non_hermit_integral_alpha,two_e_tc_non_hermit_integral_beta)
!!$OMP DO SCHEDULE (dynamic)
      do j = 1, ao_num
        do l = 1, ao_num
          density_a = TCSCF_density_matrix_ao_alpha(l,j)
          density_b = TCSCF_density_matrix_ao_beta (l,j)
          density   = density_a + density_b                      !  rho(l,j)   *  < k l| T | i j>
          two_e_tc_non_hermit_integral_alpha(k,i) += density   * ao_two_e_tc_tot(l,j,k,i)
          two_e_tc_non_hermit_integral_beta(k,i)  += density   * ao_two_e_tc_tot(l,j,k,i)
          two_e_tc_non_hermit_integral_alpha(k,i) -= density_a * ao_two_e_tc_tot(k,j,l,i)
          two_e_tc_non_hermit_integral_beta(k,i)  -= density_b * ao_two_e_tc_tot(k,j,l,i)
        enddo
      enddo
!!$OMP END DO
!!$OMP END PARALLEL
    enddo
  enddo

END_PROVIDER 

! ---

 BEGIN_PROVIDER [ double precision, two_e_tc_non_hermit_integral_alpha_deb, (ao_num, ao_num)]
&BEGIN_PROVIDER [ double precision, two_e_tc_non_hermit_integral_beta_deb , (ao_num, ao_num)]

  implicit none
  integer          :: p, q, r, s
  double precision :: density_a, density_b
  double precision :: integ

  two_e_tc_non_hermit_integral_alpha_deb = 0.d0
  two_e_tc_non_hermit_integral_beta_deb  = 0.d0

  do p = 1, ao_num
    do q = 1, ao_num
      do r = 1, ao_num
        do s = 1, ao_num

          density_a = TCSCF_density_matrix_ao_alpha(s,r)
          density_b = TCSCF_density_matrix_ao_beta (s,r)

          !             < p s || q r >     -       < p s || q r >
          integ = ao_two_e_tc_tot(p,q,s,r) - ao_two_e_tc_tot(p,r,s,q) 

          two_e_tc_non_hermit_integral_alpha_deb(p,q) += density_a * integ 
          two_e_tc_non_hermit_integral_beta_deb (p,q) += density_b * integ 
        enddo
      enddo
    enddo
  enddo

END_PROVIDER 

! ---

BEGIN_PROVIDER [ double precision, Fock_matrix_tc_ao_alpha, (ao_num, ao_num)]
  implicit none
  Fock_matrix_tc_ao_alpha =  ao_one_e_integrals                 &
                           + two_e_tc_non_hermit_integral_alpha 
  integer :: i
!  print*,'AO diag TC mat'
!  do i = 1, ao_num
!   write(35,'(100(F16.10,X))')Fock_matrix_tc_ao_alpha(:,i)
!  enddo
END_PROVIDER 

! ---
BEGIN_PROVIDER [ double precision, Fock_matrix_tc_ao_beta, (ao_num, ao_num)]
  implicit none
  Fock_matrix_tc_ao_beta = ao_one_e_integrals                  &
                         + two_e_tc_non_hermit_integral_beta 
END_PROVIDER 
! ---

BEGIN_PROVIDER [ double precision, Fock_matrix_tc_ao_tot, (ao_num, ao_num) ]
  implicit none
  Fock_matrix_tc_ao_tot = 0.5d0 * (Fock_matrix_tc_ao_alpha + Fock_matrix_tc_ao_beta)
END_PROVIDER

! ---

BEGIN_PROVIDER [ double precision, Fock_matrix_tc_mo_alpha, (mo_num, mo_num) ]
  implicit none
  if(bi_ortho)then
   call ao_to_mo_bi_ortho( Fock_matrix_tc_ao_alpha, size(Fock_matrix_tc_ao_alpha, 1) &
                         , Fock_matrix_tc_mo_alpha, size(Fock_matrix_tc_mo_alpha, 1) )
  else
   call ao_to_mo(  Fock_matrix_tc_ao_alpha, size(Fock_matrix_tc_ao_alpha, 1) &
                 , Fock_matrix_tc_mo_alpha, size(Fock_matrix_tc_mo_alpha, 1) )
  endif
END_PROVIDER

! ---

BEGIN_PROVIDER [ double precision, Fock_matrix_tc_mo_beta, (mo_num,mo_num) ]
  implicit none
  if(bi_ortho)then
   call ao_to_mo_bi_ortho( Fock_matrix_tc_ao_beta, size(Fock_matrix_tc_ao_beta, 1) &
                         , Fock_matrix_tc_mo_beta, size(Fock_matrix_tc_mo_beta, 1) )
  else
   call ao_to_mo(  Fock_matrix_tc_ao_beta, size(Fock_matrix_tc_ao_beta, 1) &
                 , Fock_matrix_tc_mo_beta, size(Fock_matrix_tc_mo_beta, 1) )
  endif
END_PROVIDER


BEGIN_PROVIDER [ double precision, Fock_matrix_tc_mo_tot, (mo_num, mo_num)]
  implicit none
  Fock_matrix_tc_mo_tot = 0.5d0 * (Fock_matrix_tc_mo_alpha + Fock_matrix_tc_mo_beta)
  if(three_body_h_tc) then
    Fock_matrix_tc_mo_tot += fock_3_mat
  endif
  !call restore_symmetry(mo_num, mo_num, Fock_matrix_tc_mo_tot, mo_num, 1.d-10)
END_PROVIDER 

! ---

