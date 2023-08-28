function Pval = calcPvalVoxelWise_semotor(ansMat,condition,outFolder, P)
%calculate p-vals for 2nd lvl
numShuff = size(ansMat,2) -1 ; % first map is real
maskData = niftiread(P.multiTMNIMask);
maskInfo = niftiinfo(P.multiTMNIMask);
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
zeroimag = zeros(size(maskData));
% zeroimag = zeros([91,109,91]);% background
zeroimag(P.linearIndex) = Pval;
niifile = single(zeroimag);

PmapName= sprintf('%s_pMmap', condition);
mkdir(outFolder);
outfile=fullfile(outFolder,PmapName);
niftiwrite(niifile, outfile, maskInfo, 'Compressed',true);

end
