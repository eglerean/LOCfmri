close all
clear all
addpath(genpath('/m/nbe/scratch/braindata/shared/toolboxes/bramila/bramila/'))

subjects={
'012TEKO'
'055VIVI'
'022MINI'
'036ARPU'
'014MILA'
'027JAKO'
'051MIKO'
}
basepath='/m/nbe/scratch/braindata/eglerean/LOCfmri';
allQC=[];
conditions={
	'rsfMRIBase'
	'rsfMRILOC'
};

for c=1:length(conditions)
    for s=1:length(subjects)
		filename=[basepath '/' subjects{s} '/' conditions{c} '/bramila/cfg.mat'];
		if(exist(filename)~=2) disp(['Missing file ' filename]);continue; end
		load(filename)
		FD=cfg.fDisplacement;
		tempQC=prctile(FD,[1 25 50 75 99 100]);
		NGood=length(find(FD<0.5));

		allQC(s+(c-1)*7,:)=[tempQC NGood NGood/length(FD)];
		
	end
end
%%
figure
stem(allQC(1:7,end))
hold on
stem(.2+(1:7),allQC(8:end,end))
xlabel('Subjects ID (blue = rsfMRIBase, red = rsfMRILOC)')
ylabel('% of time poitns with low framewise displacement')
title('Head motion quality check')
saveas(gcf,'figs/HeadMotionQC.png')
