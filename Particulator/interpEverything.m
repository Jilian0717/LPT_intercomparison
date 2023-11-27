function s = interpEverything(s0,dt,rel,run)
% takes a set of particle positions s.x, s.y, s.z, s.t and interpolates
% sigma, H, zeta, u, v, w, dksdz, wdiff, tracers, uScaled, vScaled, active
s = s0;

[s.x, s.y, s.active] = run.filterCoordinates(s.x, s.y);
s.active = s.active & (s0.t >= rel.t0);

s.H = run.interp('H',s.x, s.y);
s.zeta = run.interp('zeta',s.x, s.y, [], s.t);
s.mask = run.interp('mask',s.x, s.y, [], s.t);

if strcmpi(rel.verticalMode,'zLevel')
	s.z = repmat(rel.verticalLevel,size(s.x));
	s.sigma = z2sigma(s.z, s.H, s.zeta);
elseif strcmpi(rel.verticalMode,'sigmaLevel')
	s.sigma = repmat(rel.verticalLevel,size(s.x));
	s.z = sigma2z(s.sigma, s.H, s.zeta);
elseif strcmpi(rel.verticalMode,'zAverage')
	s.z = repmat(mean(rel.verticalLevel),size(s.x));
	s.sigma = z2sigma(s.z, s.H, s.zeta);
else % 3D
	if isempty(s.z) % z not defined yet, perhaps at the first step
		s.z = sigma2z(s.sigma, s.H, s.zeta);	
	else % normal case
		s.sigma = z2sigma(s.z, s.H, s.zeta);
		s.z = sigma2z(s.sigma, s.H, s.zeta);	
	end
end

if strcmpi(rel.verticalMode,'zAverage')
	s.u = run.interpDepthAverage('u', s.x, s.y, rel.verticalLevel, s.t);
	s.v = run.interpDepthAverage('v', s.x, s.y, rel.verticalLevel, s.t);
	s.w = run.interpDepthAverage('w', s.x, s.y, rel.verticalLevel, s.t);
else
	s.u = run.interp('u', s.x, s.y, s.sigma, s.t);
	s.v = run.interp('v', s.x, s.y, s.sigma, s.t);
	s.w = run.interp('w', s.x, s.y, s.sigma, s.t);
end
s.uScaled = run.scaleU(s.u, s.x, s.y);
s.vScaled = run.scaleV(s.v, s.x, s.y);
s.wScaled = run.scaleW(s.w);
if strcmpi(rel.verticalMode,'zAverage')
	s.Ks = run.interpDepthAverage('Ks', s.x, s.y, rel.verticalLevel, s.t);
	for i=1:length(rel.tracers)
		s.(rel.tracers{i}) = run.interpDepthAverage(rel.tracers{i}, ...
								s.x, s.y, rel.verticalLevel, s.t);
	end
else
	s.Ks = run.interp('Ks', s.x, s.y, s.sigma, s.t);
	for i=1:length(rel.tracers)
		s.(rel.tracers{i}) = run.interp(rel.tracers{i}, ...
								s.x, s.y, s.sigma, s.t);
	end
end

for i=1:length(rel.profiles)
	if i==1
		s.profiles.v_axis = run.verticalAxisForProfiles;
	end
	s.profiles.(rel.profiles{i}) = run.interpProfile(rel.profiles{i}, ...
									 s.x, s.y, s.t);
end

if rel.verticalDiffusion
	dt_secs = dt .* 86400;
		% advective velocity is stored as m/day, but this block of code works in
		% m/s and m^2/s, and converts to m/day at the end
	% diffusion gradient dKs/dz
	wdiff_approx = sqrt(2.*s.Ks./dt_secs);
	dsigma = wdiff_approx .* dt_secs ./ (s.H + s.zeta);
		% half-span to take gradient over--the scale of the next diffusive step
	sigmatop = min(s.sigma + dsigma,0);
	sigmabot = max(s.sigma - dsigma,-1);
	Kstop = run.interp('Ks', s.x, s.y, sigmatop, s.t);
	Ksbot = run.interp('Ks', s.x, s.y, sigmabot, s.t);
	s.dKsdz = (Kstop - Ksbot) ./ (sigmatop - sigmabot) ./ (s.H + s.zeta);
	% diffusion velocity wdiff
	sigma1 = z2sigma(s.z + 0.5.*s.dKsdz.* dt_secs, s.H, s.zeta);
	Ks1 = run.interp('Ks', s.x, s.y, sigma1, s.t);
	s.wdiff = sqrt(2.*Ks1./dt_secs) .* randn(size(Ks1));
	% now put both velocity terms in m/day
	s.dKsdz = s.dKsdz .* 86400;
	s.wdiff = s.wdiff .* 86400;
else
	s.dKsdz = 0;
	s.wdiff = 0;
end

if rel.horizIsotropicDiffusivity > 0
	dt_secs = dt .* 86400;
	udiffscale = sqrt(2.*rel.horizIsotropicDiffusivity./dt_secs); 
	s.u = s.u + udiffscale .* randn(size(s.u));
	s.v = s.v + udiffscale .* randn(size(s.u));
	s.uScaled = run.scaleU(s.u, s.x, s.y);
	s.vScaled = run.scaleV(s.v, s.x, s.y);
end

if rel.horizShearDiffusion
	% assume verticalMode = zAverage 
	ualong = sqrt(s.u.^2 + s.v.^2);
	rx = s.u./ualong; % unit vector in the along-flow direction is
	ry = s.v./ualong; % rx xhat + ry yhat
	ualongdiff = ualong ./ sqrt(3) .* randn(size(s.u));
	s.u = s.u + ualongdiff .* rx;
	s.v = s.v + ualongdiff .* ry;
	s.uScaled = run.scaleU(s.u, s.x, s.y);
	s.vScaled = run.scaleV(s.v, s.x, s.y);	
end