function Pval = calcPvalVoxelWise_semotor(ansMat,condition,outFolder,linearIndex)

%calculate p-vals for 2nd lvl
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
        Pval(i) = mean(double(ansMat(i,1)<=ansMat(i,2:end)));
        if Pval(i) == 0
            Pval(i) = 1/numShuff;
        end
    end
end

% sigP=zeros(size(Pval));
% sigP(Pval<0.05)=Pval(Pval<0.05);
zeroimag = zeros([91,109,91]);% background
zeroimag(linearIndex) = Pval;
niifile = single(zeroimag);

PmapName=sprintf("pvalue_map_%s", condition);
%  outFolder=fullfile(pwd,'pilot_data','MultiGroupRes_pc_1.4.20');
mkdir(outFolder);
outfile=fullfile(outFolder,PmapName);
niftiwrite(niifile,outfile, info, 'Compressed',true);

end
