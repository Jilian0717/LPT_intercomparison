function steps1 = saveStep(step,i,saveToVar,steps,basefilename)
% saves _step_ either to the variable _steps_, a numbered file, or both.

if saveToVar
	if ~isempty(steps)
		steps1 = steps;
		steps1(i) = step;
	else
		steps1 = step;
	end
end
if ~isempty(basefilename)
	nstr = ['0000' num2str(i)];
	nstr = nstr(end-3:end);
	filename = [basefilename nstr '.mat'];
	save(filename,'step');
end