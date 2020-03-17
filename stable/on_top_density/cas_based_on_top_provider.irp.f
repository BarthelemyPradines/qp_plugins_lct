
 subroutine act_on_top_on_grid_pt(ipoint,istate,pure_act_on_top_of_r)
 implicit none
 BEGIN_DOC
 ! pure_act_on_top_of_r returns the purely ACTIVE part of the STATE AVERAGED on top pair density
 END_DOC
 integer, intent(in) :: ipoint,istate
 double precision, intent(out) :: pure_act_on_top_of_r
 double precision :: phi_i,phi_j,phi_k,phi_l
 integer :: i,j,k,l

 pure_act_on_top_of_r = 0.d0
  do l = 1, n_act_orb
   phi_l = act_mos_in_r_array(l,ipoint)
   do k = 1, n_act_orb
    phi_k = act_mos_in_r_array(k,ipoint)
     do j = 1, n_act_orb
      phi_j = act_mos_in_r_array(j,ipoint)
      do i = 1, n_act_orb
       phi_i = act_mos_in_r_array(i,ipoint)
       !                                                            1 2 1 2
       pure_act_on_top_of_r += all_states_act_two_rdm_alpha_beta_mo(i,j,k,l,istate) * phi_i * phi_j * phi_k * phi_l
     enddo
    enddo
   enddo
  enddo
 end


 BEGIN_PROVIDER [double precision, core_inact_act_on_top_of_r,(n_points_final_grid,N_states) ]
 implicit none
 BEGIN_DOC
 ! on top pair density at each grid point of a CAS-BASED wf
 END_DOC
 integer :: i_point,istate
 double precision :: wall_0,wall_1,core_inact_dm,pure_act_on_top_of_r
 logical :: no_core
 print*,'providing the core_inact_act_on_top_of_r'
 ! for parallelization
 provide inact_density core_density one_e_act_density_beta one_e_act_density_alpha
 i_point = 1
 istate = 1
 call act_on_top_on_grid_pt(i_point,istate,pure_act_on_top_of_r)
 call wall_time(wall_0)
 no_core = .False.
 if(no_core_density .EQ. "no_core_dm")then
  print*,'USING THE VALENCE ONLY TWO BODY DENSITY'
  no_core = .True.
 endif
 !$OMP PARALLEL DO &
 !$OMP DEFAULT (NONE)  &
 !$OMP PRIVATE (i_point,core_inact_dm,istate,pure_act_on_top_of_r) & 
 !$OMP SHARED(core_inact_act_on_top_of_r,n_points_final_grid,inact_density,core_density,one_e_act_density_beta,one_e_act_density_alpha,no_core,N_states)
 do i_point = 1, n_points_final_grid
  do istate = 1, N_states
   call act_on_top_on_grid_pt(i_point,istate,pure_act_on_top_of_r)
   if(no_core) then
    core_inact_dm = inact_density(i_point) 
   else 
    core_inact_dm = (inact_density(i_point) + core_density(i_point))
   endif
   core_inact_act_on_top_of_r(i_point,istate) = pure_act_on_top_of_r + core_inact_dm * (one_e_act_density_beta(i_point,istate) + one_e_act_density_alpha(i_point,istate)) + core_inact_dm*core_inact_dm
  enddo
 enddo
 !$OMP END PARALLEL DO
 call wall_time(wall_1)
 print*,'provided the core_inact_act_on_top_of_r'
 print*,'Time to provide :',wall_1 - wall_0

 END_PROVIDER 

