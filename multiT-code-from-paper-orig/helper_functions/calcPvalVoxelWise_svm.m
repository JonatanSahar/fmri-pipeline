function Pval = calcPvalVoxelWise_svm(ansMat,condition,res_dir)
% addpath('../../niiTool');
%calculate p-vals for 2nd lvl
% load(fullfile('../../multit/results/4hand20181207T134958withShuffling_400.mat'),'lidx','niifile'); %just for the spatial features of the map
numShuff = size(ansMat,2) -1 ; % first map is real
if size(ansMat,2)<1500%%%%%%%%%%%%%%%%
    % calc p value voxel wise
    % this is effectively two tailed inference
    compMatrix = repmat(ansMat(:,1),1,numShuff);
    Pval  = mean((compMatrix) <=  ansMat(:,2:end),2);%%%%%%%%%%%%%%%%%%%%%%%%
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


Pname=[condition 'nShufs_' num2str(size(ansMat,2)-1) '_Pmat.mat'];
save(fullfile(res_dir,Pname),'Pval')


% % sigP=zeros(size(Pval));
% % sigP(Pval<0.05)=Pval(Pval<0.05);
% zeroimag = zeros([91,109,91]);% background
% zeroimag(lidx) = Pval;
% niifile.img = zeroimag;
% 
%  PmapName=[condition '_Pmap_zscored'];
%  outFolder=fullfile(pwd,'pilot_data','MultiRes_24.2.19');
%  mkdir(outFolder); 
% outfile=fullfile(outFolder,PmapName);
% save_untouch_nii(niifile,outfile);

end