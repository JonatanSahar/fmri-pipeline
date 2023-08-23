function MAIN() 
params.regionSize      = 27; % sl size 
params.numShuffels     = 0; % num shuffels 
addpath('./helper_functions');
addpath('/usr/local/MATLAB/R2016b/toolbox/NeuroElf_v11_7251');
addpath('/media/shiri/DATA/toolboxes/niiTool');
%% load mask
maskfn = fullfile('..','data','commonAllSubsRVF.nii.gz');
niifile = load_untouch_nii(maskfn);
niidata =  niifile.img;
[lidx, locations ] = getLocationsFromMaskNii(niidata);
resultsDirName=fullfile('..','results');

%% load pe data for one subject 
data_loc = fullfile('..','data','raw_data','304','RVF'); 
pefnms = findFilesBVQX(data_loc,'pe*.nii.gz');
data   = zeros(size(pefnms,1),size(locations,1)); % initizlie data
% load mask data from 3d: 
for p = 1:length(pefnms)
    niifile = load_untouch_nii(pefnms{p});
    pedata = niifile.img; 
    peflat  = pedata(lidx); % this is one row in our data matrix 
    data(p,:)  =  peflat;
end

load(fullfile('..','data','raw_data','301','RVF','labels.mat'));

% this is how you use searchlight to itirate over all rows. 
idx = knnsearch(locations, locations, 'K', params.regionSize); % neighbours

shufMatrix = createShuffMatrixFFX(data,params);
%% start searchlight 
% check data for zeros 
labelsuse = labels;
idxX = find(labelsuse==1);
idxY = find(labelsuse==0);
for j=1:size(idx,1) % loop on voxels
    dataX = data(idxX,idx(j,:));
    dataY = data(idxY,idx(j,:));
    xzeros(j) = sum(sum(dataX,1) == 0);
    yzeros(j) = sum(sum(dataX,1) == 0);
end
if max(xzeros(xzeros~=0)) == params.regionSize
    error('in your data x you %d have voxels with zeros')
    fprintf('\n %d search light with zeros  in x\n',...
        sum(xzeros==params.regionSize));
    fprintf('\n %d x voxels with at least 1 zero voxel\n',...
        sum(xzeros~=0));
end
if max(yzeros(yzeros~=0)) == params.regionSize
    error('in your data x you %d have voxels with zeros')
    fprintf('\n %d search light with zeros  in y\n',...
        sum(yzeros==params.regionSize));
     fprintf('\n %d y voxels with at least 1 zero voxel\n',...
        sum(yzeros~=0));
end
%% loop on all voxels in the brain to create T map
start = tic;
for i = 1:(params.numShuffels + 1) % loop on shuffels
    %don't shuffle first itiration
    if i ==1 % don't shuffle data
        labelsuse = labels;
    else % shuffle data
        labelsuse = labels(shufMatrix(:,i-1));
    end
    idxX = find(labelsuse==1);
    idxY = find(labelsuse==0);
    for j=1:size(idx,1) % loop on voxels
        dataX = data(idxX,idx(j,:));
        dataY = data(idxY,idx(j,:));
        [ansMat(j,i) ] = calcTstatMuniMengTwoGroup_v2(dataX,dataY);
    end
    timeVec(i) = toc(start); 
%     reportProgress(fnTosave,i,params, timeVec);
end
% fnOut = [fnTosave datestr(clock,30) '_.mat'];
fnOut=toc(start)
if ~exist
    mkdir(resultsDirName);
end
save(fullfile(resultsDirName,fnOut));
% msgtitle = sprintf('Finished sub %.3d ',subnum);

%%

return; 

% move results back to 3d: 
zeroimag = zeros(size(niidata));
zeroimag(lidx) = peflat;
niifile.img = zeroimag;
save_untouch_nii(niifile,'testsave.nii'); 



    