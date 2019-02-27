close all
clear all
addpath(genpath('/m/nbe/scratch/braindata/shared/toolboxes/bramila/bramila/'))
addpath(genpath('/m/nbe/scratch/braindata/shared/toolboxes/export_fig/'))

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
            load(['./networks/' num2str(s) '_' num2str(c) '.mat']) % variable adj loaded
        else
            error('You need to compute the networks first')
        end
        allnets=[allnets adj(ids)];
    end
end

% NOTE: we miss the framewise displacement for one subject. Once we find
% that, we can run the permutation t-test AFTER controlling for mean FD
% <<< Add here code for regressing out mean FD from each link >>>


%% permutation t-test to estimate each links' p-value
if(0)
    stats=bramila_ttest2_np(allnets,[ones(1,7) 2*ones(1,7)],5000);
    save mats/stats stats
else
    load mats/stats stats
end


% FDR correction
q=mafdr(min(stats.pvals,[],2),'BHFDR','true');

% num of significant links
length(find(q<0.05))

% store output
outadj=zeros(length(rois));
outadj(ids)=stats.tvals;
qvals_network=zeros(length(rois));
qvals_network(ids)=q;
qvals_network=qvals_network+qvals_network';
ttest_network=outadj+outadj';


save mats/ttest_Base_vs_LOC ttest_network qvals_network


%% display strongest output
[i j]=find(abs(outadj)>8);
for id=1:length(i)
    disp([rois(i(id)).label '-' rois(j(id)).label ' ' num2str(outadj(i(id),j(id)))])
end

if(0)
    brain=load_nii('/m/nbe/scratch/braindata/shared/toolboxes/HarvardOxford/MNI152_T1_2mm_brain.nii');
    
    vbr=double(brain.img);
    vbr=smooth3(brain.img,'box',11);
    
    save('mats/template_smooth.mat','vbr');
else
    load('mats/template_smooth.mat');
end
close all
figure(1)
netmask=(ttest_network>8);
net=netmask.*ttest_network;
ns=sum(sign(net));

template=isosurface(vbr,2000);
pp=patch(template, 'FaceColor', [1 1 1]-0.2, 'EdgeColor','none','FaceAlpha',0.2);
axis equal
axis ij

R=length(rois);
for ro=1:R
    c=rois(ro).centroidMNI;
    [x y z]=sphere(45);
    cfg=[];
    cfg.type='MNI';
    cfg.coordinates = c;
    cfg.imgsize = [91 109 91];
    [xx,yy,zz] = bramila_MNI(cfg);
    newcentroids(ro,:)=[xx,yy,zz];
    %radi=ns(ro)/3+1*sign(ns(ro));
    radi=sqrt(ns(ro));
    
    x=radi*x+yy;
    y=radi*y+xx;
    z=radi*z+zz;
    s = surface(x,y,z,ones(size(z)));
    %color=map(ns(ro),:);
    map=cbrewer('seq','Reds',9);
    color=map(end,:);
    %if(isout(map(ro))==0)
    %    isout(map(ro))=1;
    %end
    set(s,'FaceColor',color);
    set(s,'FaceAlpha',1);
    set(s,'EdgeColor','none');
    if(ns(ro)>0)
        %text(yy-3,xx,zz+ns(ro)/3+2,rois(ro).label,'Color',color);
    end
    
    %set(s,'AmbientStrength',0)
    %set(s,'DiffuseStrength',0)
    
end
view(3)

for r=1:R
    v1=newcentroids(r,:);
    for c=(r+1):R
        val=net(r,c);
        if(val==0) continue; end
        disp([num2str(ns(r)) ' - ' num2str(ns(c))])
        %color=map(ns(ro),:);
        color=[0 0 0];
        v2=newcentroids(c,:);
        h=patch([v1(2) v2(2)],[v1(1) v2(1)],[v1(3) v2(3)],1);
        
        set(h,'EdgeAlpha',1);
        
            % t values
            if(val>=0)
                LW=1;LC=.5;
            end
            if(val>=10)
                LW=1; LC=.25;
            end
            if(val>=13)
                LW=2; LC=0;
            end
            
        set(h,'LineWidth',LW);
        set(h,'EdgeColor',[1 1 1].*LC);
    end
end
set(gcf,'units','normalized','outerposition',[0 0 1 1])
set(gcf,'Color',[1 1 1])
axis off
box off
set(gcf,'paperunits','centimeters')
set(gcf,'paperposition',[1 1 4 8])


view([-1 1 1])
l1=light;
set(l1,'Position',[ -1 1 1])
l2=light;
set(l2,'Position',[ 1 1 -1])



tags='figs/Base_vs_LOC';
export_fig([tags '_persp.png'])



view([0 1 0])
set(l2,'Position',[ 0 1 0])
export_fig([tags '_sagittal.png'])

view([0 0 1])
set(l2,'Position',[ 0 0 -1])
export_fig([tags '_axial.png'])


view([1 0 0])
set(l2,'Position',[ -1 0 0])
set(l1,'Position',[ -1 1 -1])
export_fig([tags '_coronal.png'])




