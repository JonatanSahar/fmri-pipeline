function fixedAnsMat = fixAnsMat(ansMat,locations,mode)
% this function fixes ans mats that have zeros in them.
% ans mat is of the stucture  voxels x shuffels. first columns is always
% the real data shuffle
fixedAnsMat = [];
%% find problem areas and report them:
idxNans = find(isnan(median(ansMat,2))==1);% median on nan gives NaN...
if isempty(idxNans) 
    fprintf('\t no bad voxels\n');
    fixedAnsMat = ansMat;
    return 
end
%         ansMat(idxNans,:) = 0;
ct =1; idxnan =[];
for k = 1:size(ansMat,1); % loop on voxels
    tmp = ansMat(k,:);
    if  length(find(isnan(tmp)==1)) > 0
        idxnan(ct, 1) = k;
        idxnan(ct, 2) = length(find(isnan(tmp)==1)) ;
        ct = ct + 1;
    end
end

fprintf('\t %d bad voxels, %d oneshuf, %d all shufs\n',...
    size(idxnan,1),...
    length(find(idxnan(:,2) == 1)),...
    length(find(idxnan(:,2) == size(ansMat,2))))

%% fix the problem
% mode = 'equal-zero';
% mode = 'equal-min';
% mode = 'weight';

fixedAnsMat = ansMat;
idxnbrs = knnsearch(locations, locations, 'K', 10); % will take the 10 closest non nan vals
switch mode
    case 'equal-zero'
        fixedAnsMat(idxnan(:,1),:) = 0; % this creats the same value for all shuffels
    case 'weight' % this creats a diffrent value for each shuf
        for i = 1:size(idxnan,1) % loop on nan indxs
            tidx = idxnan(i,1);
            % within each shuffle, extracct the closest neighbous
            nbrs = idxnbrs(tidx,:);
            for s = 1:size(ansMat,2)
                if isnan(ansMat(nbrs(1),s)) % only replace if this shuffle has nan
                    nbrsfnd = ansMat(nbrs,s);
                    toweight = nbrsfnd(~isnan(nbrsfnd));
                    if isempty(toweight) | length(toweight) < 3 % closes 27 neibhours also nan give min val
                        replaceval = min(ansMat(:));
                        fixedAnsMat(tidx,s) = replaceval;
                    else
                        replaceval = mean(toweight(1:3));
                        fixedAnsMat(tidx,s) = replaceval;
                    end
                end
            end
        end
    case 'equal-min'
        fixedAnsMat(idxnan(:,1),:) = min(ansMat(:)); % this also creates the same val for all shufs
    case 'anatomical'
        fixedAnsMat = ansMat; 
        fixedAnsMat(isnan(ansMat)) = min(ansMat(:));
end