%calculate p-vals for 2nd lvl
load('./results/2nd_lvl/ND_FFX_VDS_24-subs_27-slsze_1-fld_400shufs_10000-stlzer_mode-equal-min_newT2013_RVF.mat');
load('../results/331LVF20180202T165212withShuffling_.mat','lidx','niifile');
addpath('./niitools');
numShuff = size(avgAnsMat,2) -1 ; % first map is real
if size(ansMat,2)<1500
% calc p value voxel wise
% this is effectively two tailed inference 
compMatrix = repmat(ansMat(:,1),1,numShuff);
Pval  = mean(compMatrix <  ansMat(:,2:end),2);
% set any Pval that is zero the effective max pval 
Pval(Pval==0) = 1/numShuff;
else
    % loop on voxels if you have more than 1500 shuffle maps since it takes
    % up too much memory to do it the other way. 
    for i = 1:size(avgAnsMat,1)
        Pval(i) = mean(double(avgAnsMat(i,1)<avgAnsMat(i,2:end)));
        if Pval(i) == 0
            Pval(i) = 1/numShuff;
        end
    end
end
sigP=zeros(size(Pval));
sigP=fdr_bh(Pval);
    zeroimag = zeros([91,109,91]);
    zeroimag(lidx) = relsigP;
    niifile.img = zeroimag;
    save_untouch_nii(niifile,['neighborstest2']);