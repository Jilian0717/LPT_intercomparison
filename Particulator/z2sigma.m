function s = z2sigma(z, H, zeta)
if nargin < 3, zeta = 0; end
s = (z - zeta) ./ (H + zeta);
s = min(max(s,-1),0);

function z = sigma2z(sigma, H, zeta)
if nargin < 3, zeta = 0; end
z = min(max(sigma,-1),0) .* (H + zeta) + zeta;