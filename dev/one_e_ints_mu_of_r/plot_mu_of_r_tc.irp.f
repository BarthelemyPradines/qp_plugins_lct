program plot_mu_of_r_tc
 implicit none
 double precision :: x,r(3),dx,xmin,xmax,r_tmp(3)
 double precision :: mu_lda,mu_minus,mu_plus,grad_mu_sq,grad_mu(3),rho_a_hf,rho_b_hf,mu
 double precision :: mu_lda_damped,mu_min,dx_2,mu_damped
 integer :: i,nx,m
 nx = 1000
 xmax = 10.d0
 xmin = -10.d0
 dx = (xmax - xmin)/dble(nx)
 x = xmin 
 mu_min = mu_erf
 do i = 1, nx
  r = 0.d0
  r(3) = x
  call dm_dft_alpha_beta_at_r(r,rho_a_hf,rho_b_hf)
  mu_damped = mu_lda_damped(rho_a_hf,rho_b_hf,mu_min)
  mu = mu_lda(rho_a_hf,rho_b_hf)
  grad_mu = 0.d0
  call get_grad_damped_mu_lda(r,dx_2,mu_min,grad_mu)
  grad_mu_sq = 0.d0
  do m = 1, 3
   grad_mu_sq += grad_mu(m)**2.
  enddo
  call dm_dft_alpha_beta_at_r(r,rho_a_hf,rho_b_hf)
  write(33,'(100(F16.10,X))')x,rho_a_hf + rho_b_hf, mu, mu_damped,dsqrt(grad_mu_sq)
  x += dx
 enddo

end

