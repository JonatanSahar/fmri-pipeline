function testMultiTanalysis_semotor_pc(subject,condition,numShuffels,TRafterEV)
params.regionSize      = 27; % sl size
params.numShuffels     =numShuffels;
params.multiResDirName=fullfile('../multit',['results_pc_TR' num2str(TRafterEV) '_2.4.20']);
params.TmapName=['pc_TR' num2str(TRafterEV) '_MNI_tmap'];
params.dataDir=fullfile(pwd,'/pilot_data');
params.multiDataLoc=fullfile(params.dataDir,num2str(subject),'/derive/pc_data/forMultiT',['pc_TR' num2str(TRafterEV)]);
params.multiout_dir=fullfile(params.dataDir,num2str(subject) ,'/derive',['multiTmaps_pc_TR' num2str(TRafterEV) '_3.4.20']);
addpath('../multit/code/helper_functions');
%addpath('neuroelf');
addpath('../../niiTool');
% dataDir=params.dataDir;
%% load mask
maskfn = fullfile(params.dataDir,'commonM_allSubs_MNI.nii.gz');
niifile = load_untouch_nii(maskfn);
niidata =  niifile.img;
[lidx, locations ] = getLocationsFromMaskNii(niidata);
% resultsDirName=params.multiResDirName;

if ~exist(params.multiResDirName)
    mkdir(params.multiResDirName)
end
%% load pe data for one subject
% %If analyzing pe
%
% % data_loc=fullfile(dataDir,num2str(subject),'/derive/PEs/zscore_PEs/all_z_PEs');
% data_loc=fullfile(dataDir,num2str(subject),'/derive/PEs/multi_MNI_PEs/all_PEs_MNI');
% l=load(fullfile(data_loc, [condition '_labels.mat']));
% labels=l.(char(fieldnames(l)));
% condList=load(fullfile(data_loc, [condition '_list.mat']));
% peList=condList.(char(fieldnames(condList)));
%
% pefnms = findFilesBVQX(data_loc,peList);
% data   = zeros(size(pefnms,1),size(locations,1)); % initizlie data
% % load mask data from 3d:
% for p = 1:length(pefnms)
%     niifile = load_untouch_nii(pefnms{p});
%     pedata = niifile.img;
%     peflat  = pedata(lidx); % this is one row in our data matrix
%     data(p,:)  =  peflat;
% end

%% load PC data for one subject
%If analyzing pc
% data_loc=params.multiDataLoc;


load(fullfile(params.multiDataLoc,'all_labels.mat'));
labels=all_labels.(char(condition));
load(fullfile(params.multiDataLoc,'all_data.mat'));
cond_data=all_data.(char(condition));

data   = zeros(size(cond_data,4),size(locations,1)); % initizlie data
% load mask data from 3d:
for t = 1:size(cond_data,4)
    t_data=squeeze(cond_data(:,:,:,t));
    peflat=t_data(lidx); % this is one row in our data matrix
    data(t,:)=peflat;
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
save(fullfile(params.multiResDirName,fnOut));
% msgtitle = sprintf('Finished sub %.3d ',subnum);

%%
% figure;histogram(ansMat);
% return;

%% move results back to 3d:
zeroimag = zeros(size(niidata));
zeroimag(lidx) = ansMat(:,1);
niifile.img = zeroimag;
% mulTout_dir=fullfile(dataDir,num2str(subject) ,'/derive/multiTres_pc_2.4.20');
if ~exist(params.multiout_dir)
    mkdir(params.multiout_dir);
end

TmapName=[condition '_' params.TmapName '_' num2str(params.numShuffels) 'shuffels'];
outfile=fullfile(params.multiout_dir,TmapName);
save_untouch_nii(niifile,outfile);
end
