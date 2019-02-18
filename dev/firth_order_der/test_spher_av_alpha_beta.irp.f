program pouet
 read_wf = .True.
 touch read_wf
!call test_int_f
!call test_int_n2
!call test_int_n
!call test_int_n2_spherical_av
!call test_int_f_paper_spherical_av
 call test_effective_intera_spherical_av
!call test_ecmd_ab_sph 
!call test_polynome
end

 subroutine test_int_f
 implicit none
 integer :: i
 double precision :: r(3)
 double precision :: f_hf_alpha_beta 
 double precision :: accu 
 accu = 0.d0 
 print*,'\\\\\\\\\\\\\\\\\'
 print*,' '
 do i = 1, n_points_final_grid
  r(1) = final_grid_points(1,i)
  r(2) = final_grid_points(2,i)
  r(3) = final_grid_points(3,i)
  call give_f_alpha_beta_hf_at_r(r,f_hf_alpha_beta)
  accu += f_hf_alpha_beta*final_weight_at_r_vector(i) 
 enddo
 print*,'integral f             =',accu
 print*,'HF_two_electron_energy =',HF_two_electron_energy
 print*,"Error                  =",accu-HF_two_electron_energy 
end


 subroutine test_int_n2
 implicit none
 integer :: i,j
 double precision :: r(3)
 double precision :: n2_hf_alpha_beta 
 double precision :: accu 
 accu = 0.d0 
 print*,'\\\\\\\\\\\\\\\\\'
 print*,' '
 do i = 1, n_points_final_grid
  r(1) = final_grid_points(1,i)
  r(2) = final_grid_points(2,i)
  r(3) = final_grid_points(3,i)
  call give_n2_alpha_beta_hf_at_r(r,n2_hf_alpha_beta) 
  accu += n2_hf_alpha_beta*final_weight_at_r_vector(i)
 enddo
 print*,'integral f             =',accu
end




!subroutine test_int_n
!implicit none
!include 'utils/constants.include.F'
!integer :: i,j,k,istate
!double precision :: accu_dr3,accu_dr,dm_a,dm_b
!double precision :: r(3)
!accu_dr3 = 0.d0 
!accu_dr =0.d0
!print*,'\\\\\\\\\\\\\\\\\'
!print*,' '
!!!!!! Bonjour la grille
!integer :: n_points_radial_grid_local
!n_points_radial_grid_local =1250
!double precision :: dr_radial_integral_local 
!double precision,allocatable    :: grid_points_radial_local(:),w_rad_local(:)
!allocate (grid_points_radial_local(n_points_radial_grid_local),w_rad_local(n_points_radial_grid_local)) 
!dr_radial_integral_local = 15.d0/dble(n_points_radial_grid_local)
!grid_points_radial_local(1)=dr_radial_integral_local
!w_rad_local(1)=dr_radial_integral_local*grid_points_radial_local(1)**2
!do i = 2, n_points_radial_grid_local
! grid_points_radial_local(i) = grid_points_radial_local(i-1) + dr_radial_integral_local
! w_rad_local(i)=dr_radial_integral_local*grid_points_radial_local(i)**2
!enddo

!double precision,allocatable :: n_tilde(:)
!allocate(n_tilde(n_points_radial_grid_local)) 
!n_tilde = 0.d0
!!!!!! Aurevoi la grille

!do i = 1,n_points_radial_grid_local 
! do k = 1,n_points_integration_angular
!  r(1)= grid_points_radial_local(i)*angular_quadrature_points(k,1)
!  r(2)= grid_points_radial_local(i)*angular_quadrature_points(k,2)
!  r(3)= grid_points_radial_local(i)*angular_quadrature_points(k,3)
!  call dm_dft_alpha_beta_at_r(r,dm_a,dm_b)
!  accu_dr3 += dm_a*weights_angular_points(k)*w_rad_local(i)
! enddo
!enddo


!do i = 1,n_points_radial_grid_local 
! do k = 1,n_points_integration_angular
!  r(1)= grid_points_radial_local(i)*angular_quadrature_points(k,1)
!  r(2)= grid_points_radial_local(i)*angular_quadrature_points(k,2)
!  r(3)= grid_points_radial_local(i)*angular_quadrature_points(k,3)
!  call dm_dft_alpha_beta_at_r(r,dm_a,dm_b)
!  n_tilde(i) += dm_a*weights_angular_points(k)/(4.d0*pi) 
! enddo
!  accu_dr += n_tilde(i)*4.d0*pi*w_rad_local(i)
!enddo

!print*,'integral n alpha(r,teta,phi)  dr3   =',accu_dr3
!print*,'integral n alpha_tilde(r)           =',accu_dr
!print*,'dernier r  =',grid_points_radial_local(n_points_radial_grid_local)
!end


 subroutine test_int_n2_spherical_av
 implicit none
 include 'utils/constants.include.F'
 integer :: i,j,k,istate
 double precision :: accu_num,accu_ana
 double precision :: r1(3),r2(3)
 double precision :: r12
 double precision :: n2_hf_alpha_beta 
 accu_ana = 0.d0
 print*,'\\\\\\\\\\\\\\\\\'
 print*,' '
 r1(1) = 0.5d0
 r1(2) = 0.3d0
 r1(3) = 0.d0
 double precision :: delta,n2_deriv2,n2_deriv4,n2_0
 delta=0.00001d0
 r12=0.d0
 call give_n2_alpha_beta_hf_at_r1_r12(r1,r12,accu_ana,n2_0,n2_deriv2,n2_deriv4)
!print*,'n2_deriv2 =',n2_deriv2
!print*,'n2_deriv4 =',n2_deriv4
 do i = 1,10000 
 accu_num = 0.d0 
  do k = 1,n_points_integration_angular
   r2(1)= r1(1)+r12*angular_quadrature_points(k,1)
   r2(2)= r1(2)+r12*angular_quadrature_points(k,2)
   r2(3)= r1(3)+r12*angular_quadrature_points(k,3)
   call give_n2_alpha_beta_hf_at_r1_r2(r1,r2,n2_hf_alpha_beta) 
   accu_num += n2_hf_alpha_beta*weights_angular_points(k)/(4.d0*pi)
  enddo

  call give_n2_alpha_beta_hf_at_r1_r12(r1,r12,accu_ana,n2_0,n2_deriv2,n2_deriv4)
  write(33,*)r12,accu_num
  write(44,*)r12,accu_ana
  r12 += delta 

 !print*,'integral num   =',accu_num
 !print*,'integral ana   =',accu_ana
 enddo
end


 subroutine test_int_f_paper_spherical_av 
 implicit none
 include 'utils/constants.include.F'
 integer :: i,j,k,istate
 double precision :: accu_num,accu_ana
 double precision :: r1(3),r2(3)
 double precision :: r12
 double precision :: f_hf_alpha_beta 
 accu_ana = 0.d0
 print*,'\\\\\\\\\\\\\\\\\'
 print*,' '
 r1(1) = 0.5d0
 r1(2) = 0.3d0
 r1(3) = 0.d0
 double precision :: delta,f_deriv2,f_deriv4,f_0
 delta=0.0001d0
 r12=0.d0
 call give_f_paper_alpha_beta_hf_at_r1_r12(r1,r12,accu_ana,f_0,f_deriv2,f_deriv4)
!print*,'n2_deriv2 =',n2_deriv2
!print*,'n2_deriv4 =',n2_deriv4
 do i = 1,100000 
 accu_num = 0.d0 
  do k = 1,n_points_integration_angular
   r2(1)= r1(1)+r12*angular_quadrature_points(k,1)
   r2(2)= r1(2)+r12*angular_quadrature_points(k,2)
   r2(3)= r1(3)+r12*angular_quadrature_points(k,3)
   call give_f_alpha_beta_hf_at_r1_r2(r1,r2,f_hf_alpha_beta) 
   accu_num += f_hf_alpha_beta*weights_angular_points(k)/(4.d0*pi)
  enddo

  call give_f_paper_alpha_beta_hf_at_r1_r12(r1,r12,accu_ana,f_0,f_deriv2,f_deriv4)
  write(33,*)r12,accu_num
  write(44,*)r12,accu_ana
  r12 += delta 

 !print*,'integral num   =',accu_num
 !print*,'integral ana   =',accu_ana
 enddo

 call give_f_paper_alpha_beta_hf_at_r1_r12(r1,0.d0,accu_ana,f_0,f_deriv2,f_deriv4)
 print*,"accu_ana_1                =",accu_ana
 print*,"f_0(0)                    =",f_0
 print*,"f_deriv2(0)               =",f_deriv2
 print*,"f_deriv4(0)               =",f_deriv4
 
end

 subroutine test_effective_intera_spherical_av
 implicit none
 include 'utils/constants.include.F'
 integer :: i,j,k,istate
 double precision :: accu_num,accu_ana_1,accu_ana_2
 double precision :: r1(3),r2(3)
 double precision :: r12
 double precision :: f_hf_alpha_beta,n2_hf_alpha_beta 
 print*,'\\\\\\\\\\\\\\\\\'
 print*,' '
 r1(1) = 0.0d0
 r1(2) = 0.0d0
 r1(3) = 0.d0
 double precision :: delta,n2_deriv2,n2_deriv4,f_deriv2,f_deriv4,f2_0,n2_0
 delta=0.00001d0
 r12=0.d0
 call give_f_paper_alpha_beta_hf_at_r1_r12(r1,r12,accu_ana_1,f2_0,f_deriv2,f_deriv4)

 do i = 1,10000 
 accu_num = 0.d0 
  do k = 1,n_points_integration_angular
   r2(1)= r1(1)+r12*angular_quadrature_points(k,1)
   r2(2)= r1(2)+r12*angular_quadrature_points(k,2)
   r2(3)= r1(3)+r12*angular_quadrature_points(k,3)
   call give_n2_alpha_beta_hf_at_r1_r2(r1,r2,n2_hf_alpha_beta) 
   call give_f_alpha_beta_hf_at_r1_r2(r1,r2,f_hf_alpha_beta) 
   accu_num += (f_hf_alpha_beta/n2_hf_alpha_beta)*weights_angular_points(k)/(4.d0*pi)
  enddo
  call give_f_paper_alpha_beta_hf_at_r1_r12(r1,r12,accu_ana_1,f2_0,f_deriv2,f_deriv4) 
  call give_n2_alpha_beta_hf_at_r1_r12(r1,r12,accu_ana_2,n2_0,n2_deriv2,n2_deriv4)
  write(33,*)r12,accu_num
  write(44,*)r12,accu_ana_1/accu_ana_2

  r12 += delta 
 
 enddo
 
 call give_f_paper_alpha_beta_hf_at_r1_r12(r1,0.01d0,accu_ana_1,f2_0,f_deriv2,f_deriv4)
 call give_n2_alpha_beta_hf_at_r1_r12(r1,0.01d0,accu_ana_2,n2_0,n2_deriv2,n2_deriv4)

 print*,"n2_0(0)                   =",n2_0
 print*,"n2_deriv2(0)              =",n2_deriv2
 print*,"n2_deriv4(0)              =",n2_deriv4
 print*,"accu_ana_1                =",accu_ana_1
 print*,"f_0(0)                    =",f2_0
 print*,"f_deriv2(0)               =",f_deriv2
 print*,"f_deriv4(0)               =",f_deriv4
 print*,"f_deriv4(0)/n2_deriv4(0)  =",f_deriv4/n2_deriv4
 print*,"Weff  =",accu_ana_1/accu_ana_2
end




 subroutine test_ecmd_ab_sph
 implicit none
 provide e_c_md_mur_ab_sph_av_LDA 
 print*,'****************************************'
 print*,' e_c_md_mur_ab_sph_av_LDA   =', e_c_md_mur_ab_sph_av_LDA 
 print*,' mu average ab              =', mu_average_ab_sph_av
 print*,'****************************************'
 end


!subroutine test_polynome
!implicit none
!double precision :: mu_1,mu_2,mu_3
!double precision :: r12
!double precision :: r(3)
!double precision :: local_potential,two_bod
!integer :: i_point
!r12 = 1.d-5
!do i_point = 1, n_points_final_grid
! r(1) = final_grid_points(1,i_point)
! r(2) = final_grid_points(2,i_point)
! r(3) = final_grid_points(3,i_point)
! call give_eff_inter_alpha_alpha_hf_at_r1_r12(r,r12,local_potential,two_bod)
! if(two_bod.le.1.d-12.or.local_potential.le.0.d0)then
!   local_potential = 1.d-10
! else 
!   local_potential = local_potential /  two_bod
! endif
! call give_mu_r12(local_potential,r12,mu_1,mu_2,mu_3)
! write(33,*)i_point,mu_1,mu_2,mu_3
!enddo
!end
