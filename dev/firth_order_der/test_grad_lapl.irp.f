program pouet
 read_wf = .True.
 touch read_wf
!call test_grad_lapl_ao
!call test_grad_lapl_mo
!call test_fourth_ao
!call test_fourth_ao_cross 
!call test_lapl_ao_product
!call test_nabla_4_ao_product
!call test_nabla_3_ao_product
!call test_nabla_4_ao_product_sous_parties
!call test_ao_to_mo_nabla4
!call test_int_f
!call test_int_n2
!call test_int_n
!call test_int_n2_spherical_av
!call test_nabla2_4_at_r
!call test_int_f_paper_spherical_av
<<<<<<< HEAD
 call test_effective_intera_spherical_av
=======
!call test_effective_intera_spherical_av
>>>>>>> 6eb03517d440ebe96b214102bef15902bd594b12
!call test_ecmd_alpha 
!call test_polynome
end


subroutine test_grad_lapl_mo
 implicit none
 integer :: i,j,k,l,m,n
 double precision :: r(3),rdx_plus(3),rdx_minus(3),accu(3),accu_2(3),accu_3(3)
 double precision :: grad_mos_array_bis(3,mo_num)
 double precision :: mos_array_plus(mo_num),mos_array_minus(mo_num)
 double precision :: lapl_mos_array_bis(3,mo_num),mos_lapl(3,mo_num)
 double precision :: grad_mos_array_plus(3,mo_num),grad_mos_array_minus(3,mo_num)
 double precision :: dr
 print*,'\\\\\\\\\\\\\\\\\'
 print*,' '
 print*,'Test MO'
 print*,'dr,error grad, error lapl'
 do n = 1, 16
  dr = 10d0**(-n)
  r = 0d0
  accu = 0d0
  accu_2= 0d0
  accu_3= 0d0
  do i = 1, n_points_final_grid
   r(1) = final_grid_points(1,i)
   r(2) = final_grid_points(2,i)
   r(3) = final_grid_points(3,i)
   do m = 1,3
    rdx_plus = r
    rdx_plus(m) = r(m) + dr
    rdx_minus = r
    rdx_minus(m) = r(m) - dr
    call give_all_mos_and_grad_at_r(rdx_plus,mos_array_plus,grad_mos_array_plus)
    call give_all_mos_and_grad_at_r(rdx_minus,mos_array_minus,grad_mos_array_minus)
    do j = 1, mo_num
     grad_mos_array_bis(m,j) = (mos_array_plus(j) - mos_array_minus(j))/(2.d0 * dr)
     accu(m) += dabs(grad_mos_array_bis(m,j) - mos_grad_in_r_array(j,i,m)) * final_weight_at_r_vector(i)

     lapl_mos_array_bis(m,j) = (grad_mos_array_plus(m,j) -grad_mos_array_minus(m,j))/(2.d0 * dr)
     accu_3(m) += dabs(lapl_mos_array_bis(m,j) - mos_lapl_in_r_array(j,i,m)) * final_weight_at_r_vector(i)
    enddo
   enddo
!  call give_all_mos_and_grad_and_lapl_at_r(r,mos_array_plus,grad_mos_array_plus,mos_lapl)
   call give_all_mos_and_grad_at_r(r,mos_array_plus,grad_mos_array_plus)
   do m = 1, 3
    do j = 1, mo_num
     accu_2(m) += dabs(grad_mos_array_bis(m,j) - grad_mos_array_plus(m,j)) * final_weight_at_r_vector(i)
    enddo
   enddo

  enddo
  write(*,'(5(F16.10,x))')dr,accu(1),accu_2(1),accu_3(1)
  write(33,'(100(F16.10,X))'),dr,accu(1),accu(2),accu(3),accu_2(1),accu_2(2),accu_2(3)
 enddo
end


 subroutine test_grad_lapl_ao
 implicit none
 integer :: i,j,k,l,m,n
 double precision :: r(3),rdx_plus(3),rdx_minus(3),accu(3),accu_2(3)
 double precision :: grad_aos_array_bis(3,ao_num)
 double precision :: aos_array_plus(ao_num),aos_array_minus(ao_num),aos_array(ao_num)
 double precision :: lapl_aos_array_bis(3,ao_num),aos_lapl_array(3,ao_num)
 double precision :: grad_aos_array_plus(3,ao_num),grad_aos_array_minus(3,ao_num),grad_aos_array(3,ao_num)
 double precision :: dr
 print*,'\\\\\\\\\\\\\\\\\'
 print*,' '
 print*,'Test AO'
 print*,'dr,error grad, error lapl BONJOURRRRRR'
 do n = 1, 16
  dr = 10d0**(-n)
  r = 0d0
  accu = 0d0
  accu_2= 0d0
  do i = 1, n_points_final_grid
   r(1) = final_grid_points(1,i)
   r(2) = final_grid_points(2,i)
   r(3) = final_grid_points(3,i)
   do m = 1,3
    rdx_plus = r
    rdx_plus(m) = r(m) + dr
    rdx_minus = r
    rdx_minus(m) = r(m) - dr
    call give_all_aos_and_grad_at_r(rdx_plus,aos_array_plus,grad_aos_array_plus)
    call give_all_aos_and_grad_at_r(rdx_minus,aos_array_minus,grad_aos_array_minus)
    call give_all_aos_and_grad_and_lapl_at_r(r,aos_array,grad_aos_array,aos_lapl_array)
    do j = 1, ao_num
     grad_aos_array_bis(m,j) = (aos_array_plus(j) - aos_array_minus(j))/(2.d0 *dr)
     accu(m) += dabs(grad_aos_array_bis(m,j) - aos_grad_in_r_array(j,i,m)) * final_weight_at_r_vector(i)

     lapl_aos_array_bis(m,j) = (aos_array_plus(j) + aos_array_minus(j)-2d0*aos_array(j))/(dr**2)
     accu_2(m) += dabs(lapl_aos_array_bis(m,j) -aos_lapl_array(m,j)) * final_weight_at_r_vector(i)
    enddo
   enddo
  enddo
  print*,dr,accu(1),accu_2(1)
  write(33,'(100(F16.10,X))'),dr,accu(1),accu(2),accu(3),accu_2(1),accu_2(2),accu_2(3)
 enddo
end



subroutine test_fourth_ao
 implicit none
 integer :: i,j,k,l,m,n
 double precision :: r(3),rdx_plus(3),rdx_minus(3),accu(3),accu_2(3),accu_3(3),accu_4(3)
 double precision :: grad_aos_array_bis(3,ao_num)
 double precision :: aos_array_plus(ao_num),aos_array_minus(ao_num)
 double precision :: lapl_aos_array_bis(3,ao_num),aos_3rd_alpha_bis(3,ao_num),aos_4th_alpha_bis(3,ao_num)
 double precision :: grad_aos_array_plus(3,ao_num),grad_aos_array_minus(3,ao_num),aos_3rd_alpha_array_minus(3,ao_num),aos_4th_alpha_array_minus(3,ao_num)
 double precision :: aos_lapl_array_plus(3,ao_num),aos_lapl_array_minus(3,ao_num),aos_3rd_alpha_array_plus(3,ao_num),aos_4th_alpha_array_plus(3,ao_num)
 double precision :: dr
 double precision :: aos_array(3,ao_num),aos_grad_array(3,ao_num),aos_lapl_array(3,ao_num),aos_3rd_alpha_array(3,ao_num),aos_4th_alpha_array(3,ao_num)
 print*,'\\\\\\\\\\\\\\\\\'
 print*,' '
 print*,'Test AO AAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
 print*,'dr,error grad, error lapl'
 do n = 1, 16
  dr = 10d0**(-n)
  r = 0d0
  accu = 0d0
  accu_2= 0d0
  accu_3= 0d0
  accu_4= 0d0
  do i = 1, n_points_final_grid
   r(1) = final_grid_points(1,i)
   r(2) = final_grid_points(2,i)
   r(3) = final_grid_points(3,i)
   do m = 1,3
    rdx_plus = r
    rdx_plus(m) = r(m) + dr
    rdx_minus = r
    rdx_minus(m) = r(m) - dr
!   call give_all_aos_and_grad_and_lapl_at_r(rdx_plus,aos_array_plus,grad_aos_array_plus,aos_lapl_array_plus)
!   call give_all_aos_and_grad_and_lapl_at_r(rdx_minus,aos_array_minus,grad_aos_array_minus,aos_lapl_array_minus)

    call give_all_aos_and_fourth_at_r(rdx_plus,aos_array_plus,grad_aos_array_plus,aos_lapl_array_plus,aos_3rd_alpha_array_plus,aos_4th_alpha_array_plus)
    call give_all_aos_and_fourth_at_r(rdx_minus,aos_array_minus,grad_aos_array_minus,aos_lapl_array_minus,aos_3rd_alpha_array_minus,aos_4th_alpha_array_minus)

    call  give_all_aos_and_fourth_at_r(r,aos_array,aos_grad_array,aos_lapl_array,aos_3rd_alpha_array,aos_4th_alpha_array)

    do j = 1, ao_num
     grad_aos_array_bis(m,j) = (aos_array_plus(j) - aos_array_minus(j))/(2.d0 *dr)
     accu(m) += dabs(grad_aos_array_bis(m,j) - aos_grad_array(m,j)) * final_weight_at_r_vector(i)

     lapl_aos_array_bis(m,j) = (grad_aos_array_plus(m,j) - grad_aos_array_minus(m,j))/(2.d0 * dr)
     accu_2(m) += dabs(lapl_aos_array_bis(m,j) - aos_lapl_array(m,j)) * final_weight_at_r_vector(i)
    
     aos_3rd_alpha_bis(m,j) = (aos_lapl_array_plus(m,j) - aos_lapl_array_minus(m,j))/(2.d0 * dr)
     accu_3(m) += dabs(aos_3rd_alpha_bis(m,j) - aos_3rd_alpha_array(m,j)) * final_weight_at_r_vector(i)

     aos_4th_alpha_bis(m,j) = (aos_3rd_alpha_array_plus(m,j) - aos_3rd_alpha_array_minus(m,j))/(2.d0 * dr)
     accu_4(m) += dabs(aos_4th_alpha_bis(m,j) - aos_4th_alpha_array(m,j)) * final_weight_at_r_vector(i)
   
    enddo
   enddo
  enddo
  print*,dr,accu(1),accu_2(1),accu_3(1),accu_4(1)
  
  write(22,'(100(F16.10,X))'),dr,accu(1),accu(2),accu(3)
  write(33,'(100(F16.10,X))'),dr,accu_2(1),accu_2(2),accu_2(3)
  write(44,'(100(F16.10,X))'),dr,accu_3(1),accu_3(2),accu_3(3)
  write(55,'(100(F16.10,X))'),dr,accu_4(1),accu_4(2),accu_4(3)
 enddo
end



subroutine test_fourth_ao_cross
 implicit none
 integer :: i,j,k,l,m,n
 double precision :: r(3),rdx_plus(3),rdx_minus(3),rdy_plus(3),rdy_minus(3),rdz_plus(3),rdz_minus(3),accu(3),accu_2(3),accu_3(6),accu_4(3)
 double precision :: grad_aos_array_bis(3,ao_num)
 double precision :: aos_array_plus(ao_num),aos_array_minus(ao_num)
 double precision :: lapl_aos_array_bis(3,ao_num),aos_3rd_cross_bis(6,ao_num),aos_4th_alpha_bis(3,ao_num)
 double precision :: grad_aos_array_plus_y(3,ao_num),grad_aos_array_minus_y(3,ao_num),aos_3rd_alpha_array_minus_y(6,ao_num),aos_4th_alpha_array_minus_y(3,ao_num)
 double precision :: aos_lapl_array_plus_y(3,ao_num),aos_lapl_array_minus_y(3,ao_num),aos_3rd_alpha_array_plus_y(6,ao_num),aos_4th_alpha_array_plus_y(3,ao_num)


 double precision :: aos_array_plus_x(3,ao_num),aos_array_plus_y(3,ao_num),aos_array_plus_z(3,ao_num)
 double precision :: aos_array_minus_x(3,ao_num),aos_array_minus_y(3,ao_num),aos_array_minus_z(3,ao_num)
 double precision :: grad_aos_array_plus_x(3,ao_num),grad_aos_array_minus_x(3,ao_num),aos_3rd_alpha_array_minus_x(6,ao_num),aos_4th_alpha_array_minus_x(3,ao_num)
 double precision :: aos_lapl_array_plus_x(3,ao_num),aos_lapl_array_minus_x(3,ao_num),aos_3rd_alpha_array_plus_x(6,ao_num),aos_4th_alpha_array_plus_x(3,ao_num)
 double precision :: grad_aos_array_plus_z_2(3,ao_num),grad_aos_array_minus_z_2(3,ao_num)
 double precision :: grad_aos_array_plus_y_2(3,ao_num),grad_aos_array_minus_y_2(3,ao_num)
 double precision :: grad_aos_array_plus_x_2(3,ao_num),grad_aos_array_minus_x_2(3,ao_num)
 double precision :: aos_lapl_array_plus_z_2(3,ao_num),aos_lapl_array_minus_z_2(3,ao_num)
 double precision :: aos_lapl_array_plus_y_2(3,ao_num),aos_lapl_array_minus_y_2(3,ao_num)
 double precision :: aos_lapl_array_plus_x_2(3,ao_num),aos_lapl_array_minus_x_2(3,ao_num)


 double precision :: grad_aos_array_plus_z(3,ao_num),grad_aos_array_minus_z(3,ao_num),aos_3rd_alpha_array_minus_z(6,ao_num),aos_4th_alpha_array_minus_z(3,ao_num)
 double precision :: aos_lapl_array_plus_z(3,ao_num),aos_lapl_array_minus_z(3,ao_num),aos_3rd_alpha_array_plus_z(6,ao_num),aos_4th_alpha_array_plus_z(3,ao_num)

 double precision :: dr
 double precision :: aos_array(3,ao_num),aos_grad_array(3,ao_num),aos_lapl_array(3,ao_num),aos_3rd_cross_array(6,ao_num),aos_4th_cross_array(3,ao_num)
 print*,'\\\\\\\\\\\\\\\\\'
 print*,' '
 print*,'Test AO AAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
 print*,'dr,error grad, error lapl'
 do n = 1, 16
  dr = 10d0**(-n)
  r = 0d0
  accu = 0d0
  accu_2= 0d0
  accu_3= 0d0
  accu_4= 0d0
  do i = 1, n_points_final_grid
   r(1) = final_grid_points(1,i)
   r(2) = final_grid_points(2,i)
   r(3) = final_grid_points(3,i)
   rdx_plus = r
   rdx_plus(1) = r(1) + dr
   rdx_minus = r
   rdx_minus(1) = r(1) - dr

   rdy_plus = r
   rdy_plus(2) = r(2) + dr
   rdy_minus = r
   rdy_minus(2) = r(2) - dr


   rdz_plus = r
   rdz_plus(3) = r(3) + dr
   rdz_minus = r
   rdz_minus(3) = r(3) - dr

   call give_all_aos_and_grad_and_lapl_at_r(rdx_plus,aos_array_plus_x,grad_aos_array_plus_x,aos_lapl_array_plus_x)
   call give_all_aos_and_grad_and_lapl_at_r(rdx_minus,aos_array_minus_x,grad_aos_array_minus_x,aos_lapl_array_minus_x)

   call give_all_aos_and_grad_and_lapl_at_r(rdy_plus,aos_array_plus_y,grad_aos_array_plus_y,aos_lapl_array_plus_y)
   call give_all_aos_and_grad_and_lapl_at_r(rdy_minus,aos_array_minus_y,grad_aos_array_minus_y,aos_lapl_array_minus_y)

   call give_all_aos_and_grad_and_lapl_at_r(rdz_plus,aos_array_plus_z,grad_aos_array_plus_z,aos_lapl_array_plus_z)
   call give_all_aos_and_grad_and_lapl_at_r(rdz_minus,aos_array_minus_z,grad_aos_array_minus_z,aos_lapl_array_minus_z)

   call give_all_aos_and_fourth_order_cross_terms_at_r(rdx_plus,aos_array_plus_x,grad_aos_array_plus_x_2,aos_lapl_array_plus_x_2,aos_3rd_alpha_array_plus_x,aos_4th_alpha_array_plus_x)
   call give_all_aos_and_fourth_order_cross_terms_at_r(rdx_minus,aos_array_minus_x,grad_aos_array_minus_x_2,aos_lapl_array_minus_x_2,aos_3rd_alpha_array_minus_x,aos_4th_alpha_array_minus_x)

   call give_all_aos_and_fourth_order_cross_terms_at_r(rdy_plus,aos_array_plus_y,grad_aos_array_plus_y_2,aos_lapl_array_plus_y_2,aos_3rd_alpha_array_plus_y,aos_4th_alpha_array_plus_y)
   call give_all_aos_and_fourth_order_cross_terms_at_r(rdy_minus,aos_array_minus_y,grad_aos_array_minus_y_2,aos_lapl_array_minus_y_2,aos_3rd_alpha_array_minus_y,aos_4th_alpha_array_minus_y)

   call give_all_aos_and_fourth_order_cross_terms_at_r(rdz_plus,aos_array_plus_z,grad_aos_array_plus_z_2,aos_lapl_array_plus_z_2,aos_3rd_alpha_array_plus_z,aos_4th_alpha_array_plus_z)
   call give_all_aos_and_fourth_order_cross_terms_at_r(rdz_minus,aos_array_minus_z,grad_aos_array_minus_z_2,aos_lapl_array_minus_z_2,aos_3rd_alpha_array_minus_z,aos_4th_alpha_array_minus_z)




   call give_all_aos_and_fourth_order_cross_terms_at_r(r,aos_array,aos_grad_array,aos_lapl_array,aos_3rd_cross_array,aos_4th_cross_array) 

   do j = 1, ao_num

    lapl_aos_array_bis(1,j) = (grad_aos_array_plus_x(2,j) - grad_aos_array_minus_x(2,j))/(2.d0 * dr)
    accu_2(1) += dabs(lapl_aos_array_bis(1,j) - aos_lapl_array(1,j)) * final_weight_at_r_vector(i)

    lapl_aos_array_bis(2,j) = (grad_aos_array_plus_y(3,j) -grad_aos_array_minus_y(3,j))/(2.d0 * dr)
    accu_2(2) += dabs(lapl_aos_array_bis(2,j) - aos_lapl_array(2,j)) *final_weight_at_r_vector(i)

    lapl_aos_array_bis(3,j) = (grad_aos_array_plus_x(3,j) -grad_aos_array_minus_x(3,j))/(2.d0 * dr)
    accu_2(3) += dabs(lapl_aos_array_bis(3,j) - aos_lapl_array(3,j)) *final_weight_at_r_vector(i)
   
    aos_3rd_cross_bis(1,j) = (aos_lapl_array_plus_y(1,j) - aos_lapl_array_minus_y(1,j))/(2.d0 * dr)
    accu_3(1) += dabs(aos_3rd_cross_bis(1,j) - aos_3rd_cross_array(1,j)) * final_weight_at_r_vector(i)

    aos_3rd_cross_bis(2,j) = (aos_lapl_array_plus_z(2,j) - aos_lapl_array_minus_z(2,j))/(2.d0 * dr)
    accu_3(2) += dabs(aos_3rd_cross_bis(2,j) - aos_3rd_cross_array(2,j)) *final_weight_at_r_vector(i)

    aos_3rd_cross_bis(3,j) = (aos_lapl_array_plus_x(3,j) - aos_lapl_array_minus_x(3,j))/(2.d0 * dr)
    accu_3(3) += dabs(aos_3rd_cross_bis(3,j) - aos_3rd_cross_array(3,j)) * final_weight_at_r_vector(i)

    aos_3rd_cross_bis(4,j) = (aos_lapl_array_plus_x(2,j) - aos_lapl_array_minus_x(2,j))/(2.d0 * dr) 
    accu_3(4) += dabs(aos_3rd_cross_bis(4,j) - aos_3rd_cross_array(4,j)) * final_weight_at_r_vector(i)
   
    aos_3rd_cross_bis(5,j) = (aos_lapl_array_plus_y(3,j) - aos_lapl_array_minus_y(3,j))/(2.d0 * dr)
    accu_3(5) += dabs(aos_3rd_cross_bis(5,j) - aos_3rd_cross_array(5,j)) * final_weight_at_r_vector(i)

    aos_3rd_cross_bis(6,j) = (aos_lapl_array_plus_z(1,j) - aos_lapl_array_minus_z(1,j))/(2.d0 * dr) 
    accu_3(6) += dabs(aos_3rd_cross_bis(6,j) - aos_3rd_cross_array(6,j)) * final_weight_at_r_vector(i)


    aos_4th_alpha_bis(1,j) = (aos_3rd_alpha_array_plus_y(1,j) - aos_3rd_alpha_array_minus_y(1,j))/(2.d0 * dr)
    accu_4(1) += dabs(aos_4th_alpha_bis(1,j) - aos_4th_cross_array(1,j)) * final_weight_at_r_vector(i)
   
    aos_4th_alpha_bis(2,j) = (aos_3rd_alpha_array_plus_z(2,j) - aos_3rd_alpha_array_minus_z(2,j))/(2.d0 * dr)
    accu_4(2) += dabs(aos_4th_alpha_bis(2,j) - aos_4th_cross_array(2,j)) * final_weight_at_r_vector(i)

    aos_4th_alpha_bis(3,j) = (aos_3rd_alpha_array_plus_x(3,j) - aos_3rd_alpha_array_minus_x(3,j))/(2.d0 * dr)
    accu_4(3) += dabs(aos_4th_alpha_bis(3,j) - aos_4th_cross_array(3,j)) * final_weight_at_r_vector(i)

   enddo
  enddo
  print*,dr,accu_2(1),accu_3(1),accu_4(1)
  
  !write(22,'(100(F16.10,X))'),dr,accu(1),accu(2),accu(3)
  write(33,'(100(F16.10,X))'),dr,accu_2(1),accu_2(2),accu_2(3)
  write(44,'(100(F16.10,X))'),dr,accu_3(1),accu_3(2),accu_3(3),accu_3(4),accu_3(5),accu_3(6)
  write(55,'(100(F16.10,X))'),dr,accu_4(1),accu_4(2),accu_4(3)
 enddo
end



 subroutine test_lapl_ao_product
 implicit none
 integer :: i,j,k,l,m,n
 double precision :: r(3),rdx_plus(3),rdx_minus(3),accu(3)
 double precision :: accu_2,lapl_num_tot
 double precision :: grad_aos_array_bis(3,ao_num)
 double precision :: aos_array(ao_num),aos_array_plus(ao_num),aos_array_minus(ao_num)
 double precision :: lapl_aos_product_array_bis(3,ao_num,ao_num)
 double precision :: grad_aos_array_plus(3,ao_num),grad_aos_array_minus(3,ao_num),grad_aos_array(3,ao_num)
 double precision :: dr
 double precision :: nabla_2_at_r(3,ao_num,ao_num)
 double precision :: nabla_2_tot_at_r(ao_num,ao_num)
 print*,'\\\\\\\\\\\\\\\\\'
 print*,' '
 print*,'Test AO'
 print*,'dr,error grad, error lapl'
 do n = 1, 16
  dr = 10d0**(-n)
  r = 0d0
  accu = 0d0
  accu_2 = 0d0
  do i = 1, n_points_final_grid
   r(1) = final_grid_points(1,i)
   r(2) = final_grid_points(2,i)
   r(3) = final_grid_points(3,i)
   do m = 1,3
    rdx_plus = r
    rdx_plus(m) = r(m) + dr
    rdx_minus = r
    rdx_minus(m) = r(m) - dr


    !!!!! For Nabla 2

    call give_all_aos_and_grad_at_r(r,aos_array,grad_aos_array)

    call give_all_aos_and_grad_at_r(rdx_plus,aos_array_plus,grad_aos_array_plus)
    call give_all_aos_and_grad_at_r(rdx_minus,aos_array_minus,grad_aos_array_minus)

    call give_nabla_2_at_r(r,nabla_2_at_r,nabla_2_tot_at_r)


    do k = 1, ao_num 
     do j = 1, ao_num
      lapl_aos_product_array_bis(m,k,j) = (aos_array_plus(k)*aos_array_plus(j)+aos_array_minus(k)*aos_array_minus(j)-2d0*aos_array(k)*aos_array(j) )/(dr**2)
      accu(m) += dabs(lapl_aos_product_array_bis(m,k,j) - nabla_2_at_r(m,k,j) ) * final_weight_at_r_vector(i)
     enddo
    enddo
   enddo

   do k = 1, ao_num
    do j = 1, ao_num
     lapl_num_tot = lapl_aos_product_array_bis(1,k,j)+ lapl_aos_product_array_bis(2,k,j) + lapl_aos_product_array_bis(3,k,j) 
     accu_2 += dabs(lapl_num_tot - nabla_2_tot_at_r(k,j) ) * final_weight_at_r_vector(i)
    enddo
   enddo


  enddo
  print*,dr,accu(1),accu_2
  write(33,'(100(F16.10,X))'),dr,accu(1),accu(2),accu(3)
 enddo
end



 subroutine test_nabla_4_ao_product
 implicit none
 integer :: i,j,k,l,m,n
 double precision :: r(3),rdx_plus(3),rdx_minus(3)
 double precision :: accu
 double precision :: nabla4numeric(3,ao_num,ao_num)
 double precision :: dr
 double precision :: nabla_2_at_r(3,ao_num,ao_num)
 double precision :: nabla_2_tot_at_r(ao_num,ao_num),nabla_2_tot_at_r_plus(ao_num,ao_num),nabla_2_tot_at_r_minus(ao_num,ao_num)
 double precision :: nabla4numeric_tot
 double precision :: nabla_4_at_r(ao_num,ao_num) 
 print*,'\\\\\\\\\\\\\\\\\'
 print*,' '
 print*,'Test AO'
 print*,'dr,error grad, error lapl'
 do n = 1, 16
  dr = 10d0**(-n)
  r = 0d0
  accu = 0d0
  do i = 1, n_points_final_grid
   r(1) = final_grid_points(1,i)
   r(2) = final_grid_points(2,i)
   r(3) = final_grid_points(3,i)
   do m = 1,3
    rdx_plus = r
    rdx_plus(m) = r(m) + dr
    rdx_minus = r
    rdx_minus(m) = r(m) - dr

    !!!!! For Nabla 2

    call give_nabla_2_at_r(rdx_plus,nabla_2_at_r,nabla_2_tot_at_r_plus)
    call give_nabla_2_at_r(rdx_minus,nabla_2_at_r,nabla_2_tot_at_r_minus)
    call give_nabla_2_at_r(r,nabla_2_at_r,nabla_2_tot_at_r)

    do k = 1, ao_num 
     do j = 1, ao_num
    
      nabla4numeric(m,j,k) = (nabla_2_tot_at_r_plus(j,k)+nabla_2_tot_at_r_minus(j,k)-2d0*nabla_2_tot_at_r(j,k))/(dr*dr)

     enddo
    enddo
   enddo
   
   call give_nabla_4_at_r(r,nabla_4_at_r) 

   do k = 1, ao_num 
    do j = 1, ao_num
     nabla4numeric_tot = nabla4numeric(1,j,k) + nabla4numeric(2,j,k) + nabla4numeric(3,j,k)
     accu += dabs(nabla4numeric_tot - nabla_4_at_r(j,k) )*final_weight_at_r_vector(i)
    enddo
   enddo

  enddo
  print*,dr,accu
 enddo
end


 subroutine test_nabla_3_ao_product
 implicit none
 integer :: i,j,k,l,m,n
 double precision :: r(3),rdx_plus(3),rdx_minus(3),rdy_plus(3),rdy_minus(3),rdz_plus(3),rdz_minus(3)
 double precision :: accu(6),accu_2(3)
 double precision :: nabla3numeric(9,ao_num,ao_num)
 double precision :: dr
 double precision :: nabla_2_at_r(3,ao_num,ao_num),nabla_2_at_r_plus_x(3,ao_num,ao_num),nabla_2_at_r_minus_x(3,ao_num,ao_num)
 double precision :: nabla_2_at_r_plus_y(3,ao_num,ao_num),nabla_2_at_r_minus_y(3,ao_num,ao_num),nabla_2_at_r_plus_z(3,ao_num,ao_num),nabla_2_at_r_minus_z(3,ao_num,ao_num)
 double precision :: nabla_2_tot_at_r(ao_num,ao_num),nabla_2_tot_at_r_plus(ao_num,ao_num),nabla_2_tot_at_r_minus(ao_num,ao_num)
 double precision :: nabla_3_at_r(9,ao_num,ao_num)
 
 print*,'\\\\\\\\\\\\\\\\\'
 print*,' '
 print*,'Test AO'
 print*,'dr,error grad, error lapl'
 do n = 1, 16
  dr = 10d0**(-n)
  r = 0d0
  accu = 0d0
  accu_2 = 0d0
  do i = 1, n_points_final_grid
   r(1) = final_grid_points(1,i)
   r(2) = final_grid_points(2,i)
   r(3) = final_grid_points(3,i)
   rdx_plus = r
   rdx_plus(1) = r(1) + dr
   rdx_minus = r
   rdx_minus(1) = r(1) - dr

   rdy_plus = r
   rdy_plus(2) = r(2) + dr
   rdy_minus = r
   rdy_minus(2) = r(2) - dr


   rdz_plus = r
   rdz_plus(3) = r(3) + dr
   rdz_minus = r
   rdz_minus(3) = r(3) - dr
   !!!!! For Nabla 2

   call give_nabla_2_at_r(rdx_plus,nabla_2_at_r_plus_x,nabla_2_tot_at_r_plus)
   call give_nabla_2_at_r(rdx_minus,nabla_2_at_r_minus_x,nabla_2_tot_at_r_minus)

   call give_nabla_2_at_r(rdy_plus,nabla_2_at_r_plus_y,nabla_2_tot_at_r_plus)
   call give_nabla_2_at_r(rdy_minus,nabla_2_at_r_minus_y,nabla_2_tot_at_r_minus)
  
   call give_nabla_2_at_r(rdz_plus,nabla_2_at_r_plus_z,nabla_2_tot_at_r_plus)
   call give_nabla_2_at_r(rdz_minus,nabla_2_at_r_minus_z,nabla_2_tot_at_r_minus)

   call give_nabla_3_at_r(r,nabla_3_at_r) 

   do k = 1, ao_num 
    do j = 1, ao_num
   
     nabla3numeric(1,j,k) = (nabla_2_at_r_plus_y(1,j,k)-nabla_2_at_r_minus_y(1,j,k))/(2.d0*dr)
     accu(1) += dabs(nabla3numeric(1,j,k) - nabla_3_at_r(1,j,k) )*final_weight_at_r_vector(i) 

     nabla3numeric(2,j,k) = (nabla_2_at_r_plus_z(2,j,k)-nabla_2_at_r_minus_z(2,j,k))/(2.d0*dr)
     accu(2) += dabs(nabla3numeric(2,j,k) - nabla_3_at_r(2,j,k) )*final_weight_at_r_vector(i)

     nabla3numeric(3,j,k) = (nabla_2_at_r_plus_x(3,j,k)-nabla_2_at_r_minus_x(3,j,k))/(2.d0*dr)
     accu(3) += dabs(nabla3numeric(3,j,k) - nabla_3_at_r(3,j,k) )*final_weight_at_r_vector(i)

     nabla3numeric(4,j,k) = (nabla_2_at_r_plus_x(2,j,k)-nabla_2_at_r_minus_x(2,j,k))/(2.d0*dr)
     accu(4) += dabs(nabla3numeric(4,j,k) - nabla_3_at_r(4,j,k) )*final_weight_at_r_vector(i) 

     nabla3numeric(5,j,k) = (nabla_2_at_r_plus_y(3,j,k)-nabla_2_at_r_minus_y(3,j,k))/(2.d0*dr)
     accu(5) += dabs(nabla3numeric(5,j,k) - nabla_3_at_r(5,j,k) )*final_weight_at_r_vector(i)

     nabla3numeric(6,j,k) = (nabla_2_at_r_plus_z(1,j,k)-nabla_2_at_r_minus_z(1,j,k))/(2.d0*dr)
     accu(6) += dabs(nabla3numeric(6,j,k) - nabla_3_at_r(6,j,k) )*final_weight_at_r_vector(i)

     nabla3numeric(7,j,k) = (nabla_2_at_r_plus_x(1,j,k)-nabla_2_at_r_minus_x(1,j,k))/(2.d0*dr)
     accu_2(1) += dabs(nabla3numeric(7,j,k) - nabla_3_at_r(7,j,k))*final_weight_at_r_vector(i)

     nabla3numeric(8,j,k) = (nabla_2_at_r_plus_y(2,j,k)-nabla_2_at_r_minus_y(2,j,k))/(2.d0*dr)
     accu_2(2) += dabs(nabla3numeric(8,j,k) - nabla_3_at_r(8,j,k))*final_weight_at_r_vector(i)

     nabla3numeric(9,j,k) = (nabla_2_at_r_plus_z(3,j,k)-nabla_2_at_r_minus_z(3,j,k))/(2.d0*dr)
     accu_2(3) += dabs(nabla3numeric(9,j,k) - nabla_3_at_r(9,j,k))*final_weight_at_r_vector(i)

    enddo
   enddo
   
  enddo
  print*,dr,accu(1),accu_2(1)
  write(33,'(100(F16.10,X))'),dr,accu(1),accu(2),accu(3),accu(4),accu(5),accu(6)
  write(44,'(100(F16.10,X))'),dr,accu_2(1),accu_2(2),accu_2(3)
 enddo
end


 subroutine test_nabla_4_ao_product_sous_parties 
 implicit none
 integer :: i,j,k,l,m,n
 double precision :: r(3),rdx_plus(3),rdx_minus(3),rdy_plus(3),rdy_minus(3),rdz_plus(3),rdz_minus(3)
 double precision :: accu(6),accu_2(3)
 double precision :: nabla3numeric(9,ao_num,ao_num)
 double precision :: dr
 double precision :: nabla_3_at_r_plus_x(9,ao_num,ao_num),nabla_3_at_r_minus_x(9,ao_num,ao_num)
 double precision :: nabla_3_at_r_plus_y(9,ao_num,ao_num),nabla_3_at_r_minus_y(9,ao_num,ao_num),nabla_3_at_r_plus_z(9,ao_num,ao_num),nabla_3_at_r_minus_z(9,ao_num,ao_num)
 double precision :: nabla_4_at_r_contrib(6,ao_num,ao_num)
 
 print*,'\\\\\\\\\\\\\\\\\'
 print*,' '
 print*,'Test AO'
 print*,'dr,error grad, error lapl'
 do n = 1, 16
  dr = 10d0**(-n)
  r = 0d0
  accu = 0d0
  accu_2 = 0d0
  do i = 1, n_points_final_grid
   r(1) = final_grid_points(1,i)
   r(2) = final_grid_points(2,i)
   r(3) = final_grid_points(3,i)
   rdx_plus = r
   rdx_plus(1) = r(1) + dr
   rdx_minus = r
   rdx_minus(1) = r(1) - dr

   rdy_plus = r
   rdy_plus(2) = r(2) + dr
   rdy_minus = r
   rdy_minus(2) = r(2) - dr


   rdz_plus = r
   rdz_plus(3) = r(3) + dr
   rdz_minus = r
   rdz_minus(3) = r(3) - dr
   !!!!! For Nabla 2

   call give_nabla_3_at_r(rdx_plus,nabla_3_at_r_plus_x)
   call give_nabla_3_at_r(rdx_minus,nabla_3_at_r_minus_x)

   call give_nabla_3_at_r(rdy_plus,nabla_3_at_r_plus_y)
   call give_nabla_3_at_r(rdy_minus,nabla_3_at_r_minus_y)
  
   call give_nabla_3_at_r(rdz_plus,nabla_3_at_r_plus_z)
   call give_nabla_3_at_r(rdz_minus,nabla_3_at_r_minus_z)

   call give_nabla_4_at_contributions(r,nabla_4_at_r_contrib)


   do k = 1, ao_num 
    do j = 1, ao_num
   
     nabla3numeric(1,j,k) = (nabla_3_at_r_plus_y(1,j,k)-nabla_3_at_r_minus_y(1,j,k))/(2.d0*dr)
     accu(1) += dabs(nabla3numeric(1,j,k) - nabla_4_at_r_contrib(1,j,k) )*final_weight_at_r_vector(i) 

     nabla3numeric(2,j,k) = (nabla_3_at_r_plus_z(2,j,k)-nabla_3_at_r_minus_z(2,j,k))/(2.d0*dr)
     accu(2) += dabs(nabla3numeric(2,j,k) - nabla_4_at_r_contrib(2,j,k) )*final_weight_at_r_vector(i)

     nabla3numeric(3,j,k) = (nabla_3_at_r_plus_x(3,j,k)-nabla_3_at_r_minus_x(3,j,k))/(2.d0*dr)
     accu(3) += dabs(nabla3numeric(3,j,k) - nabla_4_at_r_contrib(3,j,k) )*final_weight_at_r_vector(i)

     nabla3numeric(4,j,k) = (nabla_3_at_r_plus_x(2,j,k)-nabla_3_at_r_minus_x(2,j,k))/(2.d0*dr)
     accu(4) += dabs(nabla3numeric(4,j,k) - nabla_4_at_r_contrib(1,j,k) )*final_weight_at_r_vector(i) 

     nabla3numeric(5,j,k) = (nabla_3_at_r_plus_y(3,j,k)-nabla_3_at_r_minus_y(3,j,k))/(2.d0*dr)
     accu(5) += dabs(nabla3numeric(5,j,k) - nabla_4_at_r_contrib(2,j,k) )*final_weight_at_r_vector(i)

     nabla3numeric(6,j,k) = (nabla_3_at_r_plus_z(1,j,k)-nabla_3_at_r_minus_z(1,j,k))/(2.d0*dr)
     accu(6) += dabs(nabla3numeric(6,j,k) - nabla_4_at_r_contrib(3,j,k) )*final_weight_at_r_vector(i)

     nabla3numeric(7,j,k) = (nabla_3_at_r_plus_x(7,j,k)-nabla_3_at_r_minus_x(7,j,k))/(2.d0*dr)
     accu_2(1) += dabs(nabla3numeric(7,j,k) - nabla_4_at_r_contrib(4,j,k) )*final_weight_at_r_vector(i)
     
     nabla3numeric(8,j,k) = (nabla_3_at_r_plus_y(8,j,k)-nabla_3_at_r_minus_y(8,j,k))/(2.d0*dr)
     accu_2(2) += dabs(nabla3numeric(8,j,k) - nabla_4_at_r_contrib(5,j,k) )*final_weight_at_r_vector(i)

     nabla3numeric(9,j,k) = (nabla_3_at_r_plus_z(9,j,k)-nabla_3_at_r_minus_z(9,j,k))/(2.d0*dr)
     accu_2(3) += dabs(nabla3numeric(9,j,k) - nabla_4_at_r_contrib(6,j,k) )*final_weight_at_r_vector(i)

    enddo
   enddo
   
  enddo
  print*,dr,accu(1),accu_2(1)
  write(33,'(100(F20.10,X))'),dr,accu(1),accu(2),accu(3),accu(4),accu(5),accu(6)
  write(44,'(100(F20.10,X))'),dr,accu_2(1),accu_2(2),accu_2(3)
 enddo
end



 subroutine test_ao_to_mo_nabla4
 implicit none
 integer :: i,j,r
 double precision :: accu 
 
 print*,'\\\\\\\\\\\\\\\\\'
 print*,' '
 print*,'Bonjour'
  do r = 1, n_points_final_grid
   do i = 1, mo_num
    do j = 1, mo_num
    accu += (mos_nabla_4_in_r_array(j,i,r)-mos_nabla_4_in_r_array_2(j,i,r))*final_weight_at_r_vector(r) 
    enddo
   enddo
  enddo
  print*,'error   = ',accu
end


 subroutine test_nabla2_4_at_r
 implicit none
 integer :: i,j,k,istate
 double precision :: accu_num_2,accu_num_4
 double precision :: r(3)
 double precision :: nabla_2_at_r_mo(mo_num,mo_num),nabla_4_at_r_mo(mo_num,mo_num) 
 accu_num_2 = 0.d0 
 accu_num_4 = 0.d0
 print*,'\\\\\\\\\\\\\\\\\'
 print*,' '
 do k = 1,n_points_final_grid
  r(1)= final_grid_points(1,k) 
  r(2)= final_grid_points(2,k) 
  r(3)= final_grid_points(3,k)
! call give_nabla_2_at_r_mo(r,nabla_2_at_r_mo)
  call give_nabla_4_at_r_mo(r,nabla_4_at_r_mo)

  do j = 1, mo_num
   do i = 1, mo_num
!   accu_num_2 += nabla_2_at_r_mo(i,j)-mos_nabla_2_in_r_array(i,j,k) 
    accu_num_4 += nabla_4_at_r_mo(i,j)-mos_nabla_4_in_r_array(i,j,k)
   enddo
  enddo
 enddo

!print*,'error n2  =',accu_num_2
 print*,'error n4  =',accu_num_4
end

 subroutine test_int_f
 implicit none
 integer :: i
 double precision :: r(3)
 double precision :: f_hf_alpha_alpha
 double precision :: accu 
 accu = 0.d0 
 print*,'\\\\\\\\\\\\\\\\\'
 print*,' '
 do i = 1, n_points_final_grid
  r(1) = final_grid_points(1,i)
  r(2) = final_grid_points(2,i)
  r(3) = final_grid_points(3,i)
  call give_f_alpha_alpha_hf_at_r(r,f_hf_alpha_alpha)
  accu += f_hf_alpha_alpha*final_weight_at_r_vector(i) 
 enddo
 print*,'integral f             =',accu
 print*,'HF_two_electron_energy =',HF_two_electron_energy
 print*,"Error                  =",accu-HF_two_electron_energy 
end


 subroutine test_int_n2
 implicit none
 integer :: i,j
 double precision :: r(3)
 double precision :: n2_hf_alpha_alpha
 double precision :: accu 
 accu = 0.d0 
 print*,'\\\\\\\\\\\\\\\\\'
 print*,' '
 do i = 1, n_points_final_grid
  r(1) = final_grid_points(1,i)
  r(2) = final_grid_points(2,i)
  r(3) = final_grid_points(3,i)
  call give_n2_alpha_alpha_hf_at_r(r,n2_hf_alpha_alpha) 
  accu += n2_hf_alpha_alpha*final_weight_at_r_vector(i)
 enddo
 print*,'integral n2            =',accu
end




 subroutine test_int_n
 implicit none
 include 'utils/constants.include.F'
 integer :: i,j,k,istate
 double precision :: accu_dr3,accu_dr,dm_a,dm_b
 double precision :: r(3)
 accu_dr3 = 0.d0 
 accu_dr =0.d0
 print*,'\\\\\\\\\\\\\\\\\'
 print*,' '
!!!!!! Bonjour la grille
 integer :: n_points_radial_grid_local
 n_points_radial_grid_local =1250
 double precision :: dr_radial_integral_local 
 double precision,allocatable    :: grid_points_radial_local(:),w_rad_local(:)
 allocate (grid_points_radial_local(n_points_radial_grid_local),w_rad_local(n_points_radial_grid_local)) 
 dr_radial_integral_local = 15.d0/dble(n_points_radial_grid_local)
 grid_points_radial_local(1)=dr_radial_integral_local
 w_rad_local(1)=dr_radial_integral_local*grid_points_radial_local(1)**2
 do i = 2, n_points_radial_grid_local
  grid_points_radial_local(i) = grid_points_radial_local(i-1) + dr_radial_integral_local
  w_rad_local(i)=dr_radial_integral_local*grid_points_radial_local(i)**2
 enddo

 double precision,allocatable :: n_tilde(:)
 allocate(n_tilde(n_points_radial_grid_local)) 
 n_tilde = 0.d0
!!!!!! Aurevoi la grille

 do i = 1,n_points_radial_grid_local 
  do k = 1,n_points_integration_angular
   r(1)= grid_points_radial_local(i)*angular_quadrature_points(k,1)
   r(2)= grid_points_radial_local(i)*angular_quadrature_points(k,2)
   r(3)= grid_points_radial_local(i)*angular_quadrature_points(k,3)
   call dm_dft_alpha_beta_at_r(r,dm_a,dm_b)
   accu_dr3 += dm_a*weights_angular_points(k)*w_rad_local(i)
  enddo
 enddo


 do i = 1,n_points_radial_grid_local 
  do k = 1,n_points_integration_angular
   r(1)= grid_points_radial_local(i)*angular_quadrature_points(k,1)
   r(2)= grid_points_radial_local(i)*angular_quadrature_points(k,2)
   r(3)= grid_points_radial_local(i)*angular_quadrature_points(k,3)
   call dm_dft_alpha_beta_at_r(r,dm_a,dm_b)
   n_tilde(i) += dm_a*weights_angular_points(k)/(4.d0*pi) 
  enddo
   accu_dr += n_tilde(i)*4.d0*pi*w_rad_local(i)
 enddo

 print*,'integral n alpha(r,teta,phi)  dr3   =',accu_dr3
 print*,'integral n alpha_tilde(r)           =',accu_dr
!print*,'dernier r  =',grid_points_radial_local(n_points_radial_grid_local)
end


 subroutine test_int_n2_spherical_av
 implicit none
 include 'utils/constants.include.F'
 integer :: i,j,k,istate
 double precision :: accu_num,accu_ana
 double precision :: r1(3),r2(3)
 double precision :: r12
 double precision :: n2_hf_alpha_alpha
 accu_ana = 0.d0
 print*,'\\\\\\\\\\\\\\\\\'
 print*,' '
 r1(1) = 0.5d0
 r1(2) = 0.5d0
 r1(3) = 0.d0
 double precision :: delta,n2_deriv2,n2_deriv4
 delta=0.00001d0
 r12=0.d0
 call give_n2_alpha_alpha_hf_at_r1_r12(r1,r12,accu_ana,n2_deriv2,n2_deriv4)
 print*,'n2_deriv2 =',n2_deriv2
 print*,'n2_deriv4 =',n2_deriv4
 do i = 1,10000 
 accu_num = 0.d0 
  do k = 1,n_points_integration_angular
   r2(1)= r1(1)+r12*angular_quadrature_points(k,1)
   r2(2)= r1(2)+r12*angular_quadrature_points(k,2)
   r2(3)= r1(3)+r12*angular_quadrature_points(k,3)
   call give_n2_alpha_alpha_hf_at_r1_r2(r1,r2,n2_hf_alpha_alpha) 
   accu_num += n2_hf_alpha_alpha*weights_angular_points(k)/(4.d0*pi)
  enddo

  call give_n2_alpha_alpha_hf_at_r1_r12(r1,r12,accu_ana,n2_deriv2,n2_deriv4)
  write(33,*)r12,accu_num
  write(44,*)r12,accu_ana
  r12 += delta 

 !print*,'integral num   =',accu_num
 !print*,'integral ana   =',accu_ana
 enddo
end


 subroutine test_ecmd_alpha
 implicit none
!provide e_c_md_mur_aa_LDA_a
!print*,'****************************************'
!print*,' ecmd mur aa LDA a   =', e_c_md_mur_aa_LDA_a
!print*,' mu average aa       =', mu_average_aa
!print*,'****************************************'
 end


 subroutine test_polynome
 implicit none
 double precision :: mu_1,mu_2,mu_3
 double precision :: r12
 double precision :: r(3)
 double precision :: local_potential,two_bod
 integer :: i_point
 r12 = 1.d-5
 do i_point = 1, n_points_final_grid
  r(1) = final_grid_points(1,i_point)
  r(2) = final_grid_points(2,i_point)
  r(3) = final_grid_points(3,i_point)
  call give_eff_inter_alpha_alpha_hf_at_r1_r12(r,r12,local_potential,two_bod)
  if(two_bod.le.1.d-12.or.local_potential.le.0.d0)then
    local_potential = 1.d-10
  else 
    local_potential = local_potential /  two_bod
  endif
  call give_mu_r12(local_potential,r12,mu_1,mu_2,mu_3)
  write(33,*)i_point,mu_1,mu_2,mu_3
 enddo
 end
