function [stlzerAnsMat, stlzerPerms] = createStelzerPermutations(ansMat,nummapscreate,avgmode)
%% This function create stelzer permutations given
% ansMat struc - voxels X shuffels X subjects 

% QA 
if size(ansMat,2) < 2
    error('You do not have any shuffles in this data'); 
else
%     fprintf('creating %d stlzer shuffels from %d real shufs\n',...
%         nummapscreate,size(ansMat,2));
end
if length(find(isnan(ansMat)==1))
    warning('You have NaNs in your avg ans mat data'); 
    ansMat(isnan(ansMat)) = 0; 
end
% check that you have shuffels and report what you will do 
% check that you don't have any nans 
numrealshufs = size(ansMat,2) - 1;
stlzerAnsMat = zeros(size(ansMat,1),nummapscreate+1);
for j = 1:nummapscreate+1
        if j == 1 % real map
            tmp = squeeze(ansMat(:,1,:));
            stlzerAnsMat(:,j) = avgmap(tmp,avgmode);
        else
            numSubs = size(ansMat,3);
            for k = 1:numSubs% extract rand map from each sub
                idxMap = randperm(numrealshufs,1) + 1; % first map is real
                tmp(:,k) = ansMat(:,idxMap,k);
                while sum(isnan(tmp(:,k)))~= 0 % choose another map 
                    idxMap = randperm(numrealshufs,1) + 1; % first map is real
                    tmp(:,k) = ansMat(:,idxMap,k);
                end
                stlzerPerms(k,j) = idxMap;
            end
            stlzerAnsMat(:,j) = avgmap(tmp,avgmode);
        end
        clear tmp;
%         fprintf('finished comp map %d stlzr style\n',j);
end
end

function outmap = avgmap(data,mode)
switch mode
    case 'mean'
        outmap = mean(data,2);
    case 'median'
        outmap = median(data,2);
    case 'nanmean'
        outmap = nanmean(data,2);
    case 'nanmedian'
        outmap = nanmedian(data,2);
end
        
end