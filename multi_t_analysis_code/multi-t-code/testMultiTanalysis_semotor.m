function testMultiTanalysis_semotor(subject,condition)
params.regionSize      = 27; % sl size
params.numShuffels     =400; % num shuffels
addpath('../../multit/code/helper_functions');
%addpath('neuroelf');
addpath('../../niiTool');
dataDir=fullfile(pwd,'pilot_data');
%% load mask
maskfn = fullfile(dataDir,'MultiRes_24.2.19','commonM_allSubs_MNI.nii.gz');
niifile = load_untouch_nii(maskfn);
niidata =  niifile.img;
[lidx, locations ] = getLocationsFromMaskNii(niidata);
resultsDirName=fullfile('../../multit/results_zscored');

%% load pe data for one subject

% if strcmp(reg,'nat')
    pesType='PEs';
% else
%     pesType='PEs_MNI';
% end
PEsDir=fullfile(dataDir,num2str(subject),'/derive/PEs/zscore_PEs');



if strcmp(condition,'hand') || strcmp(condition,'percept') || strcmp(condition,'ans')|| strcmp(condition,'speed') || strcmp(condition,'run_effect') || strcmp(condition,'run_map')
    data_loc = fullfile(PEsDir, ['all_' pesType]); 
elseif strcmp(condition,'half_runMap') || strcmp(condition,'half_runEffect')
    data_loc = fullfile(PEsDir,'half_run'); 
else % within hand conditions
    data_loc = fullfile(PEsDir,[condition '_' pesType]);
end

s=load(fullfile(data_loc, [condition '_labels']));
labels=s.(char(fieldnames(s)));

pefnms = findFilesBVQX(data_loc,'zscored_pe*.nii.gz');
data   = zeros(size(pefnms,1),size(locations,1)); % initizlie data
% load mask data from 3d:
for p = 1:length(pefnms)
    niifile = load_untouch_nii(pefnms{p});
    pedata = niifile.img;
    peflat  = pedata(lidx); % this is one row in our data matrix
    data(p,:)  =  peflat;
end



% this is how you use searchlight to itirate over all rows.
idx = knnsearch(locations, locations, 'K', params.regionSize); % neighbours

shufMatrix = createShuffMatrixFFX(data,params);
%% start searchlight
% check data for zeros
labelsuse = labels;
idxX = find(labelsuse==1);
idxY = find(labelsuse==0);
%% checks if there are any zeros in the data
for j=1:size(idx,1) % loop on voxels
    dataX = data(idxX,idx(j,:));
    dataY = data(idxY,idx(j,:));
    xzeros(j) = sum(sum(dataX,1) == 0);
    yzeros(j) = sum(sum(dataX,1) == 0);
end
if max(xzeros(xzeros~=0)) == params.regionSize
    error('in your data x you %d have voxels with zeros')
    disp('\n %d search light with zeros  in x\n',...
        sum(xzeros==params.regionSize));
    disp('\n %d x voxels with at least 1 zero voxel\n',...
        sum(xzeros~=0));
end
if max(yzeros(yzeros~=0)) == params.regionSize
    error('in your data x you %d have voxels with zeros')
    disp('\n %d search light with zeros  in y\n',...
        sum(yzeros==params.regionSize));
    disp('\n %d y voxels with at least 1 zero voxel\n',...
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
    if mod(i,20)==0 || i==1
        disp(i);
    end
    %      reportProgress(fnTosave,i,params, timeVec);
end
timing=toc(start);
fnOut = [num2str(subject),condition, datestr(clock,30) 'withShuffling_' num2str(params.numShuffels) '.mat'];
save(fullfile(resultsDirName,fnOut));
% msgtitle = sprintf('Finished sub %.3d ',subnum);

%%
% figure;histogram(ansMat);
% return;

%% move results back to 3d:
zeroimag = zeros(size(niidata));
zeroimag(lidx) = ansMat(:,1);
niifile.img = zeroimag;
mulTout_dir=fullfile(dataDir,num2str(subject) ,'/derive/multiTres_24.2.19');
if ~exist(mulTout_dir)
    mkdir(mulTout_dir);
    % else
    %     mulTout_dir=fullfile(dataDir,num2str(subject) ,'/derive/multiTres_testing');
    %     mkdir(mulTout_dir);
end


TmapName=[condition '_MNI_tmap' num2str(params.numShuffels) 'shuffels_zscored'];
% end
outfile=fullfile(mulTout_dir,TmapName);
save_untouch_nii(niifile,outfile);
end
