tic
clear; clc;
arg1 = 'LiveOcean';
arg2 = './hydrodynamics/';

% _run_ identifies a model run to use as source data
run = modelRun_romsCascadia(arg1,arg2);	
datestr(run.t(1))
datestr(run.t(end))
%%
% pick initial coordinates
fn1 = './';
fn2 = 'release_2021.06.01_100k_7day.nc';
lon_tracker = ncread([fn1,fn2],'lon'); % obtain the inital particle coordiate from tracker
lat_tracker = ncread([fn1,fn2],'lat');
cs = ncread([fn1,fn2],'cs');
x0 = lon_tracker(:,1);
y0 = lat_tracker(:,1);
sigma0 = cs(:,1);
t0 = run.t(1);	 % start at the start of the model run
t1 = run.t(23); %2021.06.01 00:00:00 to 2021.06.01 23:00:00

% _rel_ = the setup of a particle release
rel = par_release('x0',x0,'y0',y0,'sigma0',sigma0,'t0',t0,'t1',t1,...
				  'Ninternal',12,'tracers',{'salt','temp'},...
                  'verbose',1,...
                  'verticalMode','3D');

steps = par_integrate(rel,run);	%  = the actual Lagrangian integration
						
P = par_concatSteps(steps); % concatenates _steps_ variable by variable into
							% a single structure P that's easier to analyze
save P_100k P -v7.3  % save particle locations
toc
