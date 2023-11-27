function z = sigma2z(sigma, H, zeta)
if nargin < 3, zeta = 0; end
z = min(max(sigma,-1),0) .* (H + zeta) + zeta;