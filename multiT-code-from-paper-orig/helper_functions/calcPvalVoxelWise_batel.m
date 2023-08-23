function Pval = calcPvalVoxelWise_batel(ansMat)
%calculate p-vals for 2nd lvl
load('/media/shiri/DATA/multiTanalysis/results/331RVF20180202T010059withShuffling_.mat','lidx','niifile');
numShuff = size(ansMat,2) -1 ; % first map is real
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
    for i = 1:size(ansMat,1)
        Pval(i) = mean(double(ansMat(i,1)<ansMat(i,2:end)));
        if Pval(i) == 0
            Pval(i) = 1/numShuff;
        end
    end
end
sigP=zeros(size(Pval));
sigP(Pval<0.05)=Pval(Pval<0.05);
    zeroimag = zeros([91,109,91]);
    zeroimag(lidx) = Pval;
    niifile.img = zeroimag;
    save_untouch_nii(niifile,['averaged_all_subs_RVF_feb18']);
end