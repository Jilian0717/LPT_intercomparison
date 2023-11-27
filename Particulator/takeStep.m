function s1 = takeStep(s0,dt,rel,run)
% the basic operation X1 = X0 + X*dt.
% midpoint method.
% fills in only x,y,z,t; other fields are calculated in interpEverything().
ac = double(s0.active); % when this is 0, x,y,z do not advance but t does
smid.x = s0.x + ac .* s0.uScaled .* 0.5 .* dt; % take half an advective step
smid.y = s0.y + ac .* s0.vScaled .* 0.5 .* dt;
smid.z = s0.z + ac .* s0.wScaled .* 0.5 .* dt;
smid.t = s0.t + 0.5 .* dt;
smid = interpEverything(smid,dt,rel,run); % calculate new advective velocities
s1.x = s0.x + ac .*  smid.uScaled .* dt; % full step
s1.y = s0.y + ac .*  smid.vScaled .* dt;
s1.z = s0.z + ac .* (smid.wScaled + s0.wdiff + s0.dKsdz) .* dt;
s1.t = s0.t + dt;
if rel.avoidLand
	% if the step is going to take the particle into a region where the
	% interpolated land mask is less than 0.5, don't take the step
	mask1 = run.interp('mask',s1.x,s1.y,[],s1.t);
	f = find(mask1 < rel.landThreshhold);
	if ~isempty(f)
		s1.x(f) = s0.x(f);
		s1.y(f) = s0.y(f);
		s1.z(f) = s0.z(f);
	end
end