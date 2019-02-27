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

load brainnetome_MPM_rois_2mm.mat
mkdir networks

conditions={
	'rsfMRIBase'
	'rsfMRILOC'
};
ids=find(triu(ones(length(rois)),1));
allnets=[];
for c=1:length(conditions)
	for s=1:length(subjects)
		if(exist(['./networks/' num2str(s) '_' num2str(c) '.mat'])==2)
			disp(['Network already exists in ./networks/' num2str(s) '_' num2str(c) '.mat'])
		else
			filename=[basepath '/' subjects{s} '/' conditions{c} '/epi_preprocessed.nii']; 
			disp(filename)
			cfg=[];
			cfg.rois = rois; 
			cfg.infile = filename;
			cfg.usemean = 1;
			[nodeTS perc]=bramila_roiextract(cfg);
			adj=corr(nodeTS);
			adj(isnan(adj))=0;
			save(['./networks/' num2str(s) '_' num2str(c) '.mat'],'adj','nodeTS','perc')
		end
	end
end

