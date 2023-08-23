function Pval = calcPvalVoxelWise(ansMat)
% check you have shuffeled data
if size(ansMat,2) < 2
    fprintf('you do not have shuffeeld data not calcing p val\n')
    return 
end
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
        Pval(i) = mean(ansMat(i,1)<ansMat(i,2:end));
        if Pval(i) == 0
            Pval(i) = 1/numShuff;
        end
    end
end
end