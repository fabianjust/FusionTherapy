function [] = figuresMocap(subject)
x= linspace(0,100,240);
	for iMov = [1,4,5]
		for iCon = 1:5
			y = subject.movement(iMov).condition(iCon).jointAngles_mean;
			figh = figure()
			plot(x,y)
			legend({'Abduktion','Elevation','Schulterrotation','Ellbogenflex','ProSup'})
			title(['Joint Angles: ',get_nmov(iMov), ' - ', get_ncon(iCon)])
		end
	end
end